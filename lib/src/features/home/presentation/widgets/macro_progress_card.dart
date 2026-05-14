import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';
import 'package:smartnutri/src/core/ui/theme/app_radius.dart';
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
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dinh dưỡng chính',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text(
                'Mục tiêu',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _MacroBar(
            label: 'Protein',
            consumed: proteinConsumed,
            goal: proteinGoal,
            color: AppColors.protein,
          ),
          const SizedBox(height: 11),
          _MacroBar(
            label: 'Carbs',
            consumed: carbConsumed,
            goal: carbGoal,
            color: AppColors.carb,
          ),
          const SizedBox(height: 11),
          _MacroBar(
            label: 'Chất béo',
            consumed: fatConsumed,
            goal: fatGoal,
            color: AppColors.fat,
          ),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
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

    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: ratio),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Container(
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0x12102A16),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 42,
          child: Text(
            '${consumed.round()}g',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.muted,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
