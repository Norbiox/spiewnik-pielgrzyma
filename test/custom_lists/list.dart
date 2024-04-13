import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/list.dart';

void main() async {
  group('Test CustomLists', () {
    test('should be able to be created as empty list', () {
      CustomLists list = CustomLists();
      expect(list.length, 0);
    });

    test('should be able to add list', () {
      CustomLists list = CustomLists();
      list.add(const CustomList("test", []));
      expect(list.length, 1);
    });

    test('should be able to remove list', () {
      CustomLists list = CustomLists();
      list.add(const CustomList("test", []));
      list.remove(list[0]);
      expect(list.length, 0);
    });

    test('should prevent from adding second item with same name', () {
      CustomLists list = CustomLists();
      list.add(const CustomList("test", []));
      expect(() => list.add(const CustomList("test", [])), throwsArgumentError);
    });

    test('should prevent from setting item with name that already exists', () {
      CustomLists list = CustomLists();
      list.add(const CustomList("test1", []));
      list.add(const CustomList("test2", []));
      expect(
          () => {list[0] = const CustomList("test2", [])}, throwsArgumentError);
      expect(
          () => {list[2] = const CustomList("test2", [])}, throwsArgumentError);
    });

    test('should not prevent from resetting item with same name', () {
      CustomLists list = CustomLists();
      list.add(const CustomList("test1", []));
      expect(() => {list[0] = const CustomList("test1", [])}, returnsNormally);
    });
  });
}
