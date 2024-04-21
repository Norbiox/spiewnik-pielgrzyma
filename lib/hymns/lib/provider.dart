import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spiewnik_pielgrzyma/hymns/database/query.dart';
import 'package:spiewnik_pielgrzyma/hymns/model/hymn.dart';
import 'package:spiewnik_pielgrzyma/hymns/lib/search_engine.dart';
import 'package:sqflite/sqflite.dart';

class HymnsListProvider with ChangeNotifier {
  Database db;
  List<Hymn> _hymnsList = [];

  UnmodifiableListView<Hymn> get hymnsList => UnmodifiableListView(_hymnsList);

  HymnsListProvider(this.db) {
    loadHymns().then((hymns) {
      _hymnsList = hymns;
      log("loaded ${_hymnsList.length} hymns");
      notifyListeners();
    });
  }

  Future<List<String>> loadHymnText(String filename) async {
    return await rootBundle
        .loadString("assets/texts/$filename")
        .then((value) => value.split('\n').sublist(1));
  }

  Future<List<Hymn>> loadHymns() async {
    log("Querying database for hymns");
    List<Map> queryResult = await db.rawQuery(getHymnsList);
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
        isFavorite: hymnDetails['isFavorite'] == 1,
      ));
    });

    return hymns;
  }

  List<Hymn> searchHymns(String query) {
    return HymnsSearchEngine().search(_hymnsList, query);
  }

  void toggleIsFavorite(Hymn hymn) async {
    hymn.isFavorite = !hymn.isFavorite;
    db.update('Hymns', {'isFavorite': hymn.isFavorite ? 1 : 0},
        where: 'id = ${hymn.id}');
    notifyListeners();
  }
}
