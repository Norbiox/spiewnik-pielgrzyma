import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/list.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/shared/search_app_bar.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:watch_it/watch_it.dart';

class CustomListsPage extends WatchingStatefulWidget {
  const CustomListsPage({super.key});

  @override
  State<CustomListsPage> createState() => _CustomListsPageState();
}

class _CustomListsPageState extends State<CustomListsPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final CustomListProvider provider = GetIt.I<CustomListProvider>();
    watch(provider);

    List<CustomList> lists = provider.getLists();
    final isSearching = _searchQuery.isNotEmpty;
    if (isSearching) {
      lists = lists
          .where(
              (l) => l.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    Widget body;
    if (provider.getLists().isEmpty) {
      body = const Center(child: Text("Nie utworzyłeś jeszcze żadnej listy"));
    } else if (lists.isEmpty) {
      body = const Center(child: Text("Nic nie znaleziono"));
    } else {
      body = CustomListsListWidget(lists: lists, isSearching: isSearching);
    }

    return Scaffold(
      appBar: SearchAppBar(
        onSearchChanged: (q) => setState(() => _searchQuery = q),
        hintText: 'Szukaj listy',
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var newListName = await _showCreateListDialog(context);
          if (newListName != null) {
            provider.createNewList(newListName);
          }
        },
        tooltip: "Dodaj nową listę",
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<String?> _showCreateListDialog(BuildContext context) async {
    final textFieldController =
        TextEditingController(text: DateTime.now().toString().split(".").first);

    return showDialog<String?>(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text("Nazwij nową listę"),
              content: TextField(
                controller: textFieldController,
                decoration: const InputDecoration(hintText: "Nazwa listy"),
                autofocus: true,
              ),
              actions: <Widget>[
                FilledButton.tonal(
                    child: const Text("Anuluj"),
                    onPressed: () => Navigator.pop(context)),
                FilledButton(
                    child: const Text("Zatwierdź"),
                    onPressed: () =>
                        Navigator.pop(context, textFieldController.text)),
              ]);
        });
  }
}
