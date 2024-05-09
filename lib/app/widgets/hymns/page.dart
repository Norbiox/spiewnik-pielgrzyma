import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/hymns_list.dart';
import 'package:watch_it/watch_it.dart';

class HymnsListPage extends WatchingStatefulWidget {
  const HymnsListPage({super.key});

  @override
  State<HymnsListPage> createState() => _HymnsListPageState();
}

class _HymnsListPageState extends State<HymnsListPage> {
  TextEditingController searchController = TextEditingController();
  final HymnsListProvider provider = GetIt.I<HymnsListProvider>();

  String searchText = "";

  void updateSearchText(String text) async {
    setState(() async {
      searchText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    watch(provider);

    return Scaffold(
        body: Column(children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
          child: TextField(
              controller: searchController,
              onChanged: (value) => updateSearchText(value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0))),
                labelText: 'Szukaj',
                hintText: 'Wpisz numer, fragment tytułu lub tekstu pieśni',
              ))),
      FutureBuilder(
          future: provider.searchHymns(searchText),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else {
              final hymns = snapshot.data;
              return Expanded(child: HymnsListWidget(hymnsList: hymns));
            }
          })
    ]));
  }
}
