import 'package:flutter/material.dart';

enum SNButtonVariant { primary, secondary, ghost }

class SNButton extends StatelessWidget {
  const SNButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = SNButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final SNButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(
            label,
            style: DefaultTextStyle.of(context).style.copyWith(
              decoration: TextDecoration.none,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );

    final effectiveOnPressed = isLoading ? null : onPressed;
    switch (variant) {
      case SNButtonVariant.primary:
        return FilledButton(onPressed: effectiveOnPressed, child: child);
      case SNButtonVariant.secondary:
        return OutlinedButton(onPressed: effectiveOnPressed, child: child);
      case SNButtonVariant.ghost:
        return TextButton(onPressed: effectiveOnPressed, child: child);
    }
  }
}
