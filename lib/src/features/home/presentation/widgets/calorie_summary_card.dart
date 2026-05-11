import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

class CalorieSummaryCard extends StatelessWidget {
  const CalorieSummaryCard({
    super.key,
    required this.consumed,
    required this.goal,
  });

  final double consumed;
  final double goal;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final isOver = consumed > goal;
    final remaining = (goal - consumed).clamp(0.0, goal);

    return SNCard(
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                RepaintBoundary(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    color: isOver ? Colors.red : colorScheme.primary,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${consumed.round()} / ${goal.round()} kcal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isOver ? Colors.red : null,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOver
                      ? 'Đã vượt ${(consumed - goal).round()} kcal'
                      : 'Còn lại ${remaining.round()} kcal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isOver
                            ? Colors.red
                            : colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mục tiêu ngày: ${goal.round()} kcal',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
