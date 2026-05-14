import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:go_router/go_router.dart';

import 'package:spiewnik_pielgrzyma/app/widgets/utils/dismissible.dart';

class CustomListTileWidget extends StatelessWidget {
  final CustomList list;

  const CustomListTileWidget({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background:
          slideRightBackground(Icons.archive_outlined, "Archiwizuj", context),
      secondaryBackground:
          slideLeftBackground(Icons.archive_outlined, "Archiwizuj", context),
      key: ValueKey(list.id),
      onDismissed: (DismissDirection direction) {
        _archiveList(context, list);
      },
      child: ListTile(
        title: Text(list.name),
        subtitle: Text("pieśni: ${list.hymnsIds.length.toString()}"),
        onTap: () => context.push('/custom-lists/${list.id}'),
      ),
    );
  }

  Future<void> _archiveList(BuildContext context, CustomList list) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = GetIt.I<CustomListProvider>();

    provider.archiveList(list);

    // show snackbar with 'Undo' button
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Expanded(
            child: Text('Lista "${list.name}" została zarchiwizowana"'),
          ),
          TextButton(
            onPressed: () {
              messenger.hideCurrentSnackBar();
              provider.restoreList(list);
            },
            child: Text("Przywróć",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary)),
          ),
        ]),
      ),
    );
    // );
  }
}
