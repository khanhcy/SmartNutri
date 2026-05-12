import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/water_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/core/ui/components/skeleton.dart';

class WaterCard extends StatelessWidget {
  const WaterCard({
    super.key,
    required this.targetMl,
    required this.uid,
    required this.date,
  });

  final double targetMl;
  final String uid;
  final String date;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: context.read<WaterService>().watchWaterMl(uid, date),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonBox(height: 160, width: double.infinity);
        }

        final waterMl = snapshot.data ?? 0.0;
        final progress = targetMl > 0 ? (waterMl / targetMl).clamp(0.0, 1.0) : 0.0;
        final remaining = (targetMl - waterMl).clamp(0.0, targetMl);

        return SNCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.water_drop_rounded, color: AppColors.water),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Nước uống hôm nay',
                      style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${(waterMl / 1000).toStringAsFixed(1)} / ${(targetMl / 1000).toStringAsFixed(1)} L',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.water,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          remaining > 0
                              ? 'Còn thiếu ${(remaining / 1000).toStringAsFixed(1)} L'
                              : 'Tuyệt vời! Đã đủ nước hôm nay.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.water,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.water.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Stack(
                      children: [
                        FractionallySizedBox(
                          widthFactor: value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.water,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  for (final ml in [150.0, 200.0, 250.0, 330.0])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 40),
                            backgroundColor:
                                AppColors.water.withValues(alpha: 0.1),
                            foregroundColor: AppColors.water,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            _addWater(context, ml);
                          },
                          child: Text(
                            ml >= 1000
                                ? '${(ml / 1000).toStringAsFixed(1)}L'
                                : '${ml.round()}ml',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addWater(BuildContext context, double ml) async {
    try {
      await context.read<WaterService>().addWaterMl(uid, date, ml);
    } on FirebaseException catch (e) {
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final message = e.code == 'permission-denied'
          ? 'Không thể cập nhật. Kiểm tra quyền Firestore Rules.'
          : 'Không thể cập nhật lúc này. Vui lòng thử lại.';
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Không thể cập nhật lúc này. Vui lòng thử lại.'),
          ),
        );
    }
  }
}
