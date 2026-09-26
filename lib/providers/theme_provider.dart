// lib/providers/theme_provider.dart
//
// Theme mode manager for Madhyamik Shokha.
// Handles light/dark toggle with persistence.

import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  ThemeProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    // SharedPreferences später (once added)
    // For now, default = light
  }

  void setLight() {
    _mode = ThemeMode.light;
    notifyListeners();
  }

  void setDark() {
    _mode = ThemeMode.dark;
    notifyListeners();
  }

  void toggle() {
    _mode = _mode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }
}