import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/hymns_list.dart';
import 'package:watch_it/watch_it.dart';

class FavoritesPage extends WatchingWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final HymnsListProvider provider = GetIt.I<HymnsListProvider>();
    watch(provider);

    return FutureBuilder(
        future: provider.searchHymns("", true),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Expanded(child: HymnsListWidget(hymnsList: []));
          } else {
            final hymns = snapshot.data;
            return Expanded(child: HymnsListWidget(hymnsList: hymns));
          }
        });
  }
}
