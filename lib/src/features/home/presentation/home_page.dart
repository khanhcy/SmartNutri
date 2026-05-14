import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/app/go_router_config.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/favorites_service.dart';
import 'package:smartnutri/src/core/services/goal_service.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';
import 'package:smartnutri/src/core/services/water_service.dart';
import 'package:smartnutri/src/core/ui/components/staggered_entrance.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';
import 'package:smartnutri/src/core/ui/theme/app_radius.dart';
import 'package:smartnutri/src/core/ui/theme/app_shadows.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/core/ui/theme/app_text_styles.dart';
import 'package:smartnutri/src/core/utils/date_utils.dart';
import 'package:smartnutri/src/features/home/presentation/macro_trend_card.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';
import 'package:smartnutri/src/features/meal_log/presentation/add_meal_bottom_sheet.dart';
import 'package:smartnutri/src/features/nutrition/domain/nutrition_goal.dart';
import 'package:smartnutri/src/features/profile/domain/user_profile.dart';

import 'widgets/water_card.dart';
import 'widgets/streak_badge.dart';
import 'widgets/calorie_summary_card.dart';
import 'widgets/macro_progress_card.dart';
import 'widgets/today_meals_section.dart';
import 'widgets/ai_suggestions_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/quick_add_favorites.dart';
import 'widgets/quick_add_recents.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthService>().currentUser!.uid;
    context.read<FavoriteFoodsService>().init(uid);
    final today = AppDateUtils.todayStr();

    return MultiProvider(
      providers: [
        StreamProvider<UserProfile?>(
          create: (context) => context.read<ProfileService>().watchProfile(uid),
          initialData: null,
        ),
        StreamProvider<NutritionGoal?>(
          create: (context) => context.read<GoalService>().watchGoal(uid),
          initialData: null,
        ),
        StreamProvider<List<MealEntry>>(
          create: (context) =>
              context.read<MealService>().watchEntriesForDate(uid, today),
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
    final greeting = _greetingText(displayName);
    final initials = _initials(displayName);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.warm, AppColors.bg, Color(0xFFF8FFF9)],
          stops: [0.0, 0.38, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            22,
            AppSpacing.screenHorizontal,
            108,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  // Greeting header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tổng quan hôm nay',
                              style: AppTextStyles.kicker,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              greeting,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    decoration: TextDecoration.none,
                                    height: 1.14,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Theo dõi dinh dưỡng của bạn hôm nay',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFE5F7E8), Colors.white],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: AppShadows.card,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  StaggeredEntrance(
                    children: [
                      CalorieSummaryCard(
                        consumed: consumed,
                        goal: goal.calorieTarget.toDouble(),
                        proteinG: proteinConsumed,
                        carbG: carbConsumed,
                        fatG: fatConsumed,
                      ),
                      QuickActions(
                        onAddMeal: () => showAddMealSheet(
                          context,
                          initialMealType: _mealTypeForNow(),
                        ),
                        onScanAI: () =>
                            context.push(AppPaths.scanPhoto),
                        onAddWater: () => _quickAddWater(context),
                      ),
                      StreakBadge(
                        uid: uid,
                        calorieTarget: goal.calorieTarget,
                        refreshToken: entries.length + consumed.round(),
                      ),
                      WaterCard(
                        uid: uid,
                        date: today,
                        targetMl: goal.waterTargetMl,
                      ),
                      MacroProgressCard(
                        proteinConsumed: proteinConsumed,
                        carbConsumed: carbConsumed,
                        fatConsumed: fatConsumed,
                        proteinGoal: goal.proteinG.toDouble(),
                        carbGoal: goal.carbG.toDouble(),
                        fatGoal: goal.fatG.toDouble(),
                      ),
                      AiSuggestionsCard(
                        remainingKcal: goal.calorieTarget - consumed,
                        proteinG: goal.proteinG - proteinConsumed,
                        carbG: goal.carbG - carbConsumed,
                        fatG: goal.fatG - fatConsumed,
                      ),
                      TodayMealsSection(
                        entries: entries,
                        uid: uid,
                        onAddFirstMeal: () => showAddMealSheet(
                          context,
                          initialMealType: _mealTypeForNow(),
                        ),
                      ),
                      const MacroTrendCard(),
                      const QuickAddRecents(),
                      const QuickAddFavorites(),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _quickAddWater(BuildContext context) {
    context.read<WaterService>().addWaterMl(uid, today, 250);
  }

  String _greetingText(String? displayName) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Chào buổi sáng'
        : hour < 18
            ? 'Chào buổi chiều'
            : 'Chào buổi tối';
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return '$greeting, $name';
    }
    return greeting;
  }

  String _initials(String? displayName) {
    final name = displayName?.trim();
    if (name == null || name.isEmpty) return 'SN';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  MealType _mealTypeForNow() {
    final h = DateTime.now().hour;
    if (h < 10) return MealType.breakfast;
    if (h < 14) return MealType.lunch;
    if (h < 19) return MealType.dinner;
    return MealType.snack;
  }
}
