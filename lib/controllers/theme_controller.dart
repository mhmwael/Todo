import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Controller managing app theme (light/dark mode) with persistence
class ThemeController extends ChangeNotifier {
  static const String _themeKey = 'theme_mode'; // Storage key for theme preference
  ThemeMode _themeMode = ThemeMode.light; // Current theme mode

  ThemeController() {
    _loadTheme(); // Load saved theme on initialization
  }

  ThemeMode get themeMode => _themeMode; // Get current theme
  bool get isDarkMode => _themeMode == ThemeMode.dark; // Check if dark mode

  // Load theme preference from device storage
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);
    notifyListeners();
  }
}
