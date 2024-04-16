import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/custom_lists_list_widget.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/list.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/repository.dart';

class CustomListsPage extends StatelessWidget {
  const CustomListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = GetIt.I<CustomListsRepository>();
    final list = repository.customLists;

    return Scaffold(
      body: const CustomListsListWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var newListName = await _showCreateListDialog(context);
          if (newListName != null) {
            list.add(CustomList(newListName));
            repository.save(list);
          }
        },
        tooltip: "Dodaj nową listę",
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<String?> _showCreateListDialog(BuildContext context) async {
    final textFieldController = TextEditingController();

    return showDialog<String?>(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text("Nazwij nową listę"),
              content: TextField(
                controller: textFieldController,
                decoration: const InputDecoration(hintText: "Nazwa listy"),
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
