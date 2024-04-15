import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/list.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/repository.dart';
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

      expect(repository.customLists.length, 0);
    });

    test('saves empty list of custom lists', () async {
      final CustomListsRepository repository =
          await SharedPreferences.getInstance().then(
              (value) => CustomListsRepository(value, HymnsListProvider()));

      CustomLists list = CustomLists();
      repository.save(list);

      expect(repository.customLists.length, 0);
    });

    test('saves list with one custom list', () async {
      final CustomListsRepository repository =
          await SharedPreferences.getInstance().then(
              (value) => CustomListsRepository(value, HymnsListProvider()));

      CustomLists list = CustomLists();
      list.add(CustomList("test", ["1", "2"]));
      repository.save(list);

      expect(repository.customLists.length, 1);
      expect(repository.customLists[0], equals(CustomList("test", ["1", "2"])));
    });

    test('saves list with two custom lists', () async {
      final CustomListsRepository repository =
          await SharedPreferences.getInstance().then(
              (value) => CustomListsRepository(value, HymnsListProvider()));

      CustomLists list = CustomLists();
      list.add(CustomList("test1"));
      list.add(CustomList("test2"));
      repository.save(list);

      expect(repository.customLists.length, 2);
    });

    //   test('saves list with two custom lists after reordering', () async {
    //     final CustomListsRepository repository =
    //         await SharedPreferences.getInstance().then(
    //             (value) => CustomListsRepository(value, HymnsListProvider()));

    //     CustomLists list = CustomLists();
    //     list.add(CustomList("test1"));
    //     list.add(CustomList("test2"));
    //     repository.save(list);

    //     CustomList test2List = list.removeAt(1);

    //     list.insert(0, test2List);
    //     repository.save(list);

    //     expect(
    //         repository.customLists ==
    //             [CustomList("test2"), CustomList("test1")],
    //         true);
    //   });
  });
}
