import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spiewnik_pielgrzyma/domain/custom_lists/model.dart';
import 'package:spiewnik_pielgrzyma/domain/custom_lists/repository.dart';

class CustomListTileWidget extends StatelessWidget {
  final CustomList list;

  const CustomListTileWidget({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(list.name),
      subtitle: Text("pieśni: ${list.hymns.length.toString()}"),
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
    final repository = GetIt.I<CustomListRepository>();

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
                  repository.remove(list);
                  Navigator.pop(context);
                })
          ],
        );
      },
    );
  }
}
