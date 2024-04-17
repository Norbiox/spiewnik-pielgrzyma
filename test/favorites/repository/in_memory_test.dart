import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/in_memory.dart';
import 'package:spiewnik_pielgrzyma/hymns/lib/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // needed for access to assets

  group('Test InMemoryFavoritesRepository', () {
    final hymnsListProvider = HymnsListProvider();

    test('should add favorite', () async {
      final repository =
          InMemoryFavoritesRepository(hymnsListProvider: hymnsListProvider);
      await repository.add(hymnsListProvider.hymnsList[0]);
      expect(await repository.isFavorite(hymnsListProvider.hymnsList[0]), true);
    });

    test('should remove favorite', () async {
      final repository =
          InMemoryFavoritesRepository(hymnsListProvider: hymnsListProvider);
      await repository.add(hymnsListProvider.hymnsList[0]);
      await repository.remove(hymnsListProvider.hymnsList[0]);
      expect(
          await repository.isFavorite(hymnsListProvider.hymnsList[0]), false);
    });

    test('should get favorites', () async {
      final repository =
          InMemoryFavoritesRepository(hymnsListProvider: hymnsListProvider);
      await repository.add(hymnsListProvider.hymnsList[0]);
      await repository.add(hymnsListProvider.hymnsList[1]);
      expect(await repository.getFavorites(),
          {hymnsListProvider.hymnsList[0], hymnsListProvider.hymnsList[1]});
    });

    test('hymns should be in order by number', () async {
      final repository =
          InMemoryFavoritesRepository(hymnsListProvider: hymnsListProvider);
      await repository.add(hymnsListProvider.hymnsList[22]);
      await repository.add(hymnsListProvider.hymnsList[11]);
      await repository.add(hymnsListProvider.hymnsList[13]);
      expect(await repository.getFavorites(), {
        hymnsListProvider.hymnsList[11],
        hymnsListProvider.hymnsList[13],
        hymnsListProvider.hymnsList[22]
      });
    });
  });
}
