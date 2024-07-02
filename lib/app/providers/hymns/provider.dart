import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/search_engine.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:spiewnik_pielgrzyma/objectbox.g.dart';

class HymnsListProvider with ChangeNotifier {
  // final HymnRepository hymnsRepository;
  final Box<Hymn> hymnsBox;

  HymnsListProvider(this.hymnsBox);

  Future<List<Hymn>> searchHymns(String query,
      [bool favoritesOnly = false]) async {
    var hymns = hymnsBox.getAll();
    if (favoritesOnly) {
      hymns = hymns.where((element) => element.isFavorite == true).toList();
    }
    return HymnsSearchEngine().search(hymns, query);
  }

  Future<bool> toggleIsFavorite(Hymn hymn) async {
    hymn.toggleIsFavorite();
    hymnsBox.put(hymn);
    notifyListeners();
    return hymn.isFavorite!;
  }
}
