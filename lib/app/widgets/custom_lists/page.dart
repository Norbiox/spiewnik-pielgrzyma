import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/custom_lists/list.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/home/theme_mode_button.dart';

class CustomListsPage extends StatelessWidget {
  const CustomListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    CustomListProvider provider = GetIt.I<CustomListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Twoje listy'),
        actions: const [ThemeModeButton()],
      ),
      body: const CustomListsListWidget(),
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
