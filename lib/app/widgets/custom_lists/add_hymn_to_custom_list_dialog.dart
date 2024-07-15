import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:watch_it/watch_it.dart';

showDialogWithCustomListsToAddTheHymnTo(BuildContext context, Hymn hymn) {
  CustomListProvider provider = GetIt.I<CustomListProvider>();

  return () {
    List<CustomList> lists = provider
        .getLists()
        .where((list) => !list.hymns.any((h) => h.id == hymn.id))
        .toList();

    // Show SnackBar if there are no lists without the hymn or no lists at all
    if (lists.isEmpty) {
      return () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Brak list, do których możnaby dodać tę pieśń")));
    }

    // Show dialog with list of custom lists to add the hymn to
    return showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: const Text("Dodaj pieśń do listy:"),
              children: lists
                  .map((list) => SimpleDialogOption(
                        onPressed: addHymnToCustomList(context, list, hymn),
                        child: ListTile(
                          leading: const Icon(Icons.arrow_forward_sharp),
                          title: Text(list.name!),
                          visualDensity: const VisualDensity(vertical: -4.0),
                        ),
                      ))
                  .toList(),
            ));
  };

  // Get lists that does not contain the hymn
}

addHymnToCustomList(BuildContext context, CustomList list, Hymn hymn) {
  return () {
    list.hymns.add(hymn);
    GetIt.I<CustomListProvider>().save(list);
    Navigator.pop(context);
    final SnackBar snackBar = SnackBar(
        content:
            Text('Dodano pieśń "${hymn.fullTitle}" do listy "${list.name}"'),
        action: SnackBarAction(
            label: 'Cofnij',
            onPressed: () {
              list.hymns.remove(hymn);
              GetIt.I<CustomListProvider>().save(list);
            }));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  };
}
