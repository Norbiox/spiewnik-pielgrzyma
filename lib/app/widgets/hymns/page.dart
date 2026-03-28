import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/search_engine.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/hymns_list.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:watch_it/watch_it.dart';

class HymnsListPage extends WatchingWidget {
  static final _searchEngine = HymnsSearchEngine();
  final String searchQuery;

  const HymnsListPage({super.key, this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    final HymnsListProvider provider = GetIt.I<HymnsListProvider>();
    watch(provider);

    List<Hymn> hymns = provider.getAll();
    if (searchQuery.isNotEmpty) {
      hymns = _searchEngine.search(hymns, searchQuery);
    }

    return Column(children: [
      Expanded(child: HymnsListWidget(hymnsList: hymns)),
    ]);
  }
}
