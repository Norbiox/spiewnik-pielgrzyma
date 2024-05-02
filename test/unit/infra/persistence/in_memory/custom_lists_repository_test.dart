import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/domain/custom_lists/model.dart';
import 'package:spiewnik_pielgrzyma/domain/custom_lists/repository.dart';
import 'package:spiewnik_pielgrzyma/infra/persistence/in_memory/custom_lists_repository.dart';

void main() {
  group('Test InMemoryCustomListRepository', () {
    test('save new custom list', () async {
      var repository = InMemoryCustomListRepository();
      var list = CustomList.create("Test");
      repository.save(list);
      expect(await repository.getById(list.id), list);
    });

    test('save existing custom list', () async {
      var repository = InMemoryCustomListRepository();
      var list = CustomList.create("Test");
      repository.save(list);
      list.rename("New name");
      repository.save(list);
      expect(await repository.getById(list.id), list);
    });

    test('exception raised when asked for non-existing list', () async {
      var repository = InMemoryCustomListRepository();
      expect(() => repository.getById("nope"),
          throwsA(isA<CustomListNotFoundException>()));
    });

    test('get all lists', () async {
      var repository = InMemoryCustomListRepository();
      var list1 = CustomList.create("Test1");
      var list2 = CustomList.create("Test2");
      repository.save(list1);
      repository.save(list2);
      expect(await repository.getAll(), [list1, list2]);
    });

    test('saveAll add new lists and overrides existing ones', () async {
      var repository = InMemoryCustomListRepository();
      var list1 = CustomList.create("Test1");
      var list2 = CustomList.create("Test2");
      repository.saveAll([list1, list2]);
      var list3 = CustomList.create("Test3");
      list1.rename("TestTest");
      repository.saveAll([list1, list3]);
      expect(await repository.getAll().then((elements) => elements.toSet()),
          {list1, list2, list3});
    });

    test('saveAll add new lists and overrides existing ones', () async {
      var repository = InMemoryCustomListRepository();
      var list1 = CustomList.create("Test1");
      var list2 = CustomList.create("Test2");
      repository.saveAll([list1, list2]);
      var list3 = CustomList.create("Test3");
      list1.rename("TestTest");
      repository.saveAll([list1, list3]);
      expect(await repository.getAll().then((elements) => elements.toSet()),
          {list1, list2, list3});
    });

    test('remove existing custom list', () async {
      var repository = InMemoryCustomListRepository();
      var list = CustomList.create("Test");
      repository.save(list);
      repository.remove(list);
      expect(await repository.getAll(), []);
    });

    test('exception raised when asked for removing unsaved list', () async {
      var repository = InMemoryCustomListRepository();
      var list = CustomList.create("Test");
      expect(() => repository.remove(list),
          throwsA(isA<CustomListNotFoundException>()));
    });
  });
}
