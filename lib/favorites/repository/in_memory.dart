import 'package:spiewnik_pielgrzyma/favorites/repository/abstract.dart';

class InMemoryFavoritesRepository implements FavoritesRepository {
  final Set<String> favorites = {};

  InMemoryFavoritesRepository();

  @override
  Future<bool> isFavorite(String id) async {
    return favorites.contains(id);
  }

  @override
  Future<void> add(String id) async {
    favorites.add(id);
  }

  @override
  Future<void> remove(String id) async {
    favorites.remove(id);
  }

  @override
  Future<List<String>> getFavorites() async {
    return List<String>.from(favorites);
  }
}
