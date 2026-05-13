import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/favorites_service.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/meal_log/presentation/add_meal_bottom_sheet.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';

class QuickAddFavorites extends StatelessWidget {
  const QuickAddFavorites({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoriteFoodsService>().favorites;

    if (favs.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    MealType mealTypeForNow() {
      final h = DateTime.now().hour;
      if (h < 10) return MealType.breakfast;
      if (h < 14) return MealType.lunch;
      if (h < 19) return MealType.dinner;
      return MealType.snack;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.favorite, size: 18, color: Colors.red),
            const SizedBox(width: 6),
            Text(
              'Món yêu thích',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: favs.map((food) {
            return ActionChip(
              avatar: Icon(
                Icons.restaurant,
                size: 14,
                color: colorScheme.primary,
              ),
              label: Text(
                food.name,
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: () => showAddMealSheet(
                context,
                preselectedFood: food,
                initialMealType: mealTypeForNow(),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
