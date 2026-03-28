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

  void createNewList(String name) {
    List<CustomList> allLists = getLists();
    if (allLists.any((e) => e.name == name)) {
      throw Exception('List with name $name already exists');
    }
    CustomList list = CustomList(const Uuid().v4(), name);
    save(list);
  }

  void deleteList(CustomList list) {
    deleteCustomList(list, prefs);
    notifyListeners();
  }

  void archiveList(CustomList list) {
    archiveCustomList(list, prefs);
    notifyListeners();
  }

  void restoreList(CustomList list) {
    restoreCustomList(list, prefs);
    notifyListeners();
  }

  List<CustomList> getArchivedLists() {
    return loadArchivedCustomLists(prefs);
  }

  void reindex(List<CustomList> lists) {
    updateCustomListsOrder(lists, prefs);
    notifyListeners();
  }

  void save(CustomList list) {
    saveCustomList(list, prefs);
    notifyListeners();
  }

  CustomList getList(String listId) {
    return getLists().firstWhere((e) => e.id == listId);
  }
}
