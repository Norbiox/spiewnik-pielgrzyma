import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/list.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/repository.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Test CustomListsRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should return empty list by default', () async {
      final CustomListsRepository repository =
          await SharedPreferences.getInstance().then(
              (value) => CustomListsRepository(value, HymnsListProvider()));

      expect(repository.customLists, <CustomList>[]);
    });

    test('should save list with empty list', () async {
      final CustomListsRepository repository =
          await SharedPreferences.getInstance().then(
              (value) => CustomListsRepository(value, HymnsListProvider()));

      repository.save([const CustomList("First", [])]);

      expect(repository.customLists, [const CustomList("First", [])]);
    });

    test('should save list with empty list of name containing space char',
        () async {
      final CustomListsRepository repository =
          await SharedPreferences.getInstance().then(
              (value) => CustomListsRepository(value, HymnsListProvider()));

      repository.save([const CustomList("First list", [])]);

      expect(repository.customLists, [const CustomList("First list", [])]);
    });

    test('should save list with updated hymns', () async {
      final CustomListsRepository repository =
          await SharedPreferences.getInstance().then(
              (value) => CustomListsRepository(value, HymnsListProvider()));

      repository.save([const CustomList("First list", [])]);
      List<CustomList> list = repository.customLists;
      list[0].add(const Hymn(0, "0", "", "", "", "", []));
      repository.save(list);

      expect(repository.customLists, [
        const CustomList("First list", ["0"])
      ]);
    });
  });
}
