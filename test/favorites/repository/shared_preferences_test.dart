import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/favorites/repository/shared_preferences.dart';

void main() {
  // TestWidgetsFlutterBinding.ensureInitialized();
  // SharedPreferences? preference;
  // SharedPreferencesFavoritesRepository? repository;

  // setUp(() async {
  //   preference = await SharedPreferences.getInstance();
  //   repository = SharedPreferencesFavoritesRepository(preference!);
  //   SharedPreferences.setMockInitialValues({});
  // });

  group('Test SharedPreferencesFavoritesRepository', () {
    test('should add favorite', () async {
      SharedPreferences.setMockInitialValues({});
      SharedPreferences storage = await SharedPreferences.getInstance();
      SharedPreferencesFavoritesRepository repository =
          SharedPreferencesFavoritesRepository(storage);

      await repository.add("1");
      expect(await repository.isFavorite("1"), true);
    });

    test('should remove favorite', () async {
      SharedPreferences.setMockInitialValues({});
      SharedPreferences storage = await SharedPreferences.getInstance();
      SharedPreferencesFavoritesRepository repository =
          SharedPreferencesFavoritesRepository(storage);

      await repository.add("1");
      await repository.remove("1");
      expect(await repository.isFavorite("1"), false);
    });

    test('should get favorites', () async {
      SharedPreferences.setMockInitialValues({});
      SharedPreferences storage = await SharedPreferences.getInstance();
      SharedPreferencesFavoritesRepository repository =
          SharedPreferencesFavoritesRepository(storage);

      await repository.add("1");
      await repository.add("2");
      expect(await repository.getFavorites(), {"1", "2"});
    });
  });
}
