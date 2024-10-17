import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/search_engine.dart';
import 'package:spiewnik_pielgrzyma/infra/db.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';

class HymnsListProvider with ChangeNotifier {
  final SharedPreferences prefs;
  final List<Hymn> hymns;

  HymnsListProvider(this.prefs, this.hymns);

  Hymn getHymn(int id) => hymns.firstWhere((element) => element.id == id);

  List<Hymn> getAll() {
    return hymns;
  }

  List<Hymn> getFavorites() {
    return hymns.where((element) => element.isFavorite).toList();
  }

  Future<List<Hymn>> searchHymns(List<Hymn> hymns, String query,
      [bool favoritesOnly = false]) async {
    if (favoritesOnly) {
      hymns = hymns.where((element) => element.isFavorite == true).toList();
    }
    return HymnsSearchEngine().search(hymns, query);
  }

  Future<bool> toggleIsFavorite(Hymn hymn) async {
    hymn.toggleIsFavorite();
    await saveHymnIsFavorite(prefs, hymn.id, hymn.isFavorite);
    notifyListeners();
    return hymn.isFavorite;
  }
}
