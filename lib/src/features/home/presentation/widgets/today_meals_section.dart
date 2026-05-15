import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/core/utils/date_utils.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';
import 'package:smartnutri/src/features/meal_log/presentation/widgets/copy_meal_sheet.dart';

class TodayMealsSection extends StatelessWidget {
  const TodayMealsSection({super.key, required this.entries, required this.uid});

  final List<MealEntry> entries;
  final String uid;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return SNCard(
        child: Column(
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Chưa có bữa ăn nào hôm nay',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Nhấn "Tìm món" hoặc "Nhập thủ công" để bắt đầu ghi nhật ký.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: OutlinedButton.icon(
                onPressed: () => showCopyMealSheet(
                  context,
                  uid: uid,
                  targetDate: AppDateUtils.todayStr(),
                ),
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Sao chép bữa ăn'),
              ),
            ),
          ],
        ),
      );
    }

    final grouped = <MealType, List<MealEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.mealType, () => []).add(entry);
    }

    return SNCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bữa ăn hôm nay',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final type in MealType.values)
            if (grouped.containsKey(type)) ...[
              _MealTypeHeader(type: type, entries: grouped[type]!),
              ...grouped[type]!.map(
                (e) => _EntryTile(entry: e, uid: uid),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: OutlinedButton.icon(
                onPressed: () => showCopyMealSheet(
                  context,
                  uid: uid,
                  targetDate: AppDateUtils.todayStr(),
                ),
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Sao chép bữa ăn'),
              ),
            ),
        ],
      ),
    );
  }
}

class _MealTypeHeader extends StatelessWidget {
  const _MealTypeHeader({required this.type, required this.entries});
  final MealType type;
  final List<MealEntry> entries;

  @override
  Widget build(BuildContext context) {
    final totalKcal = entries.fold(0.0, (s, e) => s + e.calorieKcal);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 2),
      child: Row(
        children: [
          Icon(type.icon, size: 16,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(type.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const Spacer(),
          Text('${totalKcal.round()} kcal',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.uid});
  final MealEntry entry;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        color: Colors.red,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final mealService = context.read<MealService>();
        try {
          await mealService.deleteEntry(uid, entry.id);
          if (!context.mounted) return true;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text("Đã xóa '${entry.foodName}'"),
                action: SnackBarAction(
                  label: 'Hoàn tác',
                  onPressed: () {
                    mealService.addEntry(uid, entry);
                  },
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          return true;
        } on FirebaseException catch (e) {
          if (!context.mounted) return false;
          final messenger = ScaffoldMessenger.of(context);
          final message = e.code == 'permission-denied'
              ? 'Không thể xóa món. Kiểm tra quyền Firestore Rules.'
              : 'Không thể xóa món lúc này. Vui lòng thử lại.';
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
          return false;
        } catch (_) {
          if (!context.mounted) return false;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Không thể xóa món lúc này. Vui lòng thử lại.'),
              ),
            );
          return false;
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.foodName,
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    '${entry.portionG.round()}g  •  P: ${entry.proteinG.toStringAsFixed(1)}g  C: ${entry.carbG.toStringAsFixed(1)}g  F: ${entry.fatG.toStringAsFixed(1)}g',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              '${entry.calorieKcal.round()} kcal',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
