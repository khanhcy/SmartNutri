import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/goal_service.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/services/water_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/layout/sn_app_bar.dart';
import 'package:smartnutri/src/core/ui/layout/sn_scaffold.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/core/utils/calorie_streak.dart';
import 'package:smartnutri/src/core/utils/date_utils.dart';
import 'package:smartnutri/src/features/nutrition/domain/nutrition_goal.dart';

/// Weekly Review — Tổng kết tuần với insights, per-day breakdown, và xu hướng.
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _loading = true;
  String? _error;
  int _streak = 0;
  NutritionGoal _goal = NutritionGoal.defaultGoal('');

  // Current week: 7 days from (today - 6) to today
  final List<_DaySnapshot> _weekDays = [];

  // Previous week total kcal for week-over-week comparison
  double _prevWeekTotalKcal = 0;
  bool _hasPrevWeek = false;

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
    final goalSnap = await context.read<GoalService>().getGoal(uid);
    final goal = goalSnap ?? NutritionGoal.defaultGoal(uid);

    try {
      final today = DateTime.now();
      final base = DateTime(today.year, today.month, today.day);

      // --- Current week (today-6 … today) ---
      final weekDays = <_DaySnapshot>[];
      for (var i = 6; i >= 0; i--) {
        final d = base.subtract(Duration(days: i));
        final ds = AppDateUtils.toDateStr(d);
        final entries = await meal.getEntriesForDate(uid, ds);
        final kcal = entries.fold(0.0, (s, e) => s + e.calorieKcal);
        final protein = entries.fold(0.0, (s, e) => s + e.proteinG);
        final carb = entries.fold(0.0, (s, e) => s + e.carbG);
        final fat = entries.fold(0.0, (s, e) => s + e.fatG);
        final waterMl = await water.getWaterMl(uid, ds);
        weekDays.add(_DaySnapshot(
          date: d,
          kcal: kcal,
          proteinG: protein,
          carbG: carb,
          fatG: fat,
          waterMl: waterMl,
        ));
      }

      // --- Previous week (today-13 … today-7) ---
      var prevWeekTotalKcal = 0.0;
      var hasPrevWeek = false;
      for (var i = 13; i >= 7; i--) {
        final d = base.subtract(Duration(days: i));
        final ds = AppDateUtils.toDateStr(d);
        final entries = await meal.getEntriesForDate(uid, ds);
        final kcal = entries.fold(0.0, (s, e) => s + e.calorieKcal);
        if (kcal > 0) hasPrevWeek = true;
        prevWeekTotalKcal += kcal;
      }

      final streak = await CalorieStreak.compute(
        meal: meal,
        uid: uid,
        calorieTarget: goal.calorieTarget,
      );

      if (!mounted) return;
      setState(() {
        _goal = goal;
        _streak = streak;
        _weekDays
          ..clear()
          ..addAll(weekDays);
        _prevWeekTotalKcal = prevWeekTotalKcal;
        _hasPrevWeek = hasPrevWeek;
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

  // ---------------------------------------------------------------------------
  // Computed values
  // ---------------------------------------------------------------------------

  double get _totalKcal =>
      _weekDays.fold(0.0, (s, d) => s + d.kcal);

  double get _avgKcal =>
      _weekDays.isEmpty ? 0 : _totalKcal / _weekDays.length;

  double get _avgProtein =>
      _weekDays.isEmpty
          ? 0
          : _weekDays.fold(0.0, (s, d) => s + d.proteinG) /
              _weekDays.length;

  double get _avgCarb =>
      _weekDays.isEmpty
          ? 0
          : _weekDays.fold(0.0, (s, d) => s + d.carbG) /
              _weekDays.length;

  double get _avgFat =>
      _weekDays.isEmpty
          ? 0
          : _weekDays.fold(0.0, (s, d) => s + d.fatG) /
              _weekDays.length;

  double get _avgWaterMl =>
      _weekDays.isEmpty
          ? 0
          : _weekDays.fold(0.0, (s, d) => s + d.waterMl) /
              _weekDays.length;

  double get _avgWaterL => _avgWaterMl / 1000;

  int get _waterGoalMetDays =>
      _weekDays.where((d) => d.waterMl >= _goal.waterTargetMl).length;

  double get _kcalGoalPercent =>
      _goal.calorieTarget > 0 ? (_avgKcal / _goal.calorieTarget) : 0;

  double get _macroCalTotal =>
      _avgProtein * 4 + _avgCarb * 4 + _avgFat * 9;

  double get _proteinCalFrac =>
      _macroCalTotal > 0 ? (_avgProtein * 4 / _macroCalTotal) : 0;

  double get _carbCalFrac =>
      _macroCalTotal > 0 ? (_avgCarb * 4 / _macroCalTotal) : 0;

  double get _fatCalFrac =>
      _macroCalTotal > 0 ? (_avgFat * 9 / _macroCalTotal) : 0;

  // ---------------------------------------------------------------------------
  // Date range
  // ---------------------------------------------------------------------------

  DateTime get _weekStart => _weekDays.isNotEmpty
      ? _weekDays.first.date
      : DateTime.now().subtract(const Duration(days: 6));

  DateTime get _weekEnd => _weekDays.isNotEmpty
      ? _weekDays.last.date
      : DateTime.now();

  String _dateRangeText() {
    final s = _weekStart;
    final e = _weekEnd;
    final sd = s.day.toString().padLeft(2, '0');
    final sm = s.month.toString().padLeft(2, '0');
    final ed = e.day.toString().padLeft(2, '0');
    final em = e.month.toString().padLeft(2, '0');
    return '${AppDateUtils.shortDayVi(s)}, $sd/$sm  —  '
        '${AppDateUtils.shortDayVi(e)}, $ed/$em';
  }

  // ---------------------------------------------------------------------------
  // Insights
  // ---------------------------------------------------------------------------

  List<_Insight> _generateInsights() {
    final insights = <_Insight>[];

    // 1. Protein below goal
    final proteinPct =
        _goal.proteinG > 0 ? (_avgProtein / _goal.proteinG) : 0;
    if (proteinPct < 0.8 && _avgProtein > 0) {
      insights.add(_Insight(
        icon: Icons.fitness_center,
        color: AppColors.protein,
        text: 'Bạn đang thiếu protein. Thử thêm trứng, thịt gà hoặc '
            'đậu phụ vào bữa ăn.',
      ));
    }

    // 2. Water not met every day
    if (_waterGoalMetDays < 7) {
      insights.add(_Insight(
        icon: Icons.water_drop,
        color: AppColors.water,
        text: 'Bạn uống nước chưa đều. Đặt reminder để uống đủ '
            '${(_goal.waterTargetMl / 1000).toStringAsFixed(1)}L '
            'mỗi ngày.',
      ));
    }

    // 3. Calorie over target
    if (_kcalGoalPercent > 1.1) {
      insights.add(_Insight(
        icon: Icons.trending_up,
        color: AppColors.danger,
        text: 'Calo trung bình đang vượt mục tiêu. Cân nhắc giảm '
            'tinh bột và tăng rau xanh.',
      ));
    } else if (_kcalGoalPercent < 0.7 && _avgKcal > 0) {
      insights.add(_Insight(
        icon: Icons.trending_down,
        color: AppColors.warning,
        text: 'Calo trung bình đang thấp hơn mục tiêu. Đảm bảo '
            'bạn ăn đủ bữa và không bỏ bữa.',
      ));
    }

    // 4. Streak
    if (_streak >= 5) {
      insights.add(_Insight(
        icon: Icons.local_fire_department,
        color: AppColors.streak,
        text: 'Bạn đã duy trì chuỗi $_streak ngày đạt mục tiêu calo. '
            'Tiếp tục phát huy!',
      ));
    }

    // 5. Carb heavy
    final carbPct =
        _goal.carbG > 0 ? (_avgCarb / _goal.carbG) : 0;
    if (carbPct > 1.2 && _kcalGoalPercent < 1.05 && _avgCarb > 0) {
      insights.add(_Insight(
        icon: Icons.grain,
        color: AppColors.carb,
        text: 'Tỉ lệ tinh bột đang cao hơn khuyến nghị. Cân nhắc '
            'tăng protein và rau xanh.',
      ));
    }

    // 6. Fat heavy
    final fatPct = _goal.fatG > 0 ? (_avgFat / _goal.fatG) : 0;
    if (fatPct > 1.3 && _avgFat > 0) {
      insights.add(_Insight(
        icon: Icons.error_outline,
        color: AppColors.fat,
        text: 'Lượng chất béo đang cao. Hạn chế đồ chiên rán, '
            'thức ăn nhanh và chọn chất béo lành mạnh.',
      ));
    }

    // 7. Everything is good
    if (insights.isEmpty) {
      insights.add(_Insight(
        icon: Icons.celebration,
        color: AppColors.success,
        text: 'Bạn đang làm rất tốt! Các chỉ số dinh dưỡng đều '
            'trong mức mục tiêu. Hãy duy trì nhé!',
      ));
    }

    return insights.take(4).toList();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return SNScaffold(
      appBar: SNAppBar(
        title: 'Tổng kết tuần',
        showBackButton: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: AppSpacing.md),
                        _buildCalorieCard(),
                        const SizedBox(height: AppSpacing.md),
                        _buildMacroCard(),
                        const SizedBox(height: AppSpacing.md),
                        _buildWaterCard(),
                        const SizedBox(height: AppSpacing.md),
                        _buildDailyChart(),
                        const SizedBox(height: AppSpacing.md),
                        _buildInsights(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section: Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _dateRangeText(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: Text(
                'Tổng kết tuần',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            if (_streak > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.streak.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department,
                        color: AppColors.streak, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$_streak ngày',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.streak,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section: Calorie Summary
  // ---------------------------------------------------------------------------

  Widget _buildCalorieCard() {
    final avgKcal = _avgKcal.round();
    final targetPercent = (_kcalGoalPercent * 100).round();
    final prevAvgKcal =
        _hasPrevWeek ? (_prevWeekTotalKcal / 7).round() : 0;
    final deltaKcal =
        _hasPrevWeek ? avgKcal - prevAvgKcal : 0;
    final deltaUp = deltaKcal > 0;

    return SNCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Icon(Icons.local_fire_department,
                  color: AppColors.streak, size: 20),
              const SizedBox(width: 8),
              Text(
                'Calo',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Big number
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$avgKcal',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'kcal / ngày',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _kcalGoalPercent.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _kcalGoalPercent > 1.1
                    ? AppColors.danger
                    : _kcalGoalPercent >= 0.85
                        ? AppColors.success
                        : AppColors.warning,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Subtitle row
          Row(
            children: [
              Text(
                'Đạt $targetPercent% mục tiêu (${_goal.calorieTarget} kcal)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _kcalGoalPercent > 1.1
                          ? AppColors.danger
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              if (_hasPrevWeek) ...[
                Icon(
                  deltaUp ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: deltaUp ? AppColors.danger : AppColors.success,
                ),
                const SizedBox(width: 4),
                Text(
                  deltaUp
                      ? '+${deltaKcal.round()} kcal'
                      : '${deltaKcal.round()} kcal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            deltaUp ? AppColors.danger : AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 4),
                Text(
                  'vs tuần trước',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section: Macro Breakdown
  // ---------------------------------------------------------------------------

  Widget _buildMacroCard() {
    final pPct = (_proteinCalFrac * 100).round();
    final cPct = (_carbCalFrac * 100).round();
    final fPct = (_fatCalFrac * 100).round();

    return SNCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(Icons.pie_chart,
                  color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Dinh dưỡng',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Stacked ratio bar
          _buildMacroBar(pFrac: _proteinCalFrac, cFrac: _carbCalFrac, fFrac: _fatCalFrac),
          const SizedBox(height: AppSpacing.sm),

          // Legend
          Row(
            children: [
              _macroLegendDot(AppColors.protein, 'Protein $pPct%'),
              SizedBox(
                  width: _macroCalTotal > 0 ? AppSpacing.md : 0),
              _macroLegendDot(AppColors.carb, 'Carb $cPct%'),
              SizedBox(
                  width: _macroCalTotal > 0 ? AppSpacing.md : 0),
              _macroLegendDot(AppColors.fat, 'Fat $fPct%'),
            ],
          ),

          if (_macroCalTotal > 0) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            _macroGoalRow('Protein', _avgProtein, _goal.proteinG,
                AppColors.protein),
            const SizedBox(height: AppSpacing.sm),
            _macroGoalRow('Carb', _avgCarb, _goal.carbG, AppColors.carb),
            const SizedBox(height: AppSpacing.sm),
            _macroGoalRow('Fat', _avgFat, _goal.fatG, AppColors.fat),
          ],
        ],
      ),
    );
  }

  Widget _buildMacroBar({
    required double pFrac,
    required double cFrac,
    required double fFrac,
  }) {
    final total = pFrac + cFrac + fFrac;
    // Show gray bar when no macros logged
    final hasData = total > 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 12,
        child: hasData
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  return Row(
                    children: [
                      if (pFrac > 0)
                        SizedBox(
                          width: w * pFrac,
                          child: Container(color: AppColors.protein),
                        ),
                      if (cFrac > 0)
                        SizedBox(
                          width: w * cFrac,
                          child: Container(color: AppColors.carb),
                        ),
                      if (fFrac > 0)
                        SizedBox(
                          width: w * fFrac,
                          child: Container(color: AppColors.fat),
                        ),
                    ],
                  );
                },
              )
            : Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
      ),
    );
  }

  Widget _macroLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _macroGoalRow(
      String label, double actual, int goal, Color color) {
    final pct =
        goal > 0 ? '${((actual / goal) * 100).round()}% mục tiêu' : '';
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(label,
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${actual.toStringAsFixed(1)} g',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (pct.isNotEmpty)
              Text(
                pct,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section: Water
  // ---------------------------------------------------------------------------

  Widget _buildWaterCard() {
    final goalL = (_goal.waterTargetMl / 1000);

    return SNCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop, color: AppColors.water, size: 20),
              const SizedBox(width: 8),
              Text(
                'Nước uống',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _avgWaterL.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'L / ngày',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Đạt $_waterGoalMetDays/7 ngày uống đủ nước '
            '(${goalL.toStringAsFixed(1)}L)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _waterGoalMetDays >= 6
                      ? AppColors.success
                      : _waterGoalMetDays >= 4
                          ? AppColors.warning
                          : AppColors.danger,
                ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section: Daily Bar Chart
  // ---------------------------------------------------------------------------

  Widget _buildDailyChart() {
    final target = _goal.calorieTarget.toDouble();
    final maxKcal =
        _weekDays.map((d) => d.kcal).fold(0.0, (a, b) => a > b ? a : b);
    final effectiveMax = maxKcal > target ? maxKcal : target;

    return SNCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart,
                  color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Calo theo ngày',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weekDays.map((day) {
                final ratio =
                    effectiveMax > 0 ? day.kcal / effectiveMax : 0.0;
                final isToday =
                    AppDateUtils.isSameDay(day.date, DateTime.now());
                final overTarget = day.kcal > target && target > 0;
                final colorScheme = Theme.of(context).colorScheme;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (day.kcal > 0)
                          Text(
                            '${day.kcal.round()}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: overTarget
                                  ? AppColors.danger
                                  : colorScheme.onSurface,
                            ),
                          ),
                        const SizedBox(height: 3),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          height: ratio * 86,
                          decoration: BoxDecoration(
                            color: overTarget
                                ? AppColors.danger.withValues(alpha: 0.55)
                                : isToday
                                    ? colorScheme.primary
                                    : colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppDateUtils.shortDayVi(day.date),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isToday
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Legend
          Row(
            children: [
              _barLegendDot(
                  Theme.of(context).colorScheme.primary, 'Hôm nay'),
              const SizedBox(width: 12),
              _barLegendDot(
                  AppColors.danger.withValues(alpha: 0.55),
                  'Vượt mục tiêu'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _barLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section: Insights
  // ---------------------------------------------------------------------------

  Widget _buildInsights() {
    final insights = _generateInsights();

    return SNCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb,
                  color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'Gợi ý cho bạn',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(insights.length, (i) {
            final insight = insights[i];
            final isLast = i == insights.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: insight.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(insight.icon,
                        color: insight.color, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      insight.text,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// =============================================================================
// Private data classes
// =============================================================================

class _DaySnapshot {
  const _DaySnapshot({
    required this.date,
    required this.kcal,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
    required this.waterMl,
  });
  final DateTime date;
  final double kcal;
  final double proteinG;
  final double carbG;
  final double fatG;
  final double waterMl;
}

class _Insight {
  const _Insight({
    required this.icon,
    required this.color,
    required this.text,
  });
  final IconData icon;
  final Color color;
  final String text;
}
