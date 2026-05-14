import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/components/sn_button.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';
import 'package:smartnutri/src/core/ui/theme/app_radius.dart';
import 'package:smartnutri/src/core/ui/theme/app_shadows.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: textTheme.bodyMedium?.copyWith(
                decoration: TextDecoration.none,
                color: AppColors.muted,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    this.description,
    this.icon,
  });

  final String title;
  final String? description;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.24),
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 40, color: AppColors.muted),
              const SizedBox(height: AppSpacing.md),
            ],
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                description!,
                style: textTheme.bodySmall?.copyWith(
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.info_outline_rounded,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: AppColors.ai.withValues(alpha: 0.22),
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.aiSoft,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Icon(icon, size: 30, color: AppColors.ai),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              SNButton(label: 'Thử lại', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
