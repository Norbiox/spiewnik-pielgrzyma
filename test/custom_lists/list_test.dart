// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/model/list.dart';
import 'package:spiewnik_pielgrzyma/hymns/model/hymn.dart';

void main() async {
  group('Test CustomList', () {
    test('add hymn to empty list', () {
      CustomList list = CustomList("test");
      list.add(Hymn(0, "0", "", "", "", "", []));
      expect(list.hymnNumbers.length, 1);
    });
  });

  test('is equatable', () {
    expect(CustomList("test") == CustomList("test"), true);
    expect(CustomList("test1") == CustomList("test"), false);
    expect(CustomList("test") == CustomList("test1"), false);
    expect(CustomList("test", ["1"]) == CustomList("test", ["1"]), true);
    expect(CustomList("test", ["1"]) == CustomList("test", []), false);
    expect(CustomList("test", ["1"]) == CustomList("test", ["2"]), false);
    expect(CustomList("test", ["1", "2"]) == CustomList("test", ["2"]), false);
    expect(
        CustomList("test", ["1", "2"]) == CustomList("test", ["1", "2"]), true);
    expect(CustomList("test", ["2", "1"]) == CustomList("test", ["1", "2"]),
        false);
  });
}
