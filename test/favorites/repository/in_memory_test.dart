import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/in_memory.dart';

void main() {
  group('Test InMemoryFavoritesRepository', () {
    final repository = InMemoryFavoritesRepository();

    test('should add favorite', () async {
      await repository.add("1");
      expect(await repository.isFavorite("1"), true);
    });

    test('should remove favorite', () async {
      await repository.add("1");
      await repository.remove("1");
      expect(await repository.isFavorite("1"), false);
    });

    test('should get favorites', () async {
      await repository.add("1");
      await repository.add("2");
      expect(await repository.getFavorites(), {"1", "2"});
    });
  });
}
