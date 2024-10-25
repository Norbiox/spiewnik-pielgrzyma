import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:watch_it/watch_it.dart';

showDialogWithCustomListsToAddTheHymnTo(BuildContext context, Hymn hymn) {
  CustomListProvider provider = GetIt.I<CustomListProvider>();

  List<CustomList> lists = provider
      .getLists()
      .where((list) => !list.hymnsIds.contains(hymn.id))
      .toList();

  // Show SnackBar if there are no lists without the hymn or no lists at all
  if (lists.isEmpty) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Brak list, do których można by dodać tę pieśń")));
    return null;
  }

  // Show dialog with list of custom lists to add the hymn to
  showDialog(
      context: context,
      builder: (context) => SimpleDialog(
            title: const Text("Dodaj pieśń do listy:"),
            children: lists
                .map((list) => SimpleDialogOption(
                      onPressed: () {
                        list.addHymn(hymn);
                        GetIt.I<CustomListProvider>().save(list);

                        final SnackBar snackBar = SnackBar(
                          content: Text(
                              'Dodano pieśń "${hymn.fullTitle}" do listy "${list.name}"'),
                          duration: const Duration(seconds: 2),
                          action: SnackBarAction(
                              label: "Cofnij",
                              onPressed: () {
                                list.removeHymn(hymn);
                                GetIt.I<CustomListProvider>().save(list);
                              }),
                        );
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);

                        Navigator.pop(context);
                      },
                      child: ListTile(
                        leading: const Icon(Icons.arrow_forward_sharp),
                        title: Text(list.name),
                        visualDensity: const VisualDensity(vertical: -4.0),
                      ),
                    ))
                .toList(),
          ));
}
