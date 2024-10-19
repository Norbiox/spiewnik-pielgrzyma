import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/home/theme_mode_button.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/hymns_list.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/search.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/menu/menu.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:watch_it/watch_it.dart';

class HymnsListPage extends WatchingWidget {
  const HymnsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final HymnsListProvider provider = GetIt.I<HymnsListProvider>();
    watch(provider);

    List<Hymn> hymns = provider.getAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Śpiewnik Pielgrzyma'),
        actions: [
          IconButton(
              onPressed: () => showSearch(
                  context: context,
                  delegate: HymnsSearch(provider: provider, hymns: hymns)),
              icon: const Icon(Icons.search)),
          const ThemeModeButton(),
          const PopupMenu(),
        ],
      ),
      body: Column(children: [
        Expanded(child: HymnsListWidget(hymnsList: hymns)),
      ]),
    );
  }
}
