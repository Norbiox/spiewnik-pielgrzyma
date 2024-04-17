// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/model/list.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/model/list_of_lists.dart';
import 'package:spiewnik_pielgrzyma/hymns/model/hymn.dart';

void main() async {
  group('Test ListOfCustomLists', () {
    test('should be able to be created as empty list', () {
      ListOfCustomLists list = ListOfCustomLists();
      expect(list.length, 0);
    });

    test('should be able to add list', () {
      ListOfCustomLists list = ListOfCustomLists();
      list.add(CustomList("test"));
      expect(list.length, 1);
    });

    test('should be able to remove list', () {
      ListOfCustomLists list = ListOfCustomLists();
      list.add(CustomList("test"));
      list.remove(list[0]);
      expect(list.length, 0);
    });

    test('should prevent from adding second item with same name', () {
      ListOfCustomLists list = ListOfCustomLists();
      list.add(CustomList("test"));
      expect(() => list.add(CustomList("test", [])), throwsArgumentError);
    });

    test('add hymn to the second list', () {
      ListOfCustomLists list = ListOfCustomLists();
      list.add(CustomList("test1"));
      list.add(CustomList("test2"));
      list[1].add(const Hymn(0, "12", "", "", "", "", []));
      expect(list[1].hymnNumbers.length, 1);
    });

    test('move list to the beginning of lists', () {
      ListOfCustomLists list = ListOfCustomLists(
          [CustomList("test1"), CustomList("test2"), CustomList("test3")]);
      list.setIndex(list[2], 0);
      expect(list[0].name, equals("test3"));
      expect(list[1].name, equals("test1"));
      expect(list[2].name, equals("test2"));
    });

    test('move list to the end of lists', () {
      ListOfCustomLists list = ListOfCustomLists(
          [CustomList("test1"), CustomList("test2"), CustomList("test3")]);
      list.setIndex(list[0], 2);
      expect(list[0].name, equals("test2"));
      expect(list[1].name, equals("test3"));
      expect(list[2].name, equals("test1"));
    });

    test('move list from the beginning to the center of lists', () {
      ListOfCustomLists list = ListOfCustomLists(
          [CustomList("test1"), CustomList("test2"), CustomList("test3")]);
      list.setIndex(list[0], 1);
      expect(list[0].name, equals("test2"));
      expect(list[1].name, equals("test1"));
      expect(list[2].name, equals("test3"));
    });

    test('move list from the end to the center of lists', () {
      ListOfCustomLists list = ListOfCustomLists(
          [CustomList("test1"), CustomList("test2"), CustomList("test3")]);
      list.setIndex(list[2], 1);
      expect(list[0].name, equals("test1"));
      expect(list[1].name, equals("test3"));
      expect(list[2].name, equals("test2"));
    });

    test('rename list', () {
      ListOfCustomLists list = ListOfCustomLists(
          [CustomList("test1"), CustomList("test2"), CustomList("test3")]);
      list.rename(list[1], "test4");
      expect(list[1].name, equals("test4"));
    });

    test('should throw error on renaming when new name already exists', () {
      ListOfCustomLists list = ListOfCustomLists(
          [CustomList("test1"), CustomList("test2"), CustomList("test3")]);
      expect(() => list.rename(list[1], "test1"), throwsArgumentError);
    });
  });
}
