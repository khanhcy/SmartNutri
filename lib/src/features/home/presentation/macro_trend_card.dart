import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';
import 'package:smartnutri/src/core/ui/theme/app_radius.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/core/utils/date_utils.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';

class MacroTrendCard extends StatefulWidget {
  const MacroTrendCard({super.key});

  @override
  State<MacroTrendCard> createState() => _MacroTrendCardState();
}

class _MacroTrendCardState extends State<MacroTrendCard> {
  List<_DayMacro> _days = [];
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
    if (_loading == false) setState(() => _loading = true);
    final uid = context.read<AuthService>().currentUser!.uid;
    final service = context.read<MealService>();
    final today = DateTime.now();
    final results = <_DayMacro>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final entries =
          await service.getEntriesForDate(uid, AppDateUtils.toDateStr(date));
      results.add(_DayMacro.fromEntries(date, entries));
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
          height: 140,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final maxTotal = _days
        .map((d) => d.proteinG + d.carbG + d.fatG)
        .fold(0.0, (a, b) => a > b ? a : b);

    return SNCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stacked_bar_chart, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Macro 7 ngày',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: _loading ? null : _loadWeek,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.refresh, size: 16, color: AppColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _days.map((day) {
                final total = day.proteinG + day.carbG + day.fatG;
                final ratio = maxTotal > 0 ? total / maxTotal : 0.0;
                final barH = ratio * 84;
                final isToday = _isSameDay(day.date, DateTime.now());

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeOut,
                          height: barH,
                          child: barH < 2
                              ? const SizedBox.shrink()
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Column(
                                    children: [
                                      if (day.fatG > 0)
                                        Flexible(
                                          flex: day.fatG.round(),
                                          child: Container(color: AppColors.fat),
                                        ),
                                      if (day.carbG > 0)
                                        Flexible(
                                          flex: day.carbG.round(),
                                          child: Container(color: AppColors.carb),
                                        ),
                                      if (day.proteinG > 0)
                                        Flexible(
                                          flex: day.proteinG.round(),
                                          child:
                                              Container(color: AppColors.protein),
                                        ),
                                    ],
                                  ),
                                ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _shortDay(day.date),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                            color:
                                isToday ? AppColors.primary : AppColors.muted,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: AppColors.protein, label: 'Protein'),
              const SizedBox(width: AppSpacing.md),
              _Legend(color: AppColors.carb, label: 'Carb'),
              const SizedBox(width: AppSpacing.md),
              _Legend(color: AppColors.fat, label: 'Fat'),
            ],
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => AppDateUtils.isSameDay(a, b);
  String _shortDay(DateTime d) => AppDateUtils.shortDayVi(d);
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
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
}

class _DayMacro {
  const _DayMacro({
    required this.date,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
  });

  factory _DayMacro.fromEntries(DateTime date, List<MealEntry> entries) {
    return _DayMacro(
      date: date,
      proteinG: entries.fold(0.0, (s, e) => s + e.proteinG),
      carbG: entries.fold(0.0, (s, e) => s + e.carbG),
      fatG: entries.fold(0.0, (s, e) => s + e.fatG),
    );
  }

  final DateTime date;
  final double proteinG;
  final double carbG;
  final double fatG;
}
