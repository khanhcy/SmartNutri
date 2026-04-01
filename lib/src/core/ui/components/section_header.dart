import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/components/sn_button.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (actionLabel != null)
          SNButton(
            label: actionLabel!,
            variant: SNButtonVariant.ghost,
            onPressed: onActionPressed,
          ),
      ],
    );
  }
}
