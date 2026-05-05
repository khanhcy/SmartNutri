import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/goal_service.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';
import 'package:smartnutri/src/core/services/water_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/layout/page_template.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/core/utils/calorie_streak.dart';
import 'package:smartnutri/src/core/utils/date_utils.dart';
import 'package:smartnutri/src/features/home/presentation/macro_trend_card.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';
import 'package:smartnutri/src/features/profile/domain/user_profile.dart';
import 'package:smartnutri/src/features/meal_log/presentation/add_meal_bottom_sheet.dart';
import 'package:smartnutri/src/features/meal_log/presentation/custom_meal_sheet.dart';
import 'package:smartnutri/src/features/nutrition/domain/nutrition_goal.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthService>().currentUser!.uid;
    final today = AppDateUtils.todayStr();

    return StreamBuilder<UserProfile?>(
      stream: context.read<ProfileService>().watchProfile(uid),
      builder: (context, profileSnap) {
        final displayName = profileSnap.data?.displayName;
        return StreamBuilder<NutritionGoal?>(
          stream: context.read<GoalService>().watchGoal(uid),
          builder: (context, goalSnap) {
            final goal = goalSnap.data ?? NutritionGoal.defaultGoal(uid);
            return StreamBuilder<List<MealEntry>>(
              stream:
                  context.read<MealService>().watchEntriesForDate(uid, today),
              builder: (context, entriesSnap) {
                final entries = entriesSnap.data ?? [];
                final consumed =
                    entries.fold(0.0, (s, e) => s + e.calorieKcal);
                final remaining = (goal.calorieTarget - consumed)
                    .clamp(0.0, goal.calorieTarget.toDouble());
                final proteinConsumed =
                    entries.fold(0.0, (s, e) => s + e.proteinG);
                final carbConsumed =
                    entries.fold(0.0, (s, e) => s + e.carbG);
                final fatConsumed =
                    entries.fold(0.0, (s, e) => s + e.fatG);

                return StreamBuilder<double>(
                  stream:
                      context.read<WaterService>().watchWaterMl(uid, today),
                  builder: (context, waterSnap) {
                    final waterMl = waterSnap.data ?? 0.0;

                    return PageTemplate(
                      title: 'Tổng quan hôm nay',
                      subtitle: homeGreetingSubtitle(displayName),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CalorieSummaryCard(
                            consumed: consumed,
                            goal: goal.calorieTarget.toDouble(),
                            remaining: remaining,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _StreakBadge(
                            uid: uid,
                            calorieTarget: goal.calorieTarget,
                            refreshToken:
                                entries.length + consumed.round(),
                          ),
                          const SizedBox(height: AppSpacing.md),
                      _WaterCard(
                        waterMl: waterMl,
                        targetMl: goal.waterTargetMl,
                        uid: uid,
                        date: today,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SNCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tiến độ macro',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _MacroRow(
                              label: 'Protein',
                              consumed: proteinConsumed,
                              goal: goal.proteinG.toDouble(),
                              color: Colors.blue,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _MacroRow(
                              label: 'Carb',
                              consumed: carbConsumed,
                              goal: goal.carbG.toDouble(),
                              color: Colors.orange,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _MacroRow(
                              label: 'Fat',
                              consumed: fatConsumed,
                              goal: goal.fatG.toDouble(),
                              color: Colors.pink,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const RepaintBoundary(child: MacroTrendCard()),
                      const SizedBox(height: AppSpacing.md),
                      _TodayMealsSection(entries: entries, uid: uid),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => showAddMealSheet(
                                context,
                                initialMealType: homeSuggestMealType(),
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
                                initialMealType: homeSuggestMealType(),
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
          },
        );
      },
    );
  }
}

String homeGreetingSubtitle(String? displayName) {
  final hour = DateTime.now().hour;
  final greeting = hour < 12
      ? 'Chào buổi sáng'
      : hour < 18
          ? 'Chào buổi chiều'
          : 'Chào buổi tối';
  final name = displayName?.trim();
  final first =
      (name != null && name.isNotEmpty) ? name.split(RegExp(r'\s+')).first : null;
  if (first != null && first.isNotEmpty) {
    return '$greeting, $first! Theo dõi dinh dưỡng của bạn hôm nay.';
  }
  return '$greeting! Theo dõi dinh dưỡng của bạn hôm nay.';
}

MealType homeSuggestMealType() {
  final hour = DateTime.now().hour;
  if (hour < 10) return MealType.breakfast;
  if (hour < 14) return MealType.lunch;
  if (hour < 19) return MealType.dinner;
  return MealType.snack;
}

class _StreakBadge extends StatefulWidget {
  const _StreakBadge({
    required this.uid,
    required this.calorieTarget,
    required this.refreshToken,
  });

  final String uid;
  final int calorieTarget;
  final int refreshToken;

  @override
  State<_StreakBadge> createState() => _StreakBadgeState();
}

class _StreakBadgeState extends State<_StreakBadge> {
  int? _value;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _StreakBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid ||
        oldWidget.calorieTarget != widget.calorieTarget ||
        oldWidget.refreshToken != widget.refreshToken) {
      _load();
    }
  }

  Future<void> _load() async {
    final meal = context.read<MealService>();
    final n = await CalorieStreak.compute(
      meal: meal,
      uid: widget.uid,
      calorieTarget: widget.calorieTarget,
    );
    if (mounted) setState(() => _value = n);
  }

  @override
  Widget build(BuildContext context) {
    final v = _value;
    if (v == null) {
      return const SizedBox(
        height: 24,
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (v == 0) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(Icons.local_fire_department, color: Colors.orange.shade700, size: 22),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$v ngày liên tiếp đạt mục tiêu calo (80–110%)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _WaterCard extends StatelessWidget {
  const _WaterCard({
    required this.waterMl,
    required this.targetMl,
    required this.uid,
    required this.date,
  });

  final double waterMl;
  final double targetMl;
  final String uid;
  final String date;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (waterMl / targetMl).clamp(0.0, 1.0);
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
  }

  Future<void> _addWater(BuildContext context, double ml) async {
    try {
      await context.read<WaterService>().addWaterMl(uid, date, ml);
    } on FirebaseException catch (e) {
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final message = e.code == 'permission-denied'
          ? 'Không thể cập nhật nước uống. Kiểm tra quyền Firestore Rules trên Firebase.'
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
            content: Text(
              'Không thể cập nhật nước uống lúc này. Vui lòng thử lại.',
            ),
          ),
        );
    }
  }
}

class _CalorieSummaryCard extends StatelessWidget {
  const _CalorieSummaryCard({
    required this.consumed,
    required this.goal,
    required this.remaining,
  });

  final double consumed;
  final double goal;
  final double remaining;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final isOver = consumed > goal;

    return SNCard(
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: isOver ? Colors.red : colorScheme.primary,
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${consumed.round()} / ${goal.round()} kcal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isOver ? Colors.red : null,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOver
                      ? 'Đã vượt ${(consumed - goal).round()} kcal'
                      : 'Còn lại ${remaining.round()} kcal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isOver
                            ? Colors.red
                            : colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mục tiêu ngày: ${goal.round()} kcal',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.label,
    required this.consumed,
    required this.goal,
    required this.color,
  });

  final String label;
  final double consumed;
  final double goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            Text(
              '${consumed.toStringAsFixed(1)}g / ${goal.round()}g',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: ratio,
          color: color,
          backgroundColor: color.withValues(alpha: 0.15),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}

class _TodayMealsSection extends StatelessWidget {
  const _TodayMealsSection({required this.entries, required this.uid});

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
              'Nhấn "Thêm bữa ăn" để bắt đầu ghi nhật ký.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
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
