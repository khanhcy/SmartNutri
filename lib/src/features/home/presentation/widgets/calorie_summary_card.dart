import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/components/sn_chip.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';
import 'package:smartnutri/src/core/ui/theme/app_radius.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/core/ui/theme/app_text_styles.dart';

class CalorieSummaryCard extends StatefulWidget {
  const CalorieSummaryCard({
    super.key,
    required this.consumed,
    required this.goal,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
  });

  final double consumed;
  final double goal;
  final double proteinG;
  final double carbG;
  final double fatG;

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

  @override
  Widget build(BuildContext context) {
    final progress = widget.goal > 0
        ? (widget.consumed / widget.goal).clamp(0.0, 1.0)
        : 0.0;
    final isOver = widget.consumed > widget.goal;
    final remaining =
        (widget.goal - widget.consumed).clamp(0.0, widget.goal);

    return SNCard(
      variant: SNCardVariant.glow,
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          // Decorative circle top-right
          Positioned(
            right: -70,
            top: -70,
            child: Container(
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mint.withValues(alpha: 0.34),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_fire_department_rounded,
                      size: 20, color: progress >= 0.8
                          ? (isOver ? AppColors.danger : AppColors.warning)
                          : AppColors.fresh),
                  const SizedBox(width: 6),
                  Text(
                    'Tổng quan calo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Donut
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: progress),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return CustomPaint(
                              size: const Size(150, 150),
                              painter: _DonutPainter(
                                progress: value,
                                progressColor:
                                    isOver ? AppColors.danger : AppColors.fresh,
                                trackColor: AppColors.mint.withValues(alpha: 0.42),
                              ),
                            );
                          },
                        ),
                        // White hole
                        Container(
                          width: 106,
                          height: 106,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white, Color(0xFFF8FFF8)],
                            ),
                          ),
                        ),
                        // Center content
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${widget.consumed.round()}',
                              style: AppTextStyles.heroNumber,
                            ),
                            const Text(
                              'kcal',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mục tiêu ${widget.goal.round()} kcal',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.fresh.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            isOver
                                ? 'Vượt ${(widget.consumed - widget.goal).round()} kcal'
                                : 'Còn ${remaining.round()} kcal',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: SnChip.macro(
                                MacroNutrient.protein,
                                'P ${widget.proteinG.round()}g',
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: SnChip.macro(
                                MacroNutrient.carb,
                                'C ${widget.carbG.round()}g',
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: SnChip.macro(
                                MacroNutrient.fat,
                                'F ${widget.fatG.round()}g',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
  });

  final double progress;
  final Color progressColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background track
    final trackPaint = Paint()..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final p = progress.clamp(0.0, 1.0);
    if (p > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * p,
        true,
        progressPaint,
      );
    }

    // Inset shadow ring (white overlay at edge)
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center, radius - 5, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}
