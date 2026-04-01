import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.helper,
    this.icon,
  });

  final String label;
  final String value;
  final String? helper;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      child: SNCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(label)),
                if (icon != null) Icon(icon, size: 18),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            if (helper != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(helper!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
