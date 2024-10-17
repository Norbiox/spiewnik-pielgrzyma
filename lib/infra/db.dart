import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';

// HYMNS

const String hymnsCsvPath = 'assets/hymns.csv';
const String hymnIsFavoriteKey = 'hymn:isFavorite:';

Future<List<Hymn>> loadHymns(SharedPreferences prefs) async {
  final String hymnsData = await rootBundle.loadString(hymnsCsvPath);
  final List<List<String>> hymnsDetails =
      const CsvToListConverter(fieldDelimiter: ',', shouldParseNumbers: false)
          .convert(hymnsData);

  final List<Hymn> hymns = [];
  for (final entry in hymnsDetails.sublist(1).asMap().entries) {
    final int index = entry.key;
    final List<String> hymnDetails = entry.value;

    String filename = "assets/texts/${hymnDetails[0]}.txt";
    String rawText = await rootBundle.loadString(filename);

    final Hymn hymn = Hymn(
      index,
      hymnDetails[0],
      hymnDetails[1],
      hymnDetails[2],
      hymnDetails[3],
      rawText.split('\n').sublist(1),
      isFavorite: prefs.getBool('$hymnIsFavoriteKey$index') ?? false,
    );
    hymns.add(hymn);
  }

  return hymns;
}

Future<void> saveHymnIsFavorite(
    SharedPreferences prefs, int hymnId, bool isFavorite) async {
  await prefs.setBool('$hymnIsFavoriteKey$hymnId', isFavorite);
}

// CUSTOM LISTS

const String customListsKey = 'customLists';
const String customListHymnsIdsKey = 'customList:hymnsIds:';
const String customListNameKey = 'customList:name:';

List<CustomList> loadCustomLists(SharedPreferences prefs) {
  final List<String> customListsIds = prefs.getStringList(customListsKey) ?? [];
  final List<CustomList> customLists = [];
  for (final id in customListsIds) {
    final List<int> hymnsIds =
        (prefs.getStringList('$customListHymnsIdsKey$id') ?? [])
            .map((e) => int.parse(e))
            .toList();
    final String name = prefs.getString('$customListNameKey$id') ?? '';
    customLists.add(CustomList(id, name, hymnsIds: hymnsIds));
  }
  return customLists;
}

void saveCustomList(CustomList list, SharedPreferences prefs) {
  prefs.setString('$customListNameKey${list.id}', list.name);
  prefs.setStringList('$customListHymnsIdsKey${list.id}',
      list.hymnsIds.map((e) => e.toString()).toList());
  if (!(prefs.getStringList(customListsKey) ?? []).contains(list.id)) {
    prefs.setStringList(customListsKey,
        [list.id, ...(prefs.getStringList(customListsKey) ?? [])]);
  }
}

void deleteCustomList(CustomList list, SharedPreferences prefs) {
  prefs.remove('$customListNameKey${list.id}');
  prefs.remove('$customListHymnsIdsKey${list.id}');
  prefs.setStringList(
      customListsKey,
      (prefs.getStringList(customListsKey) ?? [])
          .where((e) => e != list.id)
          .toList());
}

void updateCustomListsOrder(List<CustomList> lists, SharedPreferences prefs) {
  prefs.setStringList(customListsKey, lists.map((e) => e.id).toList());
}
