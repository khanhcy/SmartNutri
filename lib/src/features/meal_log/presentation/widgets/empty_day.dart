import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

class EmptyDay extends StatelessWidget {
  const EmptyDay({super.key, required this.date});
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
