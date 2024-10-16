import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/search_engine.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';

class HymnsListProvider with ChangeNotifier {
  // final HymnRepository hymnsRepository;
  final Isar isar;

  HymnsListProvider(this.isar);

  Hymn getHymn(int id) => isar.hymns.getSync(id)!;

  List<Hymn> getAll() {
    return isar.hymns.where().findAllSync();
  }

  Hymn? getHymnById(int id) {
    return isar.hymns.getSync(id);
  }

  List<Hymn> getFavorites() {
    return isar.hymns.filter().isFavoriteEqualTo(true).findAllSync();
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
    await isar.writeTxn(() async {
      await isar.hymns.put(hymn);
    });
    notifyListeners();
    return hymn.isFavorite!;
  }
}
