import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:spiewnik_pielgrzyma/objectbox.g.dart';

class CustomListProvider with ChangeNotifier {
  final Box<CustomList> customListBox;
  final Query<CustomList> getAllQuery;

  CustomListProvider._internal(this.customListBox, this.getAllQuery);

  factory CustomListProvider(Box<CustomList> customListBox) {
    return CustomListProvider._internal(
      customListBox,
      (customListBox.query()..order(CustomList_.index)).build(),
    );
  }

  List<CustomList> getLists() {
    return getAllQuery.find();
  }

  createNewList(String name) {
    List<CustomList> allLists = getLists();
    allLists.insert(0, CustomList(name, 0));
    reindex(allLists);
  }

  deleteList(CustomList list) {
    customListBox.remove(list.id);
    reindex(getLists());
  }

  reindex(List<CustomList> lists) {
    for (final (index, list) in lists.indexed) {
      list.index = index;
    }
    customListBox.putMany(lists);
    notifyListeners();
  }

  save(CustomList list) {
    customListBox.put(list);
    notifyListeners();
  }
}
