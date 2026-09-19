import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';

void main() {
  group('moveHymnBefore', () {
    test('moves a hymn in front of another', () {
      final list = CustomList('id', 'L', hymnsIds: [1, 2, 3, 4]);
      list.moveHymnBefore(4, 2);
      expect(list.hymnsIds, [1, 4, 2, 3]);
    });

    test('a null target moves the hymn to the end', () {
      final list = CustomList('id', 'L', hymnsIds: [1, 2, 3]);
      list.moveHymnBefore(1, null);
      expect(list.hymnsIds, [2, 3, 1]);
    });

    test('survives a concurrent insertion, which an index would not', () {
      // The user drags hymn 4 in front of hymn 2. Meanwhile someone else
      // prepends hymn 9, shifting every index by one.
      final concurrent = CustomList('id', 'L', hymnsIds: [9, 1, 2, 3, 4]);
      concurrent.moveHymnBefore(4, 2);
      expect(concurrent.hymnsIds, [9, 1, 4, 2, 3]);
    });

    test('ignores a hymn that is no longer in the list', () {
      final list = CustomList('id', 'L', hymnsIds: [1, 2]);
      list.moveHymnBefore(7, 1);
      expect(list.hymnsIds, [1, 2]);
    });

    test('appends when the target is no longer in the list', () {
      final list = CustomList('id', 'L', hymnsIds: [1, 2, 3]);
      list.moveHymnBefore(1, 99);
      expect(list.hymnsIds, [2, 3, 1]);
    });
  });

  group('moveArchivedHymnBefore', () {
    test('reorders the archive independently', () {
      final list =
          CustomList('id', 'L', hymnsIds: [1], archivedHymnsIds: [5, 6, 7]);
      list.moveArchivedHymnBefore(7, 5);
      expect(list.archivedHymnsIds, [7, 5, 6]);
      expect(list.hymnsIds, [1]);
    });
  });
}
