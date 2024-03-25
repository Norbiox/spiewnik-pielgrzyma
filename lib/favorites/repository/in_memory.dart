import 'package:flutter/material.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/abstract.dart';

class InMemoryFavoritesRepository extends ChangeNotifier
    implements FavoritesRepository {
  final Set<String> favorites = {};

  InMemoryFavoritesRepository();

  @override
  Future<bool> isFavorite(String id) async {
    return favorites.contains(id);
  }

  @override
  Future<void> add(String id) async {
    favorites.add(id);
    notifyListeners();
  }

  @override
  Future<void> remove(String id) async {
    favorites.remove(id);
    notifyListeners();
  }

  @override
  Future<List<String>> getFavorites() async {
    return List<String>.from(favorites);
  }
}
