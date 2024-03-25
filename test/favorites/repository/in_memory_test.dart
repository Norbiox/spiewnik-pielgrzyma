import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/in_memory.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // needed for access to assets

  group('Test InMemoryFavoritesRepository', () {
    final hymnsListProvider = HymnsListProvider();
    final repository =
        InMemoryFavoritesRepository(hymnsListProvider: hymnsListProvider);

    test('should add favorite', () async {
      await repository.add(hymnsListProvider.hymnsList[0]);
      expect(await repository.isFavorite(hymnsListProvider.hymnsList[0]), true);
    });

    test('should remove favorite', () async {
      await repository.add(hymnsListProvider.hymnsList[0]);
      await repository.remove(hymnsListProvider.hymnsList[0]);
      expect(
          await repository.isFavorite(hymnsListProvider.hymnsList[0]), false);
    });

    test('should get favorites', () async {
      await repository.add(hymnsListProvider.hymnsList[0]);
      await repository.add(hymnsListProvider.hymnsList[1]);
      expect(await repository.getFavorites(),
          {hymnsListProvider.hymnsList[0], hymnsListProvider.hymnsList[1]});
    });
  });
}
