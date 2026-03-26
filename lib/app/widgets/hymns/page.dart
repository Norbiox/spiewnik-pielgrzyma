import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/search_engine.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/hymns_list.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/shared/search_app_bar.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:watch_it/watch_it.dart';

class HymnsListPage extends WatchingStatefulWidget {
  const HymnsListPage({super.key});

  @override
  State<HymnsListPage> createState() => _HymnsListPageState();
}

class _HymnsListPageState extends State<HymnsListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final HymnsListProvider provider = GetIt.I<HymnsListProvider>();
    watch(provider);

    List<Hymn> hymns = provider.getAll();
    if (_searchQuery.isNotEmpty) {
      hymns = HymnsSearchEngine().search(hymns, _searchQuery);
    }

    return Scaffold(
      appBar: SearchAppBar(
        onSearchChanged: (q) => setState(() => _searchQuery = q),
      ),
      body: Column(children: [
        Expanded(child: HymnsListWidget(hymnsList: hymns)),
      ]),
    );
  }
}
