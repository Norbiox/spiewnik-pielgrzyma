import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/home/bottom_navigation.dart';

class MyHomePage extends StatelessWidget {
  final int initialIndex;

  const MyHomePage({super.key, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        initialIndex: initialIndex,
        child: Scaffold(
          body: BottomNavigation(initialIndex: initialIndex),
        ));
  }
}
