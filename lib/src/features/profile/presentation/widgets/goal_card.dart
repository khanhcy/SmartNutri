import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/nutrition/domain/nutrition_goal.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal, required this.uid});
  final NutritionGoal goal;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return SNCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Mục tiêu dinh dưỡng',
                  style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              Icon(Icons.flag_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _GoalRow(label: 'Calo / ngày', value: '${goal.calorieTarget} kcal',
              icon: Icons.local_fire_department_outlined),
          const Divider(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MiniGoal(label: 'Protein', value: '${goal.proteinG}g',
                    color: Colors.blue),
              ),
              Expanded(
                child: _MiniGoal(label: 'Carb', value: '${goal.carbG}g',
                    color: Colors.orange),
              ),
              Expanded(
                child: _MiniGoal(label: 'Fat', value: '${goal.fatG}g',
                    color: Colors.pink),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _MiniGoal extends StatelessWidget {
  const _MiniGoal({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
