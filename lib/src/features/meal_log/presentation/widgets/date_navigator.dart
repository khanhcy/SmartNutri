import 'package:flutter/material.dart';

class DateNavigator extends StatelessWidget {
  const DateNavigator({
    super.key,
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
