import 'dart:collection';
import 'dart:developer';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spiewnik_pielgrzyma/hymns/database/query.dart';
import 'package:spiewnik_pielgrzyma/hymns/model/hymn.dart';
import 'package:spiewnik_pielgrzyma/hymns/lib/search_engine.dart';
import 'package:sqflite/sqflite.dart';

Future<List<String>> loadHymnText(String filename) async {
  return await rootBundle
      .loadString("assets/texts/$filename")
      .then((value) => value.split('\n').sublist(1));
}

Future<List<Hymn>> loadHymnsList() async {
  final String rawData = await rootBundle.loadString('assets/hymns.csv');
  final List<List<String>> hymnsDetails =
      const CsvToListConverter(fieldDelimiter: ';', shouldParseNumbers: false)
          .convert(rawData);

  final Map<String, List<String>> hymnsTexts = {};
  await Future.forEach(hymnsDetails.sublist(1), (element) async {
    hymnsTexts[element[1]] = await loadHymnText(element[1]);
  });

  return List<Hymn>.from(hymnsDetails.sublist(1).map(
        (hymn) => Hymn(
          int.parse(hymn[0]),
          hymn[2],
          hymn[1],
          hymn[3],
          hymn[4],
          hymn[5],
          hymnsTexts[hymn[1]]!,
        ),
      ));
}

// Future<List<Hymn>> loadHymnsFromDatabase() async {
Future<List<Hymn>> loadHymnsFromDatabase(Database database) async {
  log("Querying database for hymns");
  List<Map> queryResult = await database.rawQuery(getHymnsList);

  return List<Hymn>.from(queryResult.map((hymn) => Hymn(
        hymn['id'],
        hymn['number'],
        "${hymn['number']}.txt",
        hymn['title'],
        hymn['groupName'],
        hymn['subgroupName'],
        const [],
      )));
}

class HymnsListProvider with ChangeNotifier {
  List<Hymn> _hymnsList = [];

  UnmodifiableListView<Hymn> get hymnsList => UnmodifiableListView(_hymnsList);

  HymnsListProvider(Database database) {
    loadHymnsFromDatabase(database).then((hymns) {
      _hymnsList = hymns;
      log("loaded ${_hymnsList.length} hymns");
      notifyListeners();
    });
  }

  List<Hymn> searchHymns(String query) {
    return HymnsSearchEngine().search(_hymnsList, query);
  }
}
