import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/navigation/app_router.dart';
import 'package:smartnutri/src/core/ui/layout/sn_app_bar.dart';
import 'package:smartnutri/src/core/ui/layout/sn_scaffold.dart';
import 'package:smartnutri/src/features/dashboard/presentation/notifications_sheet.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/providers/app_settings_provider.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = AppRouter.mainTabs;
    final currentTab = tabs[_currentIndex];

    return SNScaffold(
      appBar: SNAppBar(
        title: currentTab.label,
        actions: [
          const _NotificationBell(),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs.map((tab) => tab.page).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.icon, fill: 1),
              label: tab.label,
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
