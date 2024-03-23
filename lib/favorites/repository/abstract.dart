abstract class FavoritesRepository {
  Future<bool> isFavorite(String id);
  Future<void> add(String id);
  Future<void> remove(String id);
  Future<List<String>> getFavorites();
}
