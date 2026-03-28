import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/search_engine.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/hymns_list.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:watch_it/watch_it.dart';

class FavoritesPage extends WatchingWidget {
  static final _searchEngine = HymnsSearchEngine();
  final String searchQuery;

  const FavoritesPage({super.key, this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    final HymnsListProvider provider = GetIt.I<HymnsListProvider>();
    watch(provider);

    final favorites = provider.getFavorites();
    List<Hymn> hymns = favorites;
    if (searchQuery.isNotEmpty) {
      hymns = _searchEngine.search(hymns, searchQuery);
    }

    if (favorites.isEmpty) {
      return const Center(child: Text("Nie masz jeszcze ulubionych pieśni"));
    } else if (hymns.isEmpty) {
      return const Center(child: Text("Nic nie znaleziono"));
    } else {
      return Column(children: [
        Expanded(child: HymnsListWidget(hymnsList: hymns)),
      ]);
    }
  }
}
