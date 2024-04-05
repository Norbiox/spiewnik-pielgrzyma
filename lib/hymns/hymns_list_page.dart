import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list_widget.dart';
import 'package:watch_it/watch_it.dart';

class HymnsListPage extends WatchingStatefulWidget {
  const HymnsListPage({super.key});

  @override
  State<HymnsListPage> createState() => _HymnsListPageState();
}

class _HymnsListPageState extends State<HymnsListPage> {
  TextEditingController searchController = TextEditingController();

  String searchText = "";

  void updateSearchText(String text) {
    setState(() {
      searchText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final HymnsListProvider hymnsList = GetIt.I<HymnsListProvider>();
    watch(hymnsList);

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
      Expanded(
          child: HymnsListWidget(hymnsList: hymnsList.searchHymns(searchText)))
    ]));
  }
}
