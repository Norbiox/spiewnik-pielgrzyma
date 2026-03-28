import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:go_router/go_router.dart';

class CustomListTileWidget extends StatelessWidget {
  final CustomList list;

  const CustomListTileWidget({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(list.name),
      subtitle: Text("pieśni: ${list.hymnsIds.length.toString()}"),
      trailing: IconButton(
        icon: const Icon(Icons.archive_outlined),
        onPressed: () async {
          await _showArchiveListDialog(context, list);
        },
      ),
      onTap: () => context.push('/custom-lists/${list.id}'),
    );
  }

  Future<void> _showArchiveListDialog(
      BuildContext context, CustomList list) async {
    CustomListProvider provider = GetIt.I<CustomListProvider>();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text("Na pewno chcesz zarchiwizować listę ${list.name}?"),
          actions: <Widget>[
            FilledButton.tonal(
              child: const Text("Nie"),
              onPressed: () => Navigator.pop(context),
            ),
            FilledButton(
                child: const Text("Tak"),
                onPressed: () {
                  provider.archiveList(list);
                  Navigator.pop(context);
                })
          ],
        );
      },
    );
  }
}
