import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue, brightness: Brightness.light),
    useMaterial3: true,
  );
  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.red, brightness: Brightness.dark),
    useMaterial3: true,
  );

  ThemeMode themeMode;

  ThemeMode get currentThemeMode => themeMode;

  ThemeProvider({this.themeMode = ThemeMode.light});

  toggleMode() {
    themeMode == ThemeMode.light
        ? themeMode = ThemeMode.dark
        : themeMode = ThemeMode.light;
    notifyListeners();
  }
}
