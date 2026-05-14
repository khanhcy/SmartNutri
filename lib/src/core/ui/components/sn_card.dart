import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';
import 'package:smartnutri/src/core/ui/theme/app_radius.dart';
import 'package:smartnutri/src/core/ui/theme/app_shadows.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

enum SNCardVariant { regular, glow }

class SNCard extends StatelessWidget {
  const SNCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.variant = SNCardVariant.regular,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final SNCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface.withValues(alpha: 0.12) : _bgColor,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _borderColor(isDark)),
        boxShadow: isDark ? null : _shadows,
        gradient: _gradient,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }

  Color get _bgColor {
    return switch (variant) {
      SNCardVariant.glow => AppColors.surfaceStrong,
      SNCardVariant.regular => AppColors.surface,
    };
  }

  double get _radius {
    return switch (variant) {
      SNCardVariant.glow => AppRadius.xl,
      SNCardVariant.regular => AppRadius.lg,
    };
  }

  List<BoxShadow> get _shadows {
    return switch (variant) {
      SNCardVariant.glow => AppShadows.soft,
      SNCardVariant.regular => AppShadows.card,
    };
  }

  LinearGradient? get _gradient {
    if (variant != SNCardVariant.glow) return null;
    return const LinearGradient(
      begin: Alignment(-0.8, -0.6),
      end: Alignment(0.8, 0.6),
      colors: [Color(0xF2FFFFFF), Color(0xEBE9F8EB)],
    );
  }

  Color _borderColor(bool isDark) {
    if (isDark) return Colors.white12;
    return switch (variant) {
      SNCardVariant.glow => const Color(0x142E7D32),
      SNCardVariant.regular => AppColors.border,
    };
  }
}
