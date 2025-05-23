import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/settings/theme.dart';
import 'package:watch_it/watch_it.dart';

class ThemeModeButton extends WatchingWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeProvider provider = GetIt.I<ThemeProvider>();
    watch(provider);

    return IconButton(
        onPressed: () => provider.toggleMode(),
        icon: Icon(provider.themeMode == ThemeMode.light
            ? Icons.dark_mode
            : Icons.light_mode));
  }
}
