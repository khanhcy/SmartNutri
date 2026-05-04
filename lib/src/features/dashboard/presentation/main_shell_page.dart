import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/navigation/app_router.dart';
import 'package:smartnutri/src/core/ui/layout/sn_app_bar.dart';
import 'package:smartnutri/src/core/ui/layout/sn_scaffold.dart';

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
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Thông báo',
          ),
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
