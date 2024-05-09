import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/domain/hymns/model.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/search_engine.dart';
import 'package:spiewnik_pielgrzyma/domain/hymns/repository.dart';

class HymnsListProvider with ChangeNotifier {
  final HymnRepository hymnsRepository;

  HymnsListProvider(this.hymnsRepository);

  Future<List<Hymn>> searchHymns(String query,
      [bool favoritesOnly = false]) async {
    var hymns = await hymnsRepository.getAll();
    if (favoritesOnly) {
      hymns = hymns.where((element) => element.isFavorite == true).toList();
    }
    return HymnsSearchEngine().search(hymns, query);
  }

  Future<bool> toggleIsFavorite(Hymn hymn) async {
    hymn.toggleIsFavorite();
    hymnsRepository.save(hymn);
    notifyListeners();
    return hymn.isFavorite;
  }
}
