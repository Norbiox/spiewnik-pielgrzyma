import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:spiewnik_pielgrzyma/models/temp.dart';

Future<Isar> initIsar(
    Directory documentsDirectory, SharedPreferences sharedPreferences) async {
  final Isar isar = await Isar.open(
    [TempSchema, HymnSchema, CustomListSchema],
    directory: documentsDirectory.path,
  );

  if (sharedPreferences.getInt('isar_schema_version') == null) {
    sharedPreferences.setInt('isar_schema_version', 1);
  }

  await loadHymns(isar);

  return isar;
}

Future<void> loadHymns(Isar isar) async {
  if (await isar.hymns.count() > 0) return;

  final String hymnsData = await rootBundle.loadString('assets/hymns.csv');
  final List<List<String>> hymnsDetails =
      const CsvToListConverter(fieldDelimiter: ',', shouldParseNumbers: false)
          .convert(hymnsData);

  final List<Hymn> hymns = [];
  for (final hymnDetails in hymnsDetails.sublist(1)) {
    String filename = "assets/texts/${hymnDetails[0]}.txt";
    String rawText = await rootBundle.loadString(filename);
    final Hymn hymn = Hymn(
      hymnDetails[0],
      hymnDetails[1],
      hymnDetails[2],
      hymnDetails[3],
      rawText.split('\n').sublist(1),
    );
    hymns.add(hymn);
  }

  await isar.writeTxn(() async {
    await isar.hymns.putAll(hymns);
  });
}
