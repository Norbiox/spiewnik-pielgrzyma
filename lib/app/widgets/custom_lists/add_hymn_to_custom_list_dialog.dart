import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:watch_it/watch_it.dart';

void showDialogWithCustomListsToAddTheHymnTo(BuildContext context, Hymn hymn) {
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
    return;
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

                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final router = GoRouter.of(context);
                        final actionColor =
                            Theme.of(context).colorScheme.inversePrimary;
                        scaffoldMessenger.hideCurrentSnackBar();
                        scaffoldMessenger.showSnackBar(SnackBar(
                          content: Row(
                            children: [
                              Expanded(
                                child: Text('Dodano pieśń "${hymn.number}" do "${list.name}"'),
                              ),
                              TextButton(
                                onPressed: () {
                                  scaffoldMessenger.hideCurrentSnackBar();
                                  list.removeHymn(hymn);
                                  GetIt.I<CustomListProvider>().save(list);
                                  scaffoldMessenger.showSnackBar(SnackBar(
                                    content: Text(
                                        'Usunięto pieśń "${hymn.number}" z listy "${list.name}"'),
                                    duration: const Duration(seconds: 2),
                                  ));
                                },
                                child: Text("Cofnij",
                                    style: TextStyle(color: actionColor)),
                              ),
                              TextButton(
                                onPressed: () {
                                  scaffoldMessenger.hideCurrentSnackBar();
                                  router.push('/custom-lists/${list.id}');
                                },
                                child: Text("Do listy",
                                    style: TextStyle(color: actionColor)),
                              ),
                            ],
                          ),
                          duration: const Duration(seconds: 3),
                          padding: const EdgeInsets.only(
                              left: 16, top: 4, bottom: 4, right: 4),
                        ));

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
