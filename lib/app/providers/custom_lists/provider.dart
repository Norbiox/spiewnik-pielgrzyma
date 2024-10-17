import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';

class CustomListProvider with ChangeNotifier {
  final Isar isar;

  CustomListProvider(this.isar);

  List<CustomList> getLists() {
    return isar.customLists.where().sortByIndex().findAllSync();
  }

  createNewList(String name) {
    List<CustomList> allLists = getLists();
    allLists.insert(0, CustomList(name, 0));
    isar.writeTxnSync(() {
      isar.customLists.putAllSync(allLists);
    });
    reindex(allLists);
  }

  deleteList(CustomList list) {
    isar.writeTxnSync(() {
      isar.customLists.deleteSync(list.id);
    });
    reindex(getLists());
  }

  reindex(List<CustomList> lists) {
    for (final (index, list) in lists.indexed) {
      list.index = index;
    }
    isar.writeTxnSync(() {
      isar.customLists.putAllSync(lists);
    });
    notifyListeners();
  }

  save(CustomList list) {
    isar.writeTxnSync(() {
      isar.customLists.putSync(list);
    });
    notifyListeners();
  }

  CustomList getList(int listId) {
    return isar.customLists.getSync(listId)!;
  }
}
