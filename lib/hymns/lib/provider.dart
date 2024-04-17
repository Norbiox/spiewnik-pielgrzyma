import 'dart:collection';
import 'dart:developer';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spiewnik_pielgrzyma/hymns/model/hymn.dart';
import 'package:spiewnik_pielgrzyma/hymns/lib/search_engine.dart';

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

class HymnsListProvider with ChangeNotifier {
  List<Hymn> _hymnsList = [];

  UnmodifiableListView<Hymn> get hymnsList => UnmodifiableListView(_hymnsList);

  HymnsListProvider() {
    loadHymnsList().then((hymns) {
      _hymnsList = hymns;
      notifyListeners();
    });
    log("loaded ${_hymnsList.length} hymns");
  }

  List<Hymn> searchHymns(String query) {
    return HymnsSearchEngine().search(_hymnsList, query);
  }
}
