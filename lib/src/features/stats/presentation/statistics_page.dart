import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/goal_service.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/services/water_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/layout/sn_app_bar.dart';
import 'package:smartnutri/src/core/ui/layout/sn_scaffold.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/core/utils/calorie_streak.dart';
import 'package:smartnutri/src/core/utils/date_utils.dart';
import 'package:smartnutri/src/features/nutrition/domain/nutrition_goal.dart';

/// Tổng hợp 7 ngày gần nhất (calo, macro, nước, streak).
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _loading = true;
  String? _error;
  int _streak = 0;
  double _avgKcal = 0;
  double _avgProtein = 0;
  double _avgCarb = 0;
  double _avgFat = 0;
  double _avgWaterL = 0;
  int _goalWaterMl = 2500;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final uid = context.read<AuthService>().currentUser!.uid;
    final meal = context.read<MealService>();
    final water = context.read<WaterService>();
    final goalSnap =
        await context.read<GoalService>().getGoal(uid);
    final goal = goalSnap ?? NutritionGoal.defaultGoal(uid);
    try {
      var kcalSum = 0.0;
      var pSum = 0.0;
      var cSum = 0.0;
      var fSum = 0.0;
      var wSum = 0.0;
      final today = DateTime.now();
      final base = DateTime(today.year, today.month, today.day);
      for (var i = 6; i >= 0; i--) {
        final d = base.subtract(Duration(days: i));
        final ds = AppDateUtils.toDateStr(d);
        final entries = await meal.getEntriesForDate(uid, ds);
        kcalSum += entries.fold(0.0, (s, e) => s + e.calorieKcal);
        pSum += entries.fold(0.0, (s, e) => s + e.proteinG);
        cSum += entries.fold(0.0, (s, e) => s + e.carbG);
        fSum += entries.fold(0.0, (s, e) => s + e.fatG);
        wSum += await water.getWaterMl(uid, ds);
      }
      final streak = await CalorieStreak.compute(
        meal: meal,
        uid: uid,
        calorieTarget: goal.calorieTarget,
      );
      if (!mounted) return;
      setState(() {
        _streak = streak;
        _avgKcal = kcalSum / 7;
        _avgProtein = pSum / 7;
        _avgCarb = cSum / 7;
        _avgFat = fSum / 7;
        _avgWaterL = wSum / 7 / 1000;
        _goalWaterMl = goal.waterTargetMl.round();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Không tải được dữ liệu. ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SNScaffold(
      appBar: SNAppBar(
        title: 'Thống kê 7 ngày',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, textAlign: TextAlign.center))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SNCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chuỗi ngày đạt calo (80–110% mục tiêu)',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Icon(Icons.local_fire_department,
                                    color: Colors.orange.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  '$_streak ngày liên tiếp',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SNCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trung bình mỗi ngày',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _StatLine(
                                label: 'Calo',
                                value: '${_avgKcal.round()} kcal'),
                            _StatLine(
                                label: 'Protein',
                                value: '${_avgProtein.toStringAsFixed(1)} g'),
                            _StatLine(
                                label: 'Carb',
                                value: '${_avgCarb.toStringAsFixed(1)} g'),
                            _StatLine(
                                label: 'Fat',
                                value: '${_avgFat.toStringAsFixed(1)} g'),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SNCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nước uống (7 ngày)',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Trung bình: ${_avgWaterL.toStringAsFixed(2)} L / ngày',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              'Mục tiêu hồ sơ: ${(_goalWaterMl / 1000).toStringAsFixed(1)} L',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
