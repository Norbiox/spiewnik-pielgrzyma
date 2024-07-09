import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/page.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/favorites/page.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/page.dart';

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
              CustomListsPage(),
            ],
          )),
    );
  }
}
