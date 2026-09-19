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
      confirmDismiss: (direction) async {
        if (!list.isShared) return true;
        return await _confirmSharedRemoval(context, list) ?? false;
      },
      onDismissed: (direction) => _archiveList(context, list),
      child: ListTile(
        title: Text(list.name),
        subtitle: Text("pieśni: ${list.hymnsIds.length.toString()}"),
        trailing: list.isShared ? const Icon(Icons.share, size: 18) : null,
        onTap: () => context.push('/custom-lists/${list.id}'),
      ),
    );
  }

  Future<bool?> _confirmSharedRemoval(BuildContext context, CustomList list) {
    final provider = GetIt.I<CustomListProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final message = list.isOwner
        ? 'Ta lista jest współdzielona, zostanie usunięta u wszystkich, '
            'którzy z niej korzystają. Kontynuować?'
        : 'Czy opuścić listę „${list.name}”? Zniknie tylko u Ciebie.';

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Nie'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context, true);
              try {
                if (list.isOwner) {
                  await provider.deleteSharedList(list);
                } else {
                  await provider.leaveSharedList(list);
                }
              } catch (_) {
                messenger.showSnackBar(const SnackBar(
                  content: Text('Nie udało się. Sprawdź połączenie.'),
                ));
              }
            },
            child: const Text('Tak'),
          ),
        ],
      ),
    );
  }

  Future<void> _archiveList(BuildContext context, CustomList list) async {
    if (list.isShared) return;
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
