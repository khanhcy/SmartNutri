import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

class PageTemplate extends StatelessWidget {
  const PageTemplate({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.showAppBar = false,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: 22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!showAppBar) ...[
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.muted,
                  ),
                ),
              ),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    decoration: TextDecoration.none,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          child,
        ],
      ),
    );

    if (!showAppBar) return body;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                decoration: TextDecoration.none,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: Navigator.of(context).canPop() ? const BackButton() : null,
      ),
      body: body,
    );
  }
}
