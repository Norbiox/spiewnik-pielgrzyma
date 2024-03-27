import 'dart:collection';
import 'dart:developer';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';

Future<List<Hymn>> loadHymnsList() async {
  final String rawData = await rootBundle.loadString('assets/hymns.csv');
  final List<List<String>> hymnsDetails =
      const CsvToListConverter(fieldDelimiter: ';', shouldParseNumbers: false)
          .convert(rawData);
  return List<Hymn>.from(hymnsDetails.sublist(1).map(
        (hymn) => Hymn(
            int.parse(hymn[0]), hymn[2], hymn[1], hymn[3], hymn[4], hymn[5]),
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
}
