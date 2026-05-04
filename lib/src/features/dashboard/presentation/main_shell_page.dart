import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/providers/app_settings_provider.dart';
import 'package:smartnutri/src/core/ui/layout/sn_app_bar.dart';
import 'package:smartnutri/src/core/ui/layout/sn_scaffold.dart';
import 'package:smartnutri/src/features/dashboard/presentation/notifications_sheet.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _labels = ['Tổng quan', 'Tìm món', 'Nhật ký', 'Hồ sơ'];
  static const _icons = [
    Icons.home_outlined,
    Icons.search,
    Icons.restaurant_menu_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final label = _labels[shell.currentIndex];

    return SNScaffold(
      appBar: SNAppBar(
        title: label,
        actions: [const _NotificationBell()],
      ),
      body: shell,
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(
          i,
          initialLocation: i == shell.currentIndex,
        ),
        destinations: [
          for (int i = 0; i < _labels.length; i++)
            NavigationDestination(
              icon: Icon(_icons[i]),
              selectedIcon: Icon(_icons[i], fill: 1),
              label: _labels[i],
            ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final hasActive = context.select<AppSettingsProvider, bool>(
      (s) => s.waterRemindersEnabled || s.mealRemindersEnabled,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            hasActive ? Icons.notifications : Icons.notifications_none,
          ),
          tooltip: 'Nhắc nhở',
          onPressed: () => NotificationsSheet.show(context),
        ),
        if (hasActive)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
