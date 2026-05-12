import 'package:flutter/material.dart';

/// Reusable cinematic text input — large, filled, and focus-animated.
class CinematicInput extends StatefulWidget {
  const CinematicInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.suffixIcon,
    this.validator,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool autofocus;

  @override
  State<CinematicInput> createState() => _CinematicInputState();
}

class _CinematicInputState extends State<CinematicInput>
    with SingleTickerProviderStateMixin {
  late final FocusNode _focus;
  late final AnimationController _ctrl;
  late final Animation<double> _borderWidth;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _borderWidth = Tween<double>(begin: 0, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _focus.addListener(() {
      if (_focus.hasFocus) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: _borderWidth.value / 2),
            width: _borderWidth.value,
          ),
          boxShadow: [
            if (_ctrl.value > 0)
              BoxShadow(
                color: colorScheme.primary
                    .withValues(alpha: 0.08 * _ctrl.value),
                blurRadius: 16,
                spreadRadius: 2,
              ),
          ],
        ),
        child: child,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focus,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        autofocus: widget.autofocus,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: Icon(widget.icon),
          suffixIcon: widget.suffixIcon,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.error, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        validator: widget.validator,
      ),
    );
  }
}
