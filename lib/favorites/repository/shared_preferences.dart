import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/abstract.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list.dart';

class SharedPreferencesFavoritesRepository extends ChangeNotifier
    implements FavoritesRepository {
  final HymnsListProvider hymnsListProvider;
  final SharedPreferences storage;
  final String _key = 'favoriteHymns';

  SharedPreferencesFavoritesRepository(this.storage, this.hymnsListProvider) {
    if (!storage.containsKey(_key)) {
      storage.setStringList(_key, <String>[]);
    }
    notifyListeners();
  }

  @override
  Future<bool> isFavorite(Hymn hymn) async {
    return await _getFavoritesSet()
        .then((value) => value.contains(hymn.number));
  }

  @override
  Future<void> add(Hymn hymn) async {
    final favorites = await _getFavoritesSet();
    if (favorites.contains(hymn.number)) {
      return;
    }

    favorites.add(hymn.number);
    storage.setStringList(_key, favorites.toList());
    notifyListeners();
  }

  @override
  Future<void> remove(Hymn hymn) async {
    final favorites = await _getFavoritesSet();
    if (!favorites.contains(hymn.number)) {
      return;
    }
    favorites.remove(hymn.number);
    storage.setStringList(_key, favorites.toList());
    notifyListeners();
  }

  @override
  Future<List<Hymn>> getFavorites() async {
    if (!storage.containsKey(_key)) {
      return <Hymn>[];
    }
    List<Hymn> hymns = storage
        .getStringList(_key)!
        .map((e) => hymnsListProvider.hymnsList
            .firstWhere((element) => element.number == e))
        .toList();
    hymns.sort((a, b) => a.index.compareTo(b.index));
    return hymns;
  }

  Future<Set<String>> _getFavoritesSet() async {
    return await getFavorites()
        .then((value) => value.map((e) => e.number).toSet());
  }
}
