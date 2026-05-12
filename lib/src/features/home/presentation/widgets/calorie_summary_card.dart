import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

class CalorieSummaryCard extends StatefulWidget {
  const CalorieSummaryCard({
    super.key,
    required this.consumed,
    required this.goal,
  });

  final double consumed;
  final double goal;

  @override
  State<CalorieSummaryCard> createState() => _CalorieSummaryCardState();
}

class _CalorieSummaryCardState extends State<CalorieSummaryCard> {
  bool _hapticTriggered = false;

  @override
  void didUpdateWidget(covariant CalorieSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.consumed != widget.consumed ||
        oldWidget.goal != widget.goal) {
      _checkHaptic();
    }
  }

  void _checkHaptic() {
    if (widget.goal <= 0) return;
    final overGoal = widget.consumed >= widget.goal;
    if (overGoal && !_hapticTriggered) {
      _hapticTriggered = true;
      HapticFeedback.heavyImpact();
    } else if (!overGoal) {
      _hapticTriggered = false;
    }
  }

  Color _progressColor(double progress, ColorScheme cs) {
    if (progress >= 1.0) return Colors.red;
    if (progress >= 0.8) return Colors.orange;
    return cs.primary;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = widget.goal > 0
        ? (widget.consumed / widget.goal).clamp(0.0, 1.0)
        : 0.0;
    final isOver = widget.consumed > widget.goal;
    final remaining =
        (widget.goal - widget.consumed).clamp(0.0, widget.goal);
    final ringColor = _progressColor(progress, colorScheme);

    return SNCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng quan calo',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Icon(Icons.local_fire_department_outlined,
                  color: ringColor),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return SizedBox(
                        width: 180,
                        height: 180,
                        child: CustomPaint(
                          painter: _DonutPainter(
                            progress: value,
                            isOver: value >= 1.0,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            progressColor: _progressColor(
                                value, colorScheme),
                            strokeWidth: 16,
                          ),
                        ),
                      );
                    },
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.consumed.round()}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: ringColor,
                              height: 1.1,
                            ),
                      ),
                      Text(
                        'kcal nạp',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Mục tiêu',
                value: '${widget.goal.round()}',
                unit: 'kcal',
              ),
              Container(
                width: 1,
                height: 30,
                color:
                    colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              _StatItem(
                label: isOver ? 'Đã vượt' : 'Còn lại',
                value: isOver
                    ? '${(widget.consumed - widget.goal).round()}'
                    : '${remaining.round()}',
                unit: 'kcal',
                valueColor: isOver ? Colors.red : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
    this.valueColor,
  });

  final String label;
  final String value;
  final String unit;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.progress,
    required this.isOver,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final bool isOver;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isOver != isOver ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
