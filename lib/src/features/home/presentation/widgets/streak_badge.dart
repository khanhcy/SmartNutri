import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/utils/calorie_streak.dart';

class StreakBadge extends StatefulWidget {
  const StreakBadge({
    super.key,
    required this.uid,
    required this.calorieTarget,
    required this.refreshToken,
  });

  final String uid;
  final int calorieTarget;
  final int refreshToken;

  @override
  State<StreakBadge> createState() => _StreakBadgeState();
}

class _StreakBadgeState extends State<StreakBadge> {
  int? _value;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant StreakBadge oldWidget) {
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
