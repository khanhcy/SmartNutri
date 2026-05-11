import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/water_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
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
          return const SkeletonBox(height: 140, width: double.infinity);
        }

        final waterMl = snapshot.data ?? 0.0;
        final colorScheme = Theme.of(context).colorScheme;
        final progress = targetMl > 0 ? (waterMl / targetMl).clamp(0.0, 1.0) : 0.0;
        final remaining = (targetMl - waterMl).clamp(0.0, targetMl);

        return SNCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.water_drop_outlined, color: Colors.blue.shade400),
                  const SizedBox(width: 8),
                  Text('Nước uống hôm nay',
                      style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${(waterMl / 1000).toStringAsFixed(1)} / ${(targetMl / 1000).toStringAsFixed(1)} L',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade600,
                              ),
                        ),
                        Text(
                          remaining > 0
                              ? 'Còn thiếu ${(remaining / 1000).toStringAsFixed(1)} L'
                              : 'Đã đủ nước hôm nay!',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                value: progress,
                color: Colors.blue.shade400,
                backgroundColor: Colors.blue.shade50,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  for (final ml in [150.0, 200.0, 250.0, 330.0])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 36),
                            side: BorderSide(color: colorScheme.outline),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            _addWater(context, ml);
                          },
                          child: Text(
                            ml >= 1000
                                ? '${(ml / 1000).toStringAsFixed(1)}L'
                                : '${ml.round()}ml',
                            style: const TextStyle(fontSize: 12),
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
          ? 'Không thể cập nhật nước uống. Kiểm tra quyền Firestore Rules.'
          : 'Không thể cập nhật nước uống lúc này. Vui lòng thử lại.';
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Không thể cập nhật nước uống lúc này. Vui lòng thử lại.'),
          ),
        );
    }
  }
}
