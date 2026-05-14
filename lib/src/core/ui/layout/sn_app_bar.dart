import 'package:flutter/material.dart';

class SNAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SNAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: actions,
      leading: showBackButton && Navigator.of(context).canPop()
          ? const BackButton()
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
