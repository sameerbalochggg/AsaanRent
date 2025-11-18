import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // Default to light mode
  ThemeMode _themeMode = ThemeMode.light;

  // Getter so other widgets can read the current theme
  ThemeMode get themeMode => _themeMode;

  // Setter that notifies all listening widgets to rebuild
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    // Here you would also save this preference to the device
    // using a package like shared_preferences
  }
}