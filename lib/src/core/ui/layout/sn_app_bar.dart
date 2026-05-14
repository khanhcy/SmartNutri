import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';
import 'package:smartnutri/src/core/ui/theme/app_radius.dart';
import 'package:smartnutri/src/core/ui/theme/app_shadows.dart';

class SNAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SNAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.subtitle,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.025 * 25,
              height: 1.16,
              color: AppColors.text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.muted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: actions,
      leading: showBackButton && Navigator.of(context).canPop()
          ? Container(
              margin: const EdgeInsets.only(left: 4),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppShadows.card,
              ),
              child: const Center(
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
            )
          : null,
      leadingWidth: 56,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
