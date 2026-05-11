import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

class MacroProgressCard extends StatelessWidget {
  const MacroProgressCard({
    super.key,
    required this.proteinConsumed,
    required this.carbConsumed,
    required this.fatConsumed,
    required this.proteinGoal,
    required this.carbGoal,
    required this.fatGoal,
  });

  final double proteinConsumed;
  final double carbConsumed;
  final double fatConsumed;
  final double proteinGoal;
  final double carbGoal;
  final double fatGoal;

  @override
  Widget build(BuildContext context) {
    return SNCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dinh dưỡng đa lượng',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          _MacroRow(
            label: 'Protein',
            consumed: proteinConsumed,
            goal: proteinGoal,
            color: AppColors.protein,
          ),
          const SizedBox(height: AppSpacing.md),
          _MacroRow(
            label: 'Carb',
            consumed: carbConsumed,
            goal: carbGoal,
            color: AppColors.carb,
          ),
          const SizedBox(height: AppSpacing.md),
          _MacroRow(
            label: 'Fat',
            consumed: fatConsumed,
            goal: fatGoal,
            color: AppColors.fat,
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.label,
    required this.consumed,
    required this.goal,
    required this.color,
  });

  final String label;
  final double consumed;
  final double goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    
    return RepaintBoundary(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ),
              Text(
                '${consumed.toStringAsFixed(1)}g / ${goal.round()}g',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: ratio),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
