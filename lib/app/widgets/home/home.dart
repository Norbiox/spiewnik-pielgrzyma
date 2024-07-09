import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/home/bottom_navigation.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/home/theme_mode_button.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Śpiewnik Pielgrzyma'),
            actions: const [ThemeModeButton()],
          ),
          body: const BottomNavigation(),
        ));
  }
}
