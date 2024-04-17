import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/abstract.dart';
import 'package:spiewnik_pielgrzyma/hymns/model/hymn.dart';
import 'package:spiewnik_pielgrzyma/hymns/lib/provider.dart';

class InMemoryFavoritesRepository extends ChangeNotifier
    implements FavoritesRepository {
  final HymnsListProvider hymnsListProvider;
  final Set<String> favorites = {};

  InMemoryFavoritesRepository({required this.hymnsListProvider});

  @override
  Future<bool> isFavorite(Hymn hymn) async {
    return favorites.contains(hymn.number);
  }

  @override
  Future<void> add(Hymn hymn) async {
    favorites.add(hymn.number);
    notifyListeners();
  }

  @override
  Future<void> remove(Hymn hymn) async {
    favorites.remove(hymn.number);
    notifyListeners();
  }

  @override
  Future<List<Hymn>> getFavorites() async {
    return List<String>.from(favorites)
        .map((e) => hymnsListProvider.hymnsList
            .firstWhere((element) => element.number == e))
        .toList();
  }
}
