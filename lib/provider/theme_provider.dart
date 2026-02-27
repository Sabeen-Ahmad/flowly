import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {

  static const String THEME_KEY = "theme_mode";

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    loadTheme();
  }

  /// Load saved theme
  Future<void> loadTheme() async {

    final prefs = await SharedPreferences.getInstance();

    final isDark = prefs.getBool(THEME_KEY) ?? false;

    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();

  }

  /// Toggle theme
  Future<void> toggleTheme() async {

    final prefs = await SharedPreferences.getInstance();

    _themeMode =
    _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    await prefs.setBool(THEME_KEY, _themeMode == ThemeMode.dark);

    notifyListeners();

  }

}