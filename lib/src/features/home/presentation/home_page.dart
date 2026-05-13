import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/favorites_service.dart';
import 'package:smartnutri/src/core/services/goal_service.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';
import 'package:smartnutri/src/core/ui/layout/page_template.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/core/ui/components/staggered_entrance.dart';
import 'package:smartnutri/src/core/utils/date_utils.dart';
import 'package:smartnutri/src/features/home/presentation/macro_trend_card.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';
import 'package:smartnutri/src/features/profile/domain/user_profile.dart';
import 'package:smartnutri/src/features/meal_log/presentation/add_meal_bottom_sheet.dart';
import 'package:smartnutri/src/features/meal_log/presentation/custom_meal_sheet.dart';
import 'package:smartnutri/src/features/nutrition/domain/nutrition_goal.dart';

import 'widgets/water_card.dart';
import 'widgets/streak_badge.dart';
import 'widgets/calorie_summary_card.dart';
import 'widgets/macro_progress_card.dart';
import 'widgets/today_meals_section.dart';
import 'widgets/ai_suggestions_card.dart';
import 'widgets/quick_add_favorites.dart';
import 'widgets/quick_add_recents.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthService>().currentUser!.uid;
    context.read<FavoriteFoodsService>().init(uid);
    final today = AppDateUtils.todayStr();

    // Thay vì lồng 4 StreamBuilder (Pyramid of Doom), ta dùng MultiProvider
    return MultiProvider(
      providers: [
        StreamProvider<UserProfile?>(
          create: (context) => context.read<ProfileService>().watchProfile(uid),
          initialData: null,
        ),
        StreamProvider<NutritionGoal?>(
          create: (context) => context.read<GoalService>().watchGoal(uid),
          initialData: null, // Sẽ fallback về default trong _HomePageContent
        ),
        StreamProvider<List<MealEntry>>(
          create: (context) => context.read<MealService>().watchEntriesForDate(uid, today),
          initialData: const [],
        ),
      ],
      child: _HomePageContent(uid: uid, today: today),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  const _HomePageContent({required this.uid, required this.today});

  final String uid;
  final String today;

  @override
  Widget build(BuildContext context) {
    // Các Widget con bên trong chỉ cần dùng context.watch() 
    // Data thay đổi ở Provider nào thì chỉ ảnh hưởng phần liên quan.
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

    final displayName = profile?.displayName;
    final consumed = entries.fold(0.0, (s, e) => s + e.calorieKcal);
    final proteinConsumed = entries.fold(0.0, (s, e) => s + e.proteinG);
    final carbConsumed = entries.fold(0.0, (s, e) => s + e.carbG);
    final fatConsumed = entries.fold(0.0, (s, e) => s + e.fatG);

    return PageTemplate(
      title: 'Tổng quan hôm nay',
      subtitle: homeGreetingSubtitle(displayName),
      child: StaggeredEntrance(
        children: [
          CalorieSummaryCard(
            consumed: consumed,
            goal: goal.calorieTarget.toDouble(),
          ),
          const SizedBox(height: AppSpacing.sm),
          StreakBadge(
            uid: uid,
            calorieTarget: goal.calorieTarget,
            refreshToken: entries.length + consumed.round(),
          ),
          const SizedBox(height: AppSpacing.md),
          WaterCard(
            uid: uid,
            date: today,
            targetMl: goal.waterTargetMl,
          ),
          const SizedBox(height: AppSpacing.md),
          MacroProgressCard(
            proteinConsumed: proteinConsumed,
            carbConsumed: carbConsumed,
            fatConsumed: fatConsumed,
            proteinGoal: goal.proteinG.toDouble(),
            carbGoal: goal.carbG.toDouble(),
            fatGoal: goal.fatG.toDouble(),
          ),
          const SizedBox(height: AppSpacing.md),
          const RepaintBoundary(child: MacroTrendCard()),
          const SizedBox(height: AppSpacing.md),
          AiSuggestionsCard(
            remainingKcal: goal.calorieTarget - consumed,
            proteinG: goal.proteinG - proteinConsumed,
            carbG: goal.carbG - carbConsumed,
            fatG: goal.fatG - fatConsumed,
          ),
          const SizedBox(height: AppSpacing.md),
          TodayMealsSection(entries: entries, uid: uid),
          const SizedBox(height: AppSpacing.md),
          const QuickAddRecents(),
          const SizedBox(height: AppSpacing.md),
          const QuickAddFavorites(),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => showAddMealSheet(
                    context,
                    initialMealType: mealTypeForNow(),
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
                    initialMealType: mealTypeForNow(),
                  ),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Nhập thủ công'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String homeGreetingSubtitle(String? displayName) {
  final hour = DateTime.now().hour;
  final greeting = hour < 12
      ? 'Chào buổi sáng'
      : hour < 18
          ? 'Chào buổi chiều'
          : 'Chào buổi tối';
  final name = displayName?.trim();
  final first =
      (name != null && name.isNotEmpty) ? name.split(RegExp(r'\s+')).first : null;
  if (first != null && first.isNotEmpty) {
    return '$greeting, $first! Theo dõi dinh dưỡng của bạn hôm nay.';
  }
  return '$greeting! Theo dõi dinh dưỡng của bạn hôm nay.';
}

