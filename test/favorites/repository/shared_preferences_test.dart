import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized(); // needed for access to assets
  SharedPreferences.setMockInitialValues({});

  final hymnsListProvider = HymnsListProvider();
  final SharedPreferencesFavoritesRepository repository =
      await SharedPreferences.getInstance().then((value) {
    return SharedPreferencesFavoritesRepository(value, hymnsListProvider);
  });

  group('Test SharedPreferencesFavoritesRepository', () {
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
