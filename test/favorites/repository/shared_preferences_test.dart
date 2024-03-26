import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized(); // needed for access to assets
  SharedPreferences.setMockInitialValues({});

  group('Test SharedPreferencesFavoritesRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should add favorite', () async {
      final SharedPreferencesFavoritesRepository repository =
          await SharedPreferences.getInstance().then((value) {
        return SharedPreferencesFavoritesRepository(value, HymnsListProvider());
      });

      final hymnsList = await loadHymnsList();

      await repository.add(hymnsList[0]);
      expect(await repository.isFavorite(hymnsList[0]), true);
    });

    test('should remove favorite', () async {
      final SharedPreferencesFavoritesRepository repository =
          await SharedPreferences.getInstance().then((value) {
        return SharedPreferencesFavoritesRepository(value, HymnsListProvider());
      });

      final hymnsList = await loadHymnsList();

      await repository.add(hymnsList[0]);
      await repository.remove(hymnsList[0]);
      expect(await repository.isFavorite(hymnsList[0]), false);
    });

    test('should get favorites', () async {
      final SharedPreferencesFavoritesRepository repository =
          await SharedPreferences.getInstance().then((value) {
        return SharedPreferencesFavoritesRepository(value, HymnsListProvider());
      });

      final hymnsList = await loadHymnsList();

      await repository.add(hymnsList[0]);
      await repository.add(hymnsList[1]);
      expect(await repository.getFavorites(), {hymnsList[0], hymnsList[1]});
    });

    test('hymns should be in order by number', () async {
      final SharedPreferencesFavoritesRepository repository =
          await SharedPreferences.getInstance().then((value) {
        return SharedPreferencesFavoritesRepository(value, HymnsListProvider());
      });

      final hymnsList = await loadHymnsList();

      await repository.add(hymnsList[22]);
      await repository.add(hymnsList[11]);
      await repository.add(hymnsList[13]);
      expect(await repository.getFavorites(),
          {hymnsList[11], hymnsList[13], hymnsList[22]});
    });
  });
}
