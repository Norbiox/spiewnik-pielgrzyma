// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/domain/custom_lists/model.dart';

void main() async {
  group('Test CustomList', () {
    test('can be created using factory', () {
      withClock(Clock.fixed(DateTime(2024, 5, 1, 9, 15)), () {
        CustomList list = CustomList.create("Test List");
        expect(list.name, "Test List");
        expect(list.hymns, []);
        expect(list.createdAt, clock.now());
        expect(list.modifiedAt, clock.now());
      });
    });

    test('can be renamed', () {
      CustomList list = CustomList.create("Test List");
      list.rename("New name");
      expect(list.name, "New name");
    });

    test('renaming changes modification time', () {
      CustomList list = CustomList.create("Test List");
      withClock(Clock.fixed(DateTime(2024)), () {
        list.rename("New name");
        expect(list.modifiedAt, clock.now());
      });
    });

    test('new hymn can be added', () {
      CustomList list = CustomList.create("Test List");
      list.addHymn(1);
      expect(list.hymns, [1]);
    });

    test('hymn not added if already exists', () {
      CustomList list = CustomList.create("Test List");
      list.addHymn(1);
      expect(() => list.addHymn(1), throwsA(isA<Exception>()));
    });

    test('hymn can be removed', () {
      CustomList list = CustomList.create("Test List");
      list.addHymn(1);
      list.removeHymn(1);
      expect(list.hymns, []);
    });

    test('hymn cannot be removed if not exists', () {
      CustomList list = CustomList.create("Test List");
      expect(() => list.removeHymn(1), throwsA(isA<Exception>()));
    });

    test('hymns ordering can be changed', () {
      CustomList list = CustomList.create("Test List");
      list.addHymn(1);
      list.addHymn(2);
      list.addHymn(3);
      list.changeHymnOrdering(2, 0);
      expect(list.hymns, [2, 1, 3]);
    });
  });
}
