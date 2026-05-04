import 'package:flutter/material.dart';
import 'package:smartnutri/src/features/home/presentation/home_page.dart';
import 'package:smartnutri/src/features/meal_log/presentation/meal_log_page.dart';
import 'package:smartnutri/src/features/profile/presentation/profile_page.dart';
import 'package:smartnutri/src/features/search/presentation/food_search_page.dart';

class AppTabItem {
  const AppTabItem({
    required this.label,
    required this.icon,
    required this.page,
  });

  final String label;
  final IconData icon;
  final Widget page;
}

class AppRouter {
  static const List<AppTabItem> mainTabs = [
    AppTabItem(
      label: 'Tổng quan',
      icon: Icons.home_outlined,
      page: HomePage(),
    ),
    AppTabItem(
      label: 'Tìm món',
      icon: Icons.search,
      page: FoodSearchPage(),
    ),
    AppTabItem(
      label: 'Nhật ký',
      icon: Icons.restaurant_menu_outlined,
      page: MealLogPage(),
    ),
    AppTabItem(
      label: 'Hồ sơ',
      icon: Icons.person_outline,
      page: ProfilePage(),
    ),
  ];
}
