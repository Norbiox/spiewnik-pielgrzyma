import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/custom_lists_list_widget.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/list.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/repository.dart';

class CustomListsPage extends StatelessWidget {
  const CustomListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomListsListWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var newListName = await _showCreateListDialog(context);
          if (newListName != null) {
            GetIt.I<CustomListsRepository>().add(CustomList(newListName, []));
          }
        },
        tooltip: "Dodaj nową listę",
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<String?> _showCreateListDialog(BuildContext context) async {
    final _textFieldController = TextEditingController();

    return showDialog<String?>(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text("Nazwij nową listę"),
              content: TextField(
                controller: _textFieldController,
                decoration: const InputDecoration(hintText: "Nazwa listy"),
              ),
              actions: <Widget>[
                FilledButton.tonal(
                    child: Text("Anuluj"),
                    onPressed: () => Navigator.pop(context)),
                FilledButton(
                    child: Text("Zatwierdź"),
                    onPressed: () =>
                        Navigator.pop(context, _textFieldController.text)),
              ]);
        });
  }
}
