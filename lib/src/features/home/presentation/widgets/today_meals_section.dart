import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_button.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';

class TodayMealsSection extends StatelessWidget {
  const TodayMealsSection({
    super.key,
    required this.entries,
    required this.uid,
    this.onAddFirstMeal,
  });

  final List<MealEntry> entries;
  final String uid;
  final VoidCallback? onAddFirstMeal;

  @override
  Widget build(BuildContext context) {
    final grouped = <MealType, List<MealEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.mealType, () => []).add(entry);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bữa ăn hôm nay',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (entries.isEmpty && onAddFirstMeal != null)
                GestureDetector(
                  onTap: onAddFirstMeal,
                  child: const Text(
                    'Thêm bữa đầu tiên',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (entries.isEmpty)
          SNCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.mint.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.restaurant_outlined,
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Chưa có bữa ăn nào hôm nay',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Thêm món để Smart Coach cân bằng calo và macro cho bạn.',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
                if (onAddFirstMeal != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  SNButton(
                    label: 'Thêm bữa đầu tiên',
                    variant: SNButtonVariant.secondary,
                    onPressed: onAddFirstMeal,
                  ),
                ],
              ],
            ),
          )
        else
          for (final type in MealType.values)
            if (grouped.containsKey(type))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MealGroupCard(
                  type: type,
                  entries: grouped[type]!,
                  uid: uid,
                ),
              ),
      ],
    );
  }
}

class _MealGroupCard extends StatelessWidget {
  const _MealGroupCard({
    required this.type,
    required this.entries,
    required this.uid,
  });

  final MealType type;
  final List<MealEntry> entries;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final totalKcal = entries.fold(0.0, (s, e) => s + e.calorieKcal);

    return SNCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Icon(type.icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                type.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const Spacer(),
              Text(
                '${totalKcal.round()} kcal',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          for (var i = 0; i < entries.length; i++)
            _EntryTile(
              entry: entries[i],
              uid: uid,
              showDivider: i > 0,
            ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.uid,
    required this.showDivider,
  });

  final MealEntry entry;
  final String uid;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.danger),
      ),
      confirmDismiss: (_) async {
        final mealService = context.read<MealService>();
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xóa bữa ăn?'),
            content: Text('Xóa "${entry.foodName}" khỏi nhật ký?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Xóa'),
              ),
            ],
          ),
        );
        if (!context.mounted) return false;
        if (confirmed != true) return false;
        try {
          await mealService.deleteEntry(uid, entry.id);
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
      child: Column(
        children: [
          if (showDivider)
            const Divider(height: 1, color: Color(0x0F102A16)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.foodName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.portionG.round()}g  •  P: ${entry.proteinG.toStringAsFixed(1)}g  C: ${entry.carbG.toStringAsFixed(1)}g  F: ${entry.fatG.toStringAsFixed(1)}g',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${entry.calorieKcal.round()}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
