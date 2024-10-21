import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue, brightness: Brightness.light),
  useMaterial3: true,
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme:
      ColorScheme.fromSeed(seedColor: Colors.red, brightness: Brightness.dark),
  useMaterial3: true,
);

class ThemeProvider extends ChangeNotifier {
  final _preferenceKey = 'themeMode';
  ThemeMode? themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() {
    SharedPreferences.getInstance().then((prefs) {
      String preferredTheme =
          prefs.getString(_preferenceKey) ?? ThemeMode.light.toString();
      ThemeMode themeMode =
          ThemeMode.values.firstWhere((e) => e.toString() == preferredTheme);
      this.themeMode = themeMode;
      notifyListeners();
    });
  }

  toggleMode() {
    themeMode == ThemeMode.light
        ? themeMode = ThemeMode.dark
        : themeMode = ThemeMode.light;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_preferenceKey, themeMode.toString());
    });
    notifyListeners();
  }
}
