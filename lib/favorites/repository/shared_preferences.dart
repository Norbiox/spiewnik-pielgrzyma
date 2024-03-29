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
  late Set<String> _favorites = {};

  SharedPreferencesFavoritesRepository(this.storage, this.hymnsListProvider) {
    if (!storage.containsKey(_key)) {
      storage.setStringList(_key, <String>[]);
    }
    _favorites = storage.getStringList(_key)!.toSet();
    notifyListeners();
  }

  @override
  Future<bool> isFavorite(Hymn hymn) async {
    return _favorites.contains(hymn.number);
  }

  @override
  Future<void> add(Hymn hymn) async {
    if (_favorites.contains(hymn.number)) {
      return;
    }

    _favorites.add(hymn.number);
    storage.setStringList(_key, _favorites.toList());
    notifyListeners();
  }

  @override
  Future<void> remove(Hymn hymn) async {
    if (!_favorites.contains(hymn.number)) {
      return;
    }

    _favorites.remove(hymn.number);
    storage.setStringList(_key, _favorites.toList());
    notifyListeners();
  }

  @override
  Future<List<Hymn>> getFavorites() async {
    List<Hymn> hymns = _favorites
        .map((e) => hymnsListProvider.hymnsList
            .firstWhere((element) => element.number == e))
        .toList();
    hymns.sort((a, b) => a.index.compareTo(b.index));
    return hymns;
  }
}
