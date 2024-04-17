import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/model/list.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/model/list_of_lists.dart';
import 'package:spiewnik_pielgrzyma/hymns/lib/provider.dart';

class NotACustomListKey extends TypeError {}

class CustomListsRepository extends ChangeNotifier {
  final SharedPreferences storage;
  final HymnsListProvider hymnsListProvider;
  final String _key = 'customLists';

  CustomListsRepository(this.storage, this.hymnsListProvider) {
    if (!storage.containsKey(_key)) {
      storage.setStringList(_key, <String>[]);
    }
  }

  void save(ListOfCustomLists lists) {
    // save existing lists
    for (final customList in lists.elements) {
      storage.setStringList(
          customListKey(customList.name), customList.hymnNumbers);
    }
    storage.setStringList(_key, lists.elements.map((e) => e.name).toList());
    // remove old lists
    final customListNames = lists.elements.map((e) => e.name);
    final keysToBeRemoved = storage.getKeys().where((el) =>
        el.startsWith("customList_") &&
        !customListNames.contains(_getListNameFromKey(el)));
    for (final key in keysToBeRemoved) {
      storage.remove(key);
    }
    notifyListeners();
  }

  ListOfCustomLists get customLists {
    return ListOfCustomLists(storage
        .getStringList(_key)!
        .map((listName) => _loadList(listName))
        .toList());
  }

  CustomList _loadList(String name) {
    List<String> hymnsNumbers = storage.getStringList(customListKey(name))!;
    return CustomList(name, hymnsNumbers);
  }

  String customListKey(String name) {
    return "customList_$name";
  }

  String _getListNameFromKey(String key) {
    if (!key.startsWith("customList_")) {
      throw NotACustomListKey();
    }
    return key.split('_').sublist(1).join('_');
  }

  void cleanup() {
    storage
        .getKeys()
        .where((element) => element.startsWith("customList_"))
        .map((e) => storage.remove(e));
    storage.remove(_key);
  }
}
