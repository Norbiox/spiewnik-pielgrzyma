import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/search_engine.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/hymns_list.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/shared/search_app_bar.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:watch_it/watch_it.dart';

class FavoritesPage extends WatchingStatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final HymnsListProvider provider = GetIt.I<HymnsListProvider>();
    watch(provider);

    List<Hymn> hymns = provider.getFavorites();
    if (_searchQuery.isNotEmpty) {
      hymns = HymnsSearchEngine().search(hymns, _searchQuery);
    }

    Widget body;
    if (provider.getFavorites().isEmpty) {
      body =
          const Center(child: Text("Nie masz jeszcze ulubionych pieśni"));
    } else if (hymns.isEmpty) {
      body = const Center(child: Text("Nic nie znaleziono"));
    } else {
      body = Column(children: [
        Expanded(child: HymnsListWidget(hymnsList: hymns)),
      ]);
    }

    return Scaffold(
      appBar: SearchAppBar(
        onSearchChanged: (q) => setState(() => _searchQuery = q),
      ),
      body: body,
    );
  }
}
