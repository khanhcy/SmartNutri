import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/goal_service.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/layout/page_template.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/core/utils/date_utils.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';
import 'package:smartnutri/src/features/meal_log/presentation/add_meal_bottom_sheet.dart';
import 'package:smartnutri/src/features/meal_log/presentation/custom_meal_sheet.dart';
import 'package:smartnutri/src/features/meal_log/presentation/weekly_summary_card.dart';
import 'package:smartnutri/src/features/nutrition/domain/nutrition_goal.dart';

class MealLogPage extends StatefulWidget {
  const MealLogPage({super.key});

  @override
  State<MealLogPage> createState() => _MealLogPageState();
}

class _MealLogPageState extends State<MealLogPage> {
  DateTime _selectedDate = DateTime.now();

  MealType _suggestMealTypeForSelectedDay() {
    final now = DateTime.now();
    if (!AppDateUtils.isSameDay(_selectedDate, now)) {
      return MealType.lunch;
    }
    final hour = now.hour;
    if (hour < 10) return MealType.breakfast;
    if (hour < 14) return MealType.lunch;
    if (hour < 19) return MealType.dinner;
    return MealType.snack;
  }

  String get _dateStr => AppDateUtils.toDateStr(_selectedDate);

  String get _displayDate {
    final now = DateTime.now();
    final d = _selectedDate;
    if (AppDateUtils.isSameDay(d, now)) return 'Hôm nay';
    if (AppDateUtils.isSameDay(d, now.subtract(const Duration(days: 1)))) return 'Hôm qua';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthService>().currentUser!.uid;

    return StreamBuilder<NutritionGoal?>(
      stream: context.read<GoalService>().watchGoal(uid),
      builder: (context, goalSnap) {
        final goal = goalSnap.data ?? NutritionGoal.defaultGoal(uid);
        return StreamBuilder<List<MealEntry>>(
          stream:
              context.read<MealService>().watchEntriesForDate(uid, _dateStr),
          builder: (context, entriesSnap) {
            final entries = entriesSnap.data ?? [];
            final totalKcal =
                entries.fold(0.0, (s, e) => s + e.calorieKcal);
            final remaining =
                (goal.calorieTarget - totalKcal).clamp(0.0, double.infinity);

            return PageTemplate(
              title: 'Nhật ký bữa ăn',
              subtitle: 'Ghi lại các bữa ăn trong ngày.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateNavigator(
                    label: _displayDate,
                    onPrevious: () => setState(() => _selectedDate =
                        _selectedDate.subtract(const Duration(days: 1))),
                    onNext: AppDateUtils.isSameDay(_selectedDate, DateTime.now())
                        ? null
                        : () => setState(() => _selectedDate =
                            _selectedDate.add(const Duration(days: 1))),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Tổng calo',
                          value: '${totalKcal.round()} kcal',
                          sub: 'Mục tiêu ${goal.calorieTarget} kcal',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Còn lại',
                          value: '${remaining.round()} kcal',
                          sub: '${entries.length} bữa đã ghi',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (entries.isEmpty)
                    _EmptyDay(date: _displayDate)
                  else
                    _MealGroups(entries: entries, uid: uid),
                  const SizedBox(height: AppSpacing.md),
                  RepaintBoundary(child: WeeklySummaryCard(goal: goal)),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => showAddMealSheet(
                            context,
                            initialMealType: _suggestMealTypeForSelectedDay(),
                            logDate: _selectedDate,
                          ),
                          icon: const Icon(Icons.search),
                          label: const Text('Tìm món'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => showCustomMealSheet(
                            context,
                            initialMealType: _suggestMealTypeForSelectedDay(),
                            logDate: _selectedDate,
                          ),
                          icon: const Icon(Icons.edit_note),
                          label: const Text('Nhập thủ công'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: Icon(
            Icons.chevron_right,
            color: onNext == null
                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
                : null,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.sub,
  });
  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return SNCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text(sub, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.date});
  final String date;

  @override
  Widget build(BuildContext context) {
    return SNCard(
      child: Column(
        children: [
          Icon(Icons.restaurant_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.sm),
          Text('Chưa có bữa ăn nào $date',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _MealGroups extends StatelessWidget {
  const _MealGroups({required this.entries, required this.uid});
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
          ? 'Không thể lưu. Kiểm tra quyền Firestore Rules trên Firebase.'
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
          return true;
        } on FirebaseException catch (e) {
          if (!context.mounted) return false;
          final messenger = ScaffoldMessenger.of(context);
          final message = e.code == 'permission-denied'
              ? 'Không thể xóa món. Kiểm tra quyền Firestore Rules trên Firebase.'
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
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.foodName,
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    '${entry.portionG.round()}g  •  '
                    'P:${entry.proteinG.toStringAsFixed(1)}g  '
                    'C:${entry.carbG.toStringAsFixed(1)}g  '
                    'F:${entry.fatG.toStringAsFixed(1)}g',
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
