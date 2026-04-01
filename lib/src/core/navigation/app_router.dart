import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
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
  static List<AppTabItem> mainTabs(AuthUser user) {
    return [
      const AppTabItem(
        label: 'Home',
        icon: Icons.home_outlined,
        page: HomePage(),
      ),
      const AppTabItem(
        label: 'Tim mon',
        icon: Icons.search,
        page: FoodSearchPage(),
      ),
      const AppTabItem(
        label: 'Nhat ky',
        icon: Icons.restaurant_menu_outlined,
        page: MealLogPage(),
      ),
      AppTabItem(
        label: 'Ho so',
        icon: Icons.person_outline,
        page: ProfilePage(user: user),
      ),
    ];
  }
}
