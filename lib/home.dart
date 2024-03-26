import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/favorites/favorites_page.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list_page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
              title: const Text('Śpiewnik Pielgrzyma'),
              bottom: const TabBar(tabs: [
                Tab(
                  text: 'Lista pieśni',
                ),
                Tab(
                  text: 'Ulubione',
                ),
                Tab(
                  text: 'Twoje listy',
                ),
              ])),
          body: const TabBarView(
            children: [
              HymnsListPage(),
              FavoritesPage(),
              Text('TODO: listy użytkownika'),
            ],
          )),
    );
  }
}
