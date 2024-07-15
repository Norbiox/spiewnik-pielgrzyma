import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:watch_it/watch_it.dart';

class AddHymnToCustomListDialog extends SimpleDialog {
  final Hymn hymn;

  const AddHymnToCustomListDialog({super.key, required this.hymn});

  @override
  Widget build(BuildContext context) {
    CustomListProvider provider = GetIt.I<CustomListProvider>();

    List<CustomList> lists = provider
        .getLists()
        .where((list) => !list.hymns.contains(hymn))
        .toList();

    return SimpleDialog(
      title: const Text("Wybierz listę"),
      children: lists
          .map((list) => SimpleDialogOption(
                onPressed: addHymnToCustomList(context, list, hymn),
                child: Text(list.name!),
              ))
          .toList(),
    );
  }
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
