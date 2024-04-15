// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/list.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';

void main() async {
  group('Test CustomList', () {
    test('add hymn to empty list', () {
      CustomList list = CustomList("test");
      list.add(const Hymn(0, "0", "", "", "", "", []));
      expect(list.hymnNumbers.length, 1);
    });
  });

  group('Test CustomLists', () {
    test('is equatable', () {
      expect(CustomList("test") == CustomList("test"), true);
      expect(CustomList("test1") == CustomList("test"), false);
      expect(CustomList("test") == CustomList("test1"), false);
      expect(CustomList("test", ["1"]) == CustomList("test", ["1"]), true);
      expect(CustomList("test", ["1"]) == CustomList("test", []), false);
      expect(CustomList("test", ["1"]) == CustomList("test", ["2"]), false);
      expect(
          CustomList("test", ["1", "2"]) == CustomList("test", ["2"]), false);
      expect(CustomList("test", ["1", "2"]) == CustomList("test", ["1", "2"]),
          true);
      expect(CustomList("test", ["2", "1"]) == CustomList("test", ["1", "2"]),
          false);
    });

    test('should be able to be created as empty list', () {
      CustomLists list = CustomLists();
      expect(list.length, 0);
    });

    test('should be able to add list', () {
      CustomLists list = CustomLists();
      list.add(CustomList("test"));
      expect(list.length, 1);
    });

    test('should be able to remove list', () {
      CustomLists list = CustomLists();
      list.add(CustomList("test"));
      list.remove(list[0]);
      expect(list.length, 0);
    });

    test('should prevent from adding second item with same name', () {
      CustomLists list = CustomLists();
      list.add(CustomList("test"));
      expect(() => list.add(CustomList("test", [])), throwsArgumentError);
    });

    test('should prevent from setting item with name that already exists', () {
      CustomLists list = CustomLists();
      list.add(CustomList("test1"));
      list.add(CustomList("test2"));
      expect(() => {list[0] = CustomList("test2")}, throwsArgumentError);
      expect(() => {list[2] = CustomList("test2")}, throwsArgumentError);
    });

    test('should not prevent from resetting item with same name', () {
      CustomLists list = CustomLists();
      list.add(CustomList("test1"));
      expect(() => {list[0] = CustomList("test1")}, returnsNormally);
    });

    test('add hymn to the second list', () {
      CustomLists list = CustomLists();
      list.add(CustomList("test1"));
      list.add(CustomList("test2"));
      list
          .firstWhere((element) => element.name == "test2")
          .add(const Hymn(0, "12", "", "", "", "", []));
      expect(
          list
              .firstWhere((element) => element.name == "test2")
              .hymnNumbers
              .length,
          1);
    });
  });
}
