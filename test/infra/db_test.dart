import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/infra/db.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('archiveCustomList', () {
    test('moves list from active to archived keys', () {
      final list = CustomList('abc', 'My List', hymnsIds: [1, 2, 3]);
      saveCustomList(list, prefs);

      archiveCustomList(list, prefs);

      // Active keys removed
      expect(prefs.getStringList('customLists'), isEmpty);
      expect(prefs.getString('customList:name:abc'), isNull);
      expect(prefs.getStringList('customList:hymnsIds:abc'), isNull);

      // Archived keys present
      expect(prefs.getStringList('archivedCustomLists'), ['abc']);
      expect(prefs.getString('archivedCustomList:name:abc'), 'My List');
      expect(prefs.getStringList('archivedCustomList:hymnsIds:abc'),
          ['1', '2', '3']);
    });

    test('preserves other active lists when archiving one', () {
      final list1 = CustomList('a', 'List A', hymnsIds: [1]);
      final list2 = CustomList('b', 'List B', hymnsIds: [2]);
      saveCustomList(list1, prefs);
      saveCustomList(list2, prefs);

      archiveCustomList(list1, prefs);

      expect(prefs.getStringList('customLists'), ['b']);
      expect(prefs.getString('customList:name:b'), 'List B');
    });
  });

  group('restoreCustomList', () {
    test('moves list from archived to active keys at front', () {
      // Set up an existing active list
      final existing = CustomList('x', 'Existing', hymnsIds: [10]);
      saveCustomList(existing, prefs);

      // Archive a list, then restore it
      final list = CustomList('abc', 'My List', hymnsIds: [1, 2, 3]);
      saveCustomList(list, prefs);
      archiveCustomList(list, prefs);

      restoreCustomList(list, prefs);

      // Active keys restored, at front
      expect(prefs.getStringList('customLists'), ['abc', 'x']);
      expect(prefs.getString('customList:name:abc'), 'My List');
      expect(
          prefs.getStringList('customList:hymnsIds:abc'), ['1', '2', '3']);

      // Archived keys removed
      expect(prefs.getStringList('archivedCustomLists'), isEmpty);
      expect(prefs.getString('archivedCustomList:name:abc'), isNull);
      expect(prefs.getStringList('archivedCustomList:hymnsIds:abc'), isNull);
    });
  });

  group('loadArchivedCustomLists', () {
    test('returns empty list when no archived lists', () {
      expect(loadArchivedCustomLists(prefs), isEmpty);
    });

    test('loads archived lists with correct data', () {
      final list = CustomList('abc', 'My List', hymnsIds: [1, 2, 3]);
      saveCustomList(list, prefs);
      archiveCustomList(list, prefs);

      final archived = loadArchivedCustomLists(prefs);

      expect(archived.length, 1);
      expect(archived[0].id, 'abc');
      expect(archived[0].name, 'My List');
      expect(archived[0].hymnsIds, [1, 2, 3]);
    });
  });
}
