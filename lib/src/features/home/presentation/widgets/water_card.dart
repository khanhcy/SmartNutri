import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/water_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';
import 'package:smartnutri/src/core/ui/theme/app_radius.dart';
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
          return const SkeletonBox(height: 200, width: double.infinity);
        }

        final waterMl = snapshot.data ?? 0.0;
        final progress = targetMl > 0 ? (waterMl / targetMl).clamp(0.0, 1.0) : 0.0;
        final remaining = (targetMl - waterMl).clamp(0.0, targetMl);

        return SNCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nước uống',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${(waterMl / 1000).toStringAsFixed(1)}L',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                remaining > 0
                    ? 'Còn ${(remaining / 1000).toStringAsFixed(1)}L để đạt mục tiêu nước hôm nay.'
                    : 'Tuyệt vời! Đã đủ nước hôm nay.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              // Progress bar
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: Container(
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
                                gradient: const LinearGradient(
                                  colors: [AppColors.water, Color(0xFF79D3F3)],
                                ),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${targetMl.round() / 1000}L',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              // Quick water buttons
              Row(
                children: [
                  for (final ml in [150.0, 200.0, 250.0, 330.0])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _addWater(context, ml);
                            },
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: Container(
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                '${ml.round()}ml',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
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
