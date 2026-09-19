import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/utils/dismissible.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/utils/list_action.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:watch_it/watch_it.dart';

class HymnTileWidget extends StatelessWidget {
  final CustomList list;
  final Hymn hymn;

  const HymnTileWidget({super.key, required this.list, required this.hymn});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background: slideRightBackground(
          Icons.archive_outlined, "Archiwizuj", context,
          color: Theme.of(context).colorScheme.primary,
          secondColor: Theme.of(context).colorScheme.onPrimary),
      secondaryBackground: slideLeftBackground(
          Icons.delete_outline, "Usuń", context,
          color: Theme.of(context).colorScheme.error,
          secondColor: Theme.of(context).colorScheme.onError),
      key: ValueKey('active-${hymn.id}'),
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteHymnFromList(context, list, hymn);
        } else {
          _archiveHymn(context, list, hymn);
        }
      },
      child: ListTile(
        title:
            Text(hymn.fullTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: () => context.push('/hymn/${hymn.id}'),
      ),
    );
  }

  Future<void> _deleteHymnFromList(
      BuildContext context, CustomList list, Hymn hymn) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = GetIt.I<CustomListProvider>();

    runListAction(context, () => provider.removeHymn(list, hymn));

    // show snackbar with 'Undo' button
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Expanded(
            child: Text(
                'Pieśń "${hymn.fullTitle}" została usunięta z listy "${list.name}"'),
          ),
          TextButton(
            onPressed: () {
              messenger.hideCurrentSnackBar();
              runListAction(context, () => provider.addHymn(list, hymn));
            },
            child: Text("Przywróć",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary)),
          ),
        ]),
      ),
    );
  }

  Future<void> _archiveHymn(
      BuildContext context, CustomList list, Hymn hymn) async {
    final provider = GetIt.I<CustomListProvider>();
    await runListAction(context, () => provider.archiveHymn(list, hymn));
  }
}
