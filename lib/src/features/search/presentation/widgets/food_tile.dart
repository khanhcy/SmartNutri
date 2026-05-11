import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/services/recent_foods_service.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/search/domain/food_item.dart';

import 'food_detail_sheet.dart';

class FoodTile extends StatelessWidget {
  const FoodTile({super.key, required this.food});
  final FoodItem food;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs, horizontal: AppSpacing.sm),
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(Icons.restaurant_outlined,
            color: colorScheme.primary, size: 20),
      ),
      title: Text(food.name),
      subtitle: Text(
        '${food.calorieKcal.round()} kcal / 100g  •  '
        'P:${food.proteinG.round()}g  '
        'C:${food.carbG.round()}g  '
        'F:${food.fatG.round()}g',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: IconButton(
        onPressed: () => _showDetailSheet(context),
        icon: Icon(Icons.add_circle_outline, color: colorScheme.primary),
        tooltip: 'Thêm vào nhật ký',
      ),
      onTap: () => _showDetailSheet(context),
    );
  }

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FoodDetailSheet(
        food: food,
        authService: context.read<AuthService>(),
        mealService: context.read<MealService>(),
        recentFoods: context.read<RecentFoodsService>(),
      ),
    );
  }
}
