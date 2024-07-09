import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/page.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/favorites/page.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/page.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});
  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Offstage(offstage: _currentIndex != 0, child: HymnsListPage()),
          Offstage(offstage: _currentIndex != 1, child: FavoritesPage()),
          Offstage(offstage: _currentIndex != 2, child: CustomListsPage()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note_outlined),
            activeIcon: Icon(Icons.music_note),
            label: 'Lista pieśni',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Ulubione',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_outlined),
            activeIcon: Icon(Icons.list),
            label: 'Twoje listy',
          ),
        ],
      ),
    );
  }
}
