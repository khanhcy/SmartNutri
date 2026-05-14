import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';

class AppTextStyles {
  static TextTheme textTheme(ColorScheme colorScheme) {
    return TextTheme(
      // H1 — page title: 28px w850
      headlineSmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.56,
        color: colorScheme.onSurface,
      ),
      // H2 — section title: 20px w600
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: colorScheme.onSurface,
      ),
      // H3 — card title: 15px w600
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      // Body large: 16px
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.35,
        color: colorScheme.onSurface,
      ),
      // Body/caption: 14px
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        color: colorScheme.onSurface,
      ),
      // Kicker / small caption: 13px
      bodySmall: TextStyle(
        fontSize: 13,
        height: 1.48,
        color: AppColors.muted,
      ),
      // Button text / primary action: 15px w800
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: colorScheme.onPrimary,
      ),
      // Chip / macro text: 12px w900
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: colorScheme.onSurface,
      ),
      // Nav label: 11px w800
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.muted,
      ),
    );
  }

  // Hero number (kcal donut): 34px w800
  static const TextStyle heroNumber = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.7,
    height: 1.0,
    color: AppColors.text,
  );

  // Big number (kcal result): 42px w900
  static const TextStyle bigNumber = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w900,
    letterSpacing: -2.3,
    height: 1.0,
    color: AppColors.text,
  );

  // Kicker label above headings
  static const TextStyle kicker = TextStyle(
    fontSize: 13,
    color: AppColors.muted,
  );

  AppTextStyles._();
}
