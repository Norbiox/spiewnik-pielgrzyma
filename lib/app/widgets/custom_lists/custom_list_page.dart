import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/custom_list.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/search_hymn.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:watch_it/watch_it.dart';

class CustomListPage extends StatelessWidget {
  final CustomListProvider provider = GetIt.I<CustomListProvider>();
  final HymnsListProvider hymnsProvider = GetIt.I<HymnsListProvider>();
  final String listId;

  CustomListPage({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    final CustomList list = provider.getList(listId);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: TextEditingController(text: list.name),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Kliknij aby nazwać listę",
            hintStyle: Theme.of(context).textTheme.titleLarge,
          ),
          onSubmitted: (value) {
            list.name = value;
            GetIt.I<CustomListProvider>().save(list);
          },
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomListWidget(listId: list.id)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showSearch(
            context: context,
            delegate: SearchForHymnToAddToCustomList(
                provider: hymnsProvider,
                hymns: hymnsProvider.getAll(),
                customList: list)),
        tooltip: "Dodaj pieśń do listy",
        child: const Icon(Icons.add),
      ),
    );
  }
}
