import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';
import 'package:smartnutri/src/core/services/weight_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/core/utils/date_utils.dart';
import 'package:smartnutri/src/core/utils/firestore_write_message.dart';
import 'package:smartnutri/src/features/profile/domain/user_profile.dart';

class WeightTrackerCard extends StatelessWidget {
  const WeightTrackerCard({super.key, required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final uid = profile.uid;
    final today = AppDateUtils.todayStr();
    return SNCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cân nặng',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          StreamBuilder<double?>(
            stream: context.read<WeightService>().watchWeightKg(uid, today),
            builder: (context, snap) {
              final logged = snap.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theo hồ sơ: ${profile.weightKg.toStringAsFixed(1)} kg',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (logged != null)
                    Text(
                      'Đã ghi hôm nay: ${logged.toStringAsFixed(1)} kg',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  _WeightTrendMini(uid: uid),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.tonal(
            onPressed: () => _logWeight(context, profile),
            child: const Text('Cập nhật cân nặng hôm nay'),
          ),
        ],
      ),
    );
  }

  Future<void> _logWeight(BuildContext context, UserProfile profile) async {
    final ctrl =
        TextEditingController(text: profile.weightKg.toStringAsFixed(1));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cân nặng hôm nay'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Cân nặng',
            suffixText: 'kg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    final text = ctrl.text;
    ctrl.dispose();
    if (ok != true || !context.mounted) return;
    final kg = double.tryParse(text.replaceAll(',', '.'));
    if (kg == null || kg <= 0 || kg > 600) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập cân nặng hợp lệ (kg).')),
      );
      return;
    }
    final weightSvc = context.read<WeightService>();
    final profileSvc = context.read<ProfileService>();
    try {
      await weightSvc.setWeightKg(profile.uid, AppDateUtils.todayStr(), kg);
      final updated = UserProfile(
        uid: profile.uid,
        email: profile.email,
        displayName: profile.displayName,
        age: profile.age,
        heightCm: profile.heightCm,
        weightKg: kg,
        gender: profile.gender,
        activityLevel: profile.activityLevel,
        onboardingCompleted: profile.onboardingCompleted,
        updatedAt: DateTime.now(),
      );
      await profileSvc.upsertProfile(updated);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu cân nặng.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(firestoreWriteErrorMessage(e))),
      );
    }
  }
}

class _WeightTrendMini extends StatelessWidget {
  const _WeightTrendMini({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: context.read<WeightService>().getWeightsLastDays(uid: uid, days: 7),
      builder: (context, snap) {
        final data = snap.data ?? const <String, double>{};
        if (data.isEmpty) {
          return Text(
            'Chưa có dữ liệu cân nặng 7 ngày gần đây.',
            style: Theme.of(context).textTheme.bodySmall,
          );
        }
        final now = DateTime.now();
        final base = DateTime(now.year, now.month, now.day);
        final points = <({DateTime d, double? kg})>[];
        for (var i = 6; i >= 0; i--) {
          final d = base.subtract(Duration(days: i));
          final key = AppDateUtils.toDateStr(d);
          points.add((d: d, kg: data[key]));
        }
        final values = points.map((e) => e.kg).whereType<double>().toList();
        final min = values.reduce((a, b) => a < b ? a : b);
        final max = values.reduce((a, b) => a > b ? a : b);
        final range = (max - min).abs() < 0.0001 ? 1.0 : (max - min);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xu hướng 7 ngày', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              height: 72,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final p in points)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (p.kg != null)
                              Text(
                                p.kg!.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 9),
                              ),
                            const SizedBox(height: 2),
                            Container(
                              height: p.kg == null ? 4 : 12 + ((p.kg! - min) / range) * 36,
                              decoration: BoxDecoration(
                                color: p.kg == null
                                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                                    : Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppDateUtils.shortDayVi(p.d),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
