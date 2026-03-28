import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';

// HYMNS

const String hymnsCsvPath = 'assets/hymns.csv';
const String hymnsTextsJsonPath = 'assets/hymns_texts.json';
const String hymnIsFavoriteKey = 'hymn:isFavorite:';

Future<List<Hymn>> loadHymns(SharedPreferences prefs) async {
  final hymnsData = await rootBundle.loadString(hymnsCsvPath);
  final List<List<String>> hymnsDetails =
      const CsvToListConverter(fieldDelimiter: ',', shouldParseNumbers: false)
          .convert(hymnsData);

  final hymnsTexts =
      await rootBundle.loadString(hymnsTextsJsonPath).then(jsonDecode);

  final List<Hymn> hymns = [];
  for (final entry in hymnsDetails.sublist(1).asMap().entries) {
    final int index = entry.key;
    final List<String> hymnDetails = entry.value;

    final Hymn hymn = Hymn(
      index,
      hymnDetails[0],
      hymnDetails[1],
      hymnDetails[2],
      hymnDetails[3],
      List<String>.from(hymnsTexts[hymnDetails[0]]),
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

// ARCHIVED CUSTOM LISTS

const String archivedCustomListsKey = 'archivedCustomLists';
const String archivedCustomListHymnsIdsKey = 'archivedCustomList:hymnsIds:';
const String archivedCustomListNameKey = 'archivedCustomList:name:';

List<CustomList> loadArchivedCustomLists(SharedPreferences prefs) {
  final List<String> ids = prefs.getStringList(archivedCustomListsKey) ?? [];
  final List<CustomList> lists = [];
  for (final id in ids) {
    final List<int> hymnsIds =
        (prefs.getStringList('$archivedCustomListHymnsIdsKey$id') ?? [])
            .map((e) => int.parse(e))
            .toList();
    final String name = prefs.getString('$archivedCustomListNameKey$id') ?? '';
    lists.add(CustomList(id, name, hymnsIds: hymnsIds));
  }
  return lists;
}

void archiveCustomList(CustomList list, SharedPreferences prefs) {
  // Copy to archived keys
  prefs.setString('$archivedCustomListNameKey${list.id}', list.name);
  prefs.setStringList('$archivedCustomListHymnsIdsKey${list.id}',
      list.hymnsIds.map((e) => e.toString()).toList());
  final archivedIds = prefs.getStringList(archivedCustomListsKey) ?? [];
  if (!archivedIds.contains(list.id)) {
    prefs.setStringList(archivedCustomListsKey, [list.id, ...archivedIds]);
  }
  // Remove from active keys
  deleteCustomList(list, prefs);
}

void restoreCustomList(CustomList list, SharedPreferences prefs) {
  // Copy to active keys (prepend to front)
  prefs.setString('$customListNameKey${list.id}', list.name);
  prefs.setStringList('$customListHymnsIdsKey${list.id}',
      list.hymnsIds.map((e) => e.toString()).toList());
  final activeIds = prefs.getStringList(customListsKey) ?? [];
  prefs.setStringList(customListsKey, [list.id, ...activeIds]);
  // Remove from archived keys
  prefs.remove('$archivedCustomListNameKey${list.id}');
  prefs.remove('$archivedCustomListHymnsIdsKey${list.id}');
  prefs.setStringList(
      archivedCustomListsKey,
      (prefs.getStringList(archivedCustomListsKey) ?? [])
          .where((e) => e != list.id)
          .toList());
}
