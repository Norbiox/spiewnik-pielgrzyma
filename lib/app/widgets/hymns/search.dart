import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/hymns/hymns_list.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';

class HymnsSearch extends SearchDelegate<Hymn> {
  final HymnsListProvider provider;
  final List<Hymn> hymns;

  HymnsSearch({required this.provider, required this.hymns});

  @override
  String get searchFieldLabel => 'Szukaj';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pop(context, null);
      },
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
        future: provider.searchHymns(hymns, query),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text("Nic nie znaleziono"));
          }
          return HymnsListWidget(hymnsList: snapshot.data!);
        });
  }
}
