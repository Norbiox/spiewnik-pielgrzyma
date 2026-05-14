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
    return Dismissible(
      background: slideRightBackground(context),
      secondaryBackground: slideLeftBackground(context),
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

Widget slideRightBackground(BuildContext context) {
  return Container(
    color: Theme.of(context).colorScheme.primary,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Icon(
            Icons.archive_outlined,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          Text(
            " Archiwizuj",
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    ),
  );
}

Widget slideLeftBackground(BuildContext context) {
  return Container(
    color: Theme.of(context).colorScheme.primary,
    child: Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Icon(
            Icons.archive_outlined,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          Text(
            " Archiwizuj",
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    ),
  );
}
