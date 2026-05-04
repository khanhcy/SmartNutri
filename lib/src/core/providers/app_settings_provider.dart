import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  AppSettingsProvider._();

  static const _keyDarkMode = 'dark_mode';
  static const _keyWaterReminders = 'water_reminders';
  static const _keyMealReminders = 'meal_reminders';

  ThemeMode _themeMode = ThemeMode.system;
  bool _waterRemindersEnabled = false;
  bool _mealRemindersEnabled = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get waterRemindersEnabled => _waterRemindersEnabled;
  bool get mealRemindersEnabled => _mealRemindersEnabled;

  /// Factory: load saved preferences before exposing provider.
  static Future<AppSettingsProvider> create() async {
    final provider = AppSettingsProvider._();
    await provider._load();
    return provider;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDark = prefs.getBool(_keyDarkMode);
    if (savedDark != null) {
      _themeMode = savedDark ? ThemeMode.dark : ThemeMode.light;
    }
    _waterRemindersEnabled = prefs.getBool(_keyWaterReminders) ?? false;
    _mealRemindersEnabled = prefs.getBool(_keyMealReminders) ?? false;
  }

  Future<void> setDarkMode(bool dark) async {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, dark);
  }

  void toggleTheme() => setDarkMode(!isDarkMode);

  Future<void> setWaterReminders(bool enabled) async {
    _waterRemindersEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyWaterReminders, enabled);
  }

  Future<void> setMealReminders(bool enabled) async {
    _mealRemindersEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMealReminders, enabled);
  }
}
