import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/infra/db.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';

class CustomListProvider with ChangeNotifier {
  SharedPreferences prefs;

  CustomListProvider(this.prefs);

  List<CustomList> getLists() {
    return loadCustomLists(prefs);
  }

  createNewList(String name) {
    List<CustomList> allLists = getLists();
    if (allLists.any((e) => e.name == name)) {
      throw Exception('List with name $name already exists');
    }
    CustomList list = CustomList(const Uuid().v4(), name);
    save(list);
  }

  deleteList(CustomList list) {
    deleteCustomList(list, prefs);
    notifyListeners();
  }

  reindex(List<CustomList> lists) {
    updateCustomListsOrder(lists, prefs);
    notifyListeners();
  }

  save(CustomList list) {
    saveCustomList(list, prefs);
    notifyListeners();
  }

  CustomList getList(String listId) {
    return getLists().firstWhere((e) => e.id == listId);
  }
}
