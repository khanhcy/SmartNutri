import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/goal_service.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';
import 'package:smartnutri/src/core/ui/layout/page_template.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/core/utils/date_utils.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';
import 'package:smartnutri/src/features/meal_log/presentation/add_meal_bottom_sheet.dart';
import 'package:smartnutri/src/features/meal_log/presentation/custom_meal_sheet.dart';
import 'package:smartnutri/src/features/meal_log/presentation/weekly_summary_card.dart';
import 'package:smartnutri/src/features/nutrition/domain/nutrition_goal.dart';
import 'package:smartnutri/src/features/profile/domain/user_profile.dart';

import 'widgets/copy_meal_sheet.dart';
import 'widgets/date_navigator.dart';
import 'widgets/empty_day.dart';
import 'widgets/meal_groups.dart';
import 'widgets/meal_summary_card.dart';

class MealLogPage extends StatefulWidget {
  const MealLogPage({super.key});

  @override
  State<MealLogPage> createState() => _MealLogPageState();
}

class _MealLogPageState extends State<MealLogPage> {
  DateTime _selectedDate = DateTime.now();

  MealType _suggestMealTypeForSelectedDay() {
    final now = DateTime.now();
    if (!AppDateUtils.isSameDay(_selectedDate, now)) {
      return MealType.lunch;
    }
    final hour = now.hour;
    if (hour < 10) return MealType.breakfast;
    if (hour < 14) return MealType.lunch;
    if (hour < 19) return MealType.dinner;
    return MealType.snack;
  }

  String get _dateStr => AppDateUtils.toDateStr(_selectedDate);

  String get _displayDate {
    final now = DateTime.now();
    final d = _selectedDate;
    if (AppDateUtils.isSameDay(d, now)) return 'Hôm nay';
    if (AppDateUtils.isSameDay(d, now.subtract(const Duration(days: 1)))) return 'Hôm qua';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthService>().currentUser!.uid;

    return MultiProvider(
      providers: [
        StreamProvider<UserProfile?>(
          create: (_) => context.read<ProfileService>().watchProfile(uid),
          initialData: null,
        ),
        StreamProvider<NutritionGoal?>(
          create: (_) => context.read<GoalService>().watchGoal(uid),
          initialData: null,
        ),
        StreamProvider<List<MealEntry>>(
          key: ValueKey(_dateStr),
          create: (_) => context.read<MealService>().watchEntriesForDate(uid, _dateStr),
          initialData: const [],
        ),
      ],
      child: Builder(
        builder: (context) {
          final profile = context.watch<UserProfile?>();
          final storedGoal = context.watch<NutritionGoal?>();
          final goal = NutritionGoal.resolveForDisplay(
            uid: uid,
            storedGoal: storedGoal,
            weightKg: profile?.weightKg,
            heightCm: profile?.heightCm,
            age: profile?.age,
            gender: profile?.gender,
            activityLevel: profile?.activityLevel,
          );
          final entries = context.watch<List<MealEntry>>();

          final totalKcal = entries.fold(0.0, (s, e) => s + e.calorieKcal);
          final remaining = (goal.calorieTarget - totalKcal).clamp(0.0, double.infinity);

          return PageTemplate(
            title: 'Nhật ký bữa ăn',
            subtitle: 'Ghi lại các bữa ăn trong ngày.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DateNavigator(
                  label: _displayDate,
                  onPrevious: () => setState(() => _selectedDate =
                      _selectedDate.subtract(const Duration(days: 1))),
                  onNext: AppDateUtils.isSameDay(_selectedDate, DateTime.now())
                      ? null
                      : () => setState(() => _selectedDate =
                          _selectedDate.add(const Duration(days: 1))),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: MealSummaryCard(
                        label: 'Tổng calo',
                        value: '${totalKcal.round()} kcal',
                        sub: 'Mục tiêu ${goal.calorieTarget} kcal',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: MealSummaryCard(
                        label: 'Còn lại',
                        value: '${remaining.round()} kcal',
                        sub: '${entries.length} bữa đã ghi',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (entries.isEmpty)
                  EmptyDay(date: _displayDate)
                else
                  MealGroups(entries: entries, uid: uid),
                const SizedBox(height: AppSpacing.md),
                WeeklySummaryCard(goal: goal),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => showAddMealSheet(
                          context,
                          initialMealType: _suggestMealTypeForSelectedDay(),
                          logDate: _selectedDate,
                        ),
                        icon: const Icon(Icons.search),
                        label: const Text('Tìm món'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => showCustomMealSheet(
                          context,
                          initialMealType: _suggestMealTypeForSelectedDay(),
                          logDate: _selectedDate,
                        ),
                        icon: const Icon(Icons.edit_note),
                        label: const Text('Nhập thủ công'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => showCopyMealSheet(
                          context,
                          uid: uid,
                          targetDate: _dateStr,
                        ),
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Sao chép'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}
