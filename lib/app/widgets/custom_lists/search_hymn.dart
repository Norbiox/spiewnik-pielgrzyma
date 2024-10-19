import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:watch_it/watch_it.dart';
import 'package:go_router/go_router.dart';

class SearchForHymnToAddToCustomList extends SearchDelegate<Hymn> {
  final HymnsListProvider provider;
  final List<Hymn> hymns;
  final CustomList customList;

  SearchForHymnToAddToCustomList(
      {required this.provider, required this.hymns, required this.customList});

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
          return HymnsSearchListWidget(
              hymns: snapshot.data!, customList: customList);
        });
  }
}

class HymnsSearchListWidget extends StatelessWidget {
  final List<Hymn> hymns;
  final CustomList customList;

  const HymnsSearchListWidget(
      {super.key, required this.hymns, required this.customList});

  @override
  Widget build(BuildContext context) {
    final CustomListProvider provider = GetIt.I<CustomListProvider>();

    return Scrollbar(
      thumbVisibility: true,
      thickness: 20.0,
      interactive: true,
      child: ListView.builder(
          itemCount: hymns.length,
          prototypeItem: const ListTile(),
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(hymns[index].fullTitle,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              enabled: !customList.hymnsIds.contains(hymns[index].id),
              onTap: () {
                customList.addHymn(hymns[index]);
                provider.save(customList);
                context.pop();
              },
            );
          }),
    );
  }
}
