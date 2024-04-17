import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/model/list.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/repository/list_of_lists.dart';

class CustomListTileWidget extends StatelessWidget {
  final CustomList list;

  const CustomListTileWidget({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(list.name),
      subtitle: Text("pieśni: ${list.hymnNumbers.length.toString()}"),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          await _showDeleteListDialog(context, list);
        },
      ),
    );
  }

  Future<void> _showDeleteListDialog(
      BuildContext context, CustomList list) async {
    final repository = GetIt.I<CustomListsRepository>();
    final lists = repository.customLists;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text("Na pewno chcesz trwale usunąć listę ${list.name}?"),
          actions: <Widget>[
            FilledButton.tonal(
              child: const Text("Nie"),
              onPressed: () => Navigator.pop(context),
            ),
            FilledButton(
                child: const Text("Tak"),
                onPressed: () {
                  lists.remove(list);
                  repository.save(lists);
                  Navigator.pop(context);
                })
          ],
        );
      },
    );
  }
}
