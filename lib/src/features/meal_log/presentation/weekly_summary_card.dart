import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/core/utils/date_utils.dart';
import 'package:smartnutri/src/features/nutrition/domain/nutrition_goal.dart';

class WeeklySummaryCard extends StatefulWidget {
  const WeeklySummaryCard({super.key, required this.goal});
  final NutritionGoal goal;

  @override
  State<WeeklySummaryCard> createState() => _WeeklySummaryCardState();
}

class _WeeklySummaryCardState extends State<WeeklySummaryCard> {
  List<_DayCalorie> _days = [];
  bool _loading = true;
  bool _tickerWasActive = false;

  @override
  void initState() {
    super.initState();
    _loadWeek();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tickerActive = TickerMode.valuesOf(context).enabled;
    if (tickerActive && !_tickerWasActive && !_loading) {
      _loadWeek();
    }
    _tickerWasActive = tickerActive;
  }

  Future<void> _loadWeek() async {
    if (!_loading) setState(() => _loading = true);
    final uid = context.read<AuthService>().currentUser!.uid;
    final service = context.read<MealService>();
    final today = DateTime.now();
    final results = <_DayCalorie>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final entries = await service.getEntriesForDate(uid, AppDateUtils.toDateStr(date));
      final total = entries.fold(0.0, (s, e) => s + e.calorieKcal);
      results.add(_DayCalorie(date: date, kcal: total));
    }

    if (mounted) {
      setState(() {
        _days = results;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SNCard(
        child: SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final maxKcal = _days.map((d) => d.kcal).fold(0.0, (a, b) => a > b ? a : b);
    final target = widget.goal.calorieTarget.toDouble();
    final effectiveMax = maxKcal > target ? maxKcal : target;
    final totalWeek = _days.fold(0.0, (s, d) => s + d.kcal);
    final avgDay = totalWeek / 7;

    return SNCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart,
                  color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('Tổng kết 7 ngày',
                  style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              Text(
                'TB: ${avgDay.round()} kcal/ngày',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 4),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _loading ? null : _loadWeek,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.refresh,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _days.map((day) {
                final ratio = effectiveMax > 0 ? day.kcal / effectiveMax : 0.0;
                final isToday = _isSameDay(day.date, DateTime.now());
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
                              fontSize: 8,
                              color: overTarget
                                  ? Colors.red
                                  : colorScheme.onSurface,
                            ),
                          ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          height: ratio * 72,
                          decoration: BoxDecoration(
                            color: overTarget
                                ? Colors.red.shade300
                                : isToday
                                    ? colorScheme.primary
                                    : colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _shortDay(day.date),
                          style: TextStyle(
                            fontSize: 10,
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
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              Text('Hôm nay', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 12),
              Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: Colors.red.shade300,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              Text('Vượt mục tiêu',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => AppDateUtils.isSameDay(a, b);
  String _shortDay(DateTime d) => AppDateUtils.shortDayVi(d);
}

class _DayCalorie {
  const _DayCalorie({required this.date, required this.kcal});
  final DateTime date;
  final double kcal;
}
