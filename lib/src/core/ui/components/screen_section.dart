import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/components/section_header.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

class ScreenSection extends StatelessWidget {
  const ScreenSection({
    super.key,
    required this.title,
    required this.child,
    this.actionLabel,
    this.onActionPressed,
    this.topSpacing = AppSpacing.lg,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Widget child;
  final double topSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: topSpacing),
        SectionHeader(
          title: title,
          actionLabel: actionLabel,
          onActionPressed: onActionPressed,
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}
