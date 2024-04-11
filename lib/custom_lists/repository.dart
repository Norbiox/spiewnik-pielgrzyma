import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/list.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list.dart';

class CustomListsRepository extends ChangeNotifier {
  final SharedPreferences storage;
  final HymnsListProvider hymnsListProvider;
  final String _key = 'customLists';

  CustomListsRepository(this.storage, this.hymnsListProvider) {
    if (!storage.containsKey(_key)) {
      storage.setStringList(_key, <String>[]);
    }
  }

  List<CustomList> get customLists {
    return storage
        .getStringList(_key)!
        .map((listName) => _loadList(listName))
        .toList();
  }

  CustomList _loadList(String name) {
    List<String> hymnsNumbers = storage.getStringList(_customListKey(name))!;
    return CustomList(name, hymnsNumbers);
  }

  String _customListKey(String name) {
    return "customList_$name";
  }

  void save(List<CustomList> lists) {
    for (final customList in lists) {
      storage.setStringList(
          _customListKey(customList.name), customList.hymnNumbers);
    }
    storage.setStringList(_key, lists.map((e) => e.name).toList());
    notifyListeners();
  }

  void add(CustomList list) {
    final currentLists = customLists;
    currentLists.add(list);
    save(currentLists);
  }
}
