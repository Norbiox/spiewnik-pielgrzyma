import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/abstract.dart';

class SharedPreferencesFavoritesRepository implements FavoritesRepository {
  late SharedPreferences _storage;
  final String _key = 'favoriteHymns';

  SharedPreferencesFavoritesRepository(SharedPreferences storage) {
    _storage = storage;
    if (!_storage.containsKey(_key)) {
      _storage.setStringList(_key, <String>[]);
    }
  }

  @override
  Future<bool> isFavorite(String id) async {
    return await _getFavoritesSet().then((value) => value.contains(id));
  }

  @override
  Future<List<String>> getFavorites() async {
    if (!_storage.containsKey(_key)) {
      return <String>[];
    }
    return _storage.getStringList(_key)!.toList();
  }

  @override
  Future<void> add(String id) async {
    final favorites = await _getFavoritesSet();
    if (favorites.contains(id)) {
      return;
    }

    favorites.add(id);
    _storage.setStringList(_key, favorites.toList());
  }

  @override
  Future<void> remove(String id) async {
    final favorites = await _getFavoritesSet();
    if (!favorites.contains(id)) {
      return;
    }
    favorites.remove(id);
    _storage.setStringList(_key, favorites.toList());
  }

  Future<Set<String>> _getFavoritesSet() async {
    return await getFavorites().then((value) => value.toSet());
  }
}
