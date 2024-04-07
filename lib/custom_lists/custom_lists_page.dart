import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomListsPage extends StatelessWidget {
  const CustomListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Text("Nie utworzyłeś jeszcze żadnej listy"),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var newListName = await _showCreateListDialog(context);
          if (newListName != null) {
            print("Creating new list: $newListName");
          }
        },
        child: const Icon(Icons.add),
        tooltip: "Dodaj nową listę",
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
