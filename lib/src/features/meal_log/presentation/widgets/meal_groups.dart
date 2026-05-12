import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';

class MealGroups extends StatelessWidget {
  const MealGroups({super.key, required this.entries, required this.uid});
  final List<MealEntry> entries;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final grouped = <MealType, List<MealEntry>>{};
    for (final e in entries) {
      grouped.putIfAbsent(e.mealType, () => []).add(e);
    }

    return Column(
      children: [
        for (final type in MealType.values)
          if (grouped.containsKey(type)) ...[
            _MealGroupCard(
              type: type,
              entries: grouped[type]!,
              uid: uid,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
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
    final colorScheme = Theme.of(context).colorScheme;
    final totalKcal = entries.fold(0.0, (s, e) => s + e.calorieKcal);

    return SNCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(type.icon, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(type.label,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${totalKcal.round()} kcal',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const Divider(height: AppSpacing.md),
          for (int i = 0; i < entries.length; i++) ...[
            _EntryRow(entry: entries[i], uid: uid),
            if (i < entries.length - 1) const Divider(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.uid});
  final MealEntry entry;
  final String uid;

  Future<void> _editPortion(BuildContext context) async {
    final mealService = context.read<MealService>();
    final controller =
        TextEditingController(text: entry.portionG.round().toString());
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sửa khẩu phần — ${entry.foodName}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Khẩu phần (g)',
            suffixText: 'g',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Lưu')),
        ],
      ),
    );

    if (!context.mounted) return;
    if (confirmed != true) return;
    final newPortion = double.tryParse(controller.text);
    if (newPortion == null || newPortion <= 0) return;

    // Scale macros proportionally
    final scale = newPortion / entry.portionG;
    final updated = MealEntry(
      id: entry.id,
      uid: entry.uid,
      date: entry.date,
      mealType: entry.mealType,
      foodName: entry.foodName,
      portionG: newPortion,
      calorieKcal: entry.calorieKcal * scale,
      proteinG: entry.proteinG * scale,
      carbG: entry.carbG * scale,
      fatG: entry.fatG * scale,
      loggedAt: entry.loggedAt,
    );

    try {
      await mealService.updateEntry(uid, updated);
    } on FirebaseException catch (e) {
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final message = e.code == 'permission-denied'
          ? 'Không thể lưu. Kiểm tra quyền Firestore Rules.'
          : 'Không thể lưu lúc này. Vui lòng thử lại.';
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Không thể lưu lúc này. Vui lòng thử lại.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
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
                  child: const Text('Hủy')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Xóa')),
            ],
          ),
        );
        if (!context.mounted) return false;
        if (confirmed != true) return false;
        try {
          await mealService.deleteEntry(uid, entry.id);
          HapticFeedback.mediumImpact();
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.foodName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${entry.portionG.round()}g',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _MacroBadge(label: 'P', value: entry.proteinG, color: Colors.blue),
                      const SizedBox(width: 4),
                      _MacroBadge(label: 'C', value: entry.carbG, color: Colors.orange),
                      const SizedBox(width: 4),
                      _MacroBadge(label: 'F', value: entry.fatG, color: Colors.pink),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${entry.calorieKcal.round()} kcal',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              tooltip: 'Chỉnh sửa khẩu phần',
              visualDensity: VisualDensity.compact,
              onPressed: () => _editPortion(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroBadge extends StatelessWidget {
  const _MacroBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        '$label ${value.round()}g',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
