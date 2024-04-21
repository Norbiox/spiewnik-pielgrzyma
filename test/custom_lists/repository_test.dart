import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/model/list.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/model/list_of_lists.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/repository/list_of_lists.dart';
import 'package:spiewnik_pielgrzyma/hymns/model/hymn.dart';
import 'package:spiewnik_pielgrzyma/hymns/lib/provider.dart';

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

      ListOfCustomLists list = ListOfCustomLists();
      repository.save(list);

      expect(repository.customLists.length, 0);
    });

    test('saves list with one custom list', () async {
      final CustomListsRepository repository =
          await SharedPreferences.getInstance().then(
              (value) => CustomListsRepository(value, HymnsListProvider()));

      ListOfCustomLists list = ListOfCustomLists([
        CustomList("test", ["1", "2"])
      ]);
      repository.save(list);

      expect(repository.customLists.length, 1);
      expect(repository.customLists[0], equals(CustomList("test", ["1", "2"])));
    });

    test('saves list with two custom lists', () async {
      final CustomListsRepository repository =
          await SharedPreferences.getInstance().then(
              (value) => CustomListsRepository(value, HymnsListProvider()));

      ListOfCustomLists list =
          ListOfCustomLists([CustomList("test1"), CustomList("test2")]);
      repository.save(list);

      expect(repository.customLists.length, 2);
    });

    test('saves list after change - add hymn to a list', () async {
      final CustomListsRepository repository =
          await SharedPreferences.getInstance().then(
              (value) => CustomListsRepository(value, HymnsListProvider()));

      ListOfCustomLists list = ListOfCustomLists([
        CustomList("test", ["1", "2"])
      ]);
      repository.save(list);

      list[0].add(Hymn(0, "3", "filename", "title", "group", "subgroup", []));
      repository.save(list);

      expect(repository.customLists.length, 1);
      expect(repository.customLists[0],
          equals(CustomList("test", ["1", "2", "3"])));
    });

    test('saves list after change - remove hymn from list', () async {
      final CustomListsRepository repository =
          await SharedPreferences.getInstance().then(
              (value) => CustomListsRepository(value, HymnsListProvider()));

      ListOfCustomLists list = ListOfCustomLists([
        CustomList("test", ["1", "2"])
      ]);
      repository.save(list);

      list[0].remove(Hymn(1, "1", "", "", "", "", []));
      repository.save(list);

      expect(repository.customLists.length, 1);
      expect(repository.customLists[0], equals(CustomList("test", ["2"])));
    });

    test('no residues are left in storage after custom list is removed',
        () async {
      SharedPreferences storage = await SharedPreferences.getInstance();
      final CustomListsRepository repository =
          CustomListsRepository(storage, HymnsListProvider());

      ListOfCustomLists list = ListOfCustomLists([
        CustomList("test", ["1", "2"])
      ]);
      repository.save(list);

      list.remove(CustomList("test"));
      repository.save(list);

      expect(repository.customLists.length, 0);
      expect(storage.getKeys().contains(repository.customListKey("test")),
          equals(false));
    });

    test('add one list and remove other', () async {
      final CustomListsRepository repository =
          await SharedPreferences.getInstance().then(
              (value) => CustomListsRepository(value, HymnsListProvider()));

      ListOfCustomLists list = ListOfCustomLists([
        CustomList("test", ["1", "2"])
      ]);
      repository.save(list);

      list.add(CustomList("new list", ["3", "4"]));
      list.remove(CustomList("test"));
      repository.save(list);

      expect(repository.customLists.length, 1);
      expect(repository.customLists[0].name, "new list");
      expect(repository.customLists[0].hymnNumbers, ["3", "4"]);
    });
  });
}
