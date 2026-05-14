import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/favorites_service.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';
import 'package:smartnutri/src/core/ui/theme/app_radius.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/meal_log/presentation/add_meal_bottom_sheet.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';

class QuickAddFavorites extends StatelessWidget {
  const QuickAddFavorites({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoriteFoodsService>().favorites;

    if (favs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            const Icon(Icons.favorite, size: 18, color: AppColors.danger),
            const SizedBox(width: 6),
            Text(
              'Món yêu thích',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: favs.map((food) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => showAddMealSheet(
                  context,
                  preselectedFood: food,
                  initialMealType: _mealTypeForNow(),
                ),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.restaurant, size: 14, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Text(
                        food.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF8A5B00),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  MealType _mealTypeForNow() {
    final h = DateTime.now().hour;
    if (h < 10) return MealType.breakfast;
    if (h < 14) return MealType.lunch;
    if (h < 19) return MealType.dinner;
    return MealType.snack;
  }
}
