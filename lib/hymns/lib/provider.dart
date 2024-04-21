import 'dart:collection';
import 'dart:developer';

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

Future<List<Hymn>> loadHymns(Database database) async {
  log("Querying database for hymns");
  List<Map> queryResult = await database.rawQuery(getHymnsList);
  List<Hymn> hymns = [];

  await Future.forEach(queryResult, (hymnDetails) async {
    hymns.add(Hymn(
      hymnDetails['id'],
      hymnDetails['number'],
      "${hymnDetails['number']}.txt",
      hymnDetails['title'],
      hymnDetails['groupName'],
      hymnDetails['subgroupName'],
      await loadHymnText("${hymnDetails['number']}.txt"),
    ));
  });

  return hymns;
}

class HymnsListProvider with ChangeNotifier {
  List<Hymn> _hymnsList = [];

  UnmodifiableListView<Hymn> get hymnsList => UnmodifiableListView(_hymnsList);

  HymnsListProvider(Database database) {
    loadHymns(database).then((hymns) {
      _hymnsList = hymns;
      log("loaded ${_hymnsList.length} hymns");
      notifyListeners();
    });
  }

  List<Hymn> searchHymns(String query) {
    return HymnsSearchEngine().search(_hymnsList, query);
  }
}
