import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/app/widgets/utils/dismissible.dart';
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
      background: slideRightBackground(Icons.delete_outline, "Usuń", context,
          color: Theme.of(context).colorScheme.error,
          secondColor: Theme.of(context).colorScheme.onError),
      secondaryBackground: slideLeftBackground(
          Icons.delete_outline, "Usuń", context,
          color: Theme.of(context).colorScheme.error,
          secondColor: Theme.of(context).colorScheme.onError),
      key: ValueKey(hymn.id),
      onDismissed: (DismissDirection direction) {
        _deleteHymnFromList(context, list, hymn);
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

    list.removeHymn(hymn);
    provider.save(list);

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
              list.addHymn(hymn);
              provider.save(list);
            },
            child: Text("Przywróć",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary)),
          ),
        ]),
      ),
    );
  }
}

//     return ListTile(
//       horizontalTitleGap: 0,
//       title: Text(
//         hymn.fullTitle,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//       ),
//       onTap: () => context.push('/hymn/${hymn.id}'),
//       trailing: IconButton(
//           icon: const Icon(Icons.delete),
//           onPressed: () => showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                     content: Text(
//                         'Na pewno chcesz usunąć pieśń "${hymn.fullTitle}" z listy "${list.name}"?'),
//                     actions: <Widget>[
//                       FilledButton.tonal(
//                         child: const Text("Nie"),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                       FilledButton(
//                           child: const Text("Tak"),
//                           onPressed: () {
//                             list.removeHymn(hymn);
//                             provider.save(list);
//                             Navigator.pop(context);
//                           })
//                     ]);
//               })),
//     );
//   }
// }
