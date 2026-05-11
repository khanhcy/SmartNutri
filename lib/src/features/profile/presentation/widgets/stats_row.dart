import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/profile/domain/user_profile.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key, required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final bmi = profile.weightKg / ((profile.heightCm / 100) * (profile.heightCm / 100));
    final bmiLabel = bmi < 18.5
        ? 'Gầy'
        : bmi < 25
            ? 'Bình thường'
            : bmi < 30
                ? 'Thừa cân'
                : 'Béo phì';
    final bmiColor = bmi < 18.5
        ? Colors.blue
        : bmi < 25
            ? Colors.green
            : bmi < 30
                ? Colors.orange
                : Colors.red;

    return Row(
      children: [
        Expanded(
          child: _StatChip(
            label: 'Chiều cao',
            value: '${profile.heightCm.round()} cm',
            icon: Icons.height,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatChip(
            label: 'Cân nặng',
            value: '${profile.weightKg.toStringAsFixed(1)} kg',
            icon: Icons.monitor_weight_outlined,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatChip(
            label: 'BMI',
            value: bmi.toStringAsFixed(1),
            sub: bmiLabel,
            subColor: bmiColor,
            icon: Icons.analytics_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    this.sub,
    this.subColor,
  });
  final String label;
  final String value;
  final String? sub;
  final Color? subColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SNCard(
      child: Column(
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          if (sub != null)
            Text(sub!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: subColor))
          else
            Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
