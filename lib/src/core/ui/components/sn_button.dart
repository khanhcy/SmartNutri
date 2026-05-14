import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';
import 'package:smartnutri/src/core/ui/theme/app_shadows.dart';

enum SNButtonVariant { primary, secondary, ghost, danger }

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
    final effectiveOnPressed = isLoading ? null : onPressed;

    final child = isLoading
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Text(
            label,
            style: _textStyle(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: effectiveOnPressed,
        borderRadius: BorderRadius.circular(_radius),
        child: Container(
          width: double.infinity,
          height: _height,
          decoration: BoxDecoration(
            gradient: _gradient,
            color: _bgColor,
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: _shadows,
            border: _border,
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  double get _height {
    return switch (variant) {
      SNButtonVariant.primary => 52,
      SNButtonVariant.danger => 52,
      SNButtonVariant.secondary => 44,
      SNButtonVariant.ghost => 44,
    };
  }

  double get _radius {
    return switch (variant) {
      SNButtonVariant.primary => 18,
      SNButtonVariant.danger => 18,
      SNButtonVariant.secondary => 16,
      SNButtonVariant.ghost => 16,
    };
  }

  LinearGradient? get _gradient {
    return switch (variant) {
      SNButtonVariant.primary => const LinearGradient(
          colors: [AppColors.primary, AppColors.fresh],
        ),
      _ => null,
    };
  }

  Color? get _bgColor {
    return switch (variant) {
      SNButtonVariant.secondary => AppColors.primary.withValues(alpha: 0.08),
      SNButtonVariant.danger => AppColors.danger,
      SNButtonVariant.primary => null,
      SNButtonVariant.ghost => Colors.transparent,
    };
  }

  List<BoxShadow>? get _shadows {
    return switch (variant) {
      SNButtonVariant.primary => AppShadows.button,
      SNButtonVariant.danger => AppShadows.button,
      _ => null,
    };
  }

  BoxBorder? get _border {
    return switch (variant) {
      SNButtonVariant.ghost => null,
      _ => null,
    };
  }

  TextStyle _textStyle(BuildContext context) {
    final base = DefaultTextStyle.of(context).style;
    return base.copyWith(
      decoration: TextDecoration.none,
      color: _textColor,
      fontWeight: FontWeight.w800,
      fontSize: 15,
    );
  }

  Color get _textColor {
    return switch (variant) {
      SNButtonVariant.primary => Colors.white,
      SNButtonVariant.danger => Colors.white,
      SNButtonVariant.secondary => AppColors.primary,
      SNButtonVariant.ghost => AppColors.primary,
    };
  }
}
