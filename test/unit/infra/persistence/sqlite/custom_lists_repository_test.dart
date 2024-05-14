import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/domain/custom_lists/model.dart';
import 'package:spiewnik_pielgrzyma/domain/custom_lists/repository.dart';
import 'package:spiewnik_pielgrzyma/infra/persistence/sqlite/custom_lists_repository.dart';
import 'package:spiewnik_pielgrzyma/infra/persistence/sqlite/database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  WidgetsFlutterBinding.ensureInitialized();

  group('Test SqliteCustomListRepository', () {
    test('cannot save new custom list alone', () async {
      var repository = await SqliteCustomListRepository.create(
          await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
              options: databaseOptions));
      var list = CustomList.create("Test");
      expect(() => repository.save(list),
          throwsA(isA<CustomListNotFoundException>()));
    });

    test('save existing custom list', () async {
      var repository = await SqliteCustomListRepository.create(
          await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
              options: databaseOptions));
      var list = CustomList.create("Test");
      await repository.saveAll([list]);
      list.rename("New name");
      await repository.save(list);
      expect(await repository.getById(list.id), list);
    });

    test('exception raised when asked for non-existing list', () async {
      var repository = await SqliteCustomListRepository.create(
          await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
              options: databaseOptions));
      expect(() => repository.getById("nope"),
          throwsA(isA<CustomListNotFoundException>()));
    });

    test('get all lists', () async {
      var repository = await SqliteCustomListRepository.create(
          await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
              options: databaseOptions));
      var lists = [CustomList.create("Test1"), CustomList.create("Test2")];
      await repository.saveAll(lists);
      expect(await repository.getAll(), lists);
    });

    test('saveAll add new lists and overrides existing ones', () async {
      var repository = await SqliteCustomListRepository.create(
          await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
              options: databaseOptions));
      var list1 = CustomList.create("Test1");
      var list2 = CustomList.create("Test2");
      await repository.saveAll([list1, list2]);
      var list3 = CustomList.create("Test3");
      list1.rename("TestTest");
      await repository.saveAll([list1, list3]);
      expect(await repository.getAll().then((elements) => elements.toSet()),
          {list1, list3});
      expect(await repository.getById(list1.id).then((value) => value.name),
          "TestTest");
    });

    test('remove existing custom list', () async {
      var repository = await SqliteCustomListRepository.create(
          await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
              options: databaseOptions));
      var list = CustomList.create("Test");
      await repository.saveAll([list]);
      await repository.remove(list);
      expect(await repository.getAll(), []);
    });

    test('ordering after removing existing custom list', () async {
      var repository = await SqliteCustomListRepository.create(
          await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
              options: databaseOptions));
      var lists = [
        CustomList.create("Test1"),
        CustomList.create("Test2"),
        CustomList.create("Test3")
      ];
      await repository.saveAll(lists);
      await repository.remove(lists[1]);
      expect(await repository.getAll(), [lists[0], lists[2]]);
    });
    test('exception raised when asked for removing unsaved list', () async {
      var repository = await SqliteCustomListRepository.create(
          await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
              options: databaseOptions));
      var list = CustomList.create("Test");
      expect(() => repository.remove(list),
          throwsA(isA<CustomListNotFoundException>()));
    });
  });
}
