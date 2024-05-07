import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:spiewnik_pielgrzyma/domain/hymns/model.dart';
import 'package:spiewnik_pielgrzyma/domain/hymns/repository.dart';
import 'package:spiewnik_pielgrzyma/seed/entity.dart';
import 'package:sqflite/sqflite.dart';

class SqliteHymnRepository extends HymnRepository {
  Database database;
  late Map<EntityId, Hymn> _hymns;

  static Future<SqliteHymnRepository> create(Database database) async {
    var repository = SqliteHymnRepository._internal(database);
    repository._hymns = await repository._loadHymns();
    return repository;
  }

  SqliteHymnRepository._internal(this.database);

  Future<List<String>> _loadHymnText(String filename) async {
    return await rootBundle
        .loadString("assets/texts/$filename")
        .then((value) => value.split('\n').sublist(1));
  }

  Future<Map<EntityId, Hymn>> _loadHymns() async {
    log("Querying database for hymns");
    List<Map> queryResult = await database.rawQuery(getHymnsList);
    Map<EntityId, Hymn> hymns = {};

    await Future.forEach(queryResult, (hymnDetails) async {
      hymns[hymnDetails['id']] = Hymn(
        hymnDetails['id'],
        DateTime.now(),
        hymnDetails['number'],
        hymnDetails['title'],
        hymnDetails['groupName'],
        hymnDetails['subgroupName'],
        await _loadHymnText("${hymnDetails['number']}.txt"),
        hymnDetails['isFavorite'] == 1,
      );
    });

    return hymns;
  }

  @override
  Future<Hymn> getById(EntityId hymnId) async {
    if (!_hymns.containsKey(hymnId)) {
      throw HymnNotFoundException();
    }
    return _hymns[hymnId]!;
  }

  @override
  Future<List<Hymn>> getAll() async {
    return _hymns.values.toList();
  }

  @override
  void save(Hymn hymn) async {
    if (!_hymns.containsKey(hymn.id)) {
      throw HymnNotFoundException();
    }
    await database.rawUpdate('UPDATE Hymns SET isFavorite = ? WHERE id = ?',
        [hymn.isFavorite ? 1 : 0, hymn.id]);
    _hymns[hymn.id] = hymn;
    notifyListeners();
  }
}

void addIsFavoriteColumn(Batch batch) {
  batch.execute(
      'ALTER TABLE Hymns ADD COLUMN isFavorite INTEGER DEFAULT 0 NOT NULL CHECK (isFavorite IN (0, 1))');
}

String getHymnsList = '''
SELECT
  Hymns.id AS id,
  Hymns.number AS number,
  Hymns.title AS title,
  Hymns.isFavorite AS isFavorite,
  HymnSubgroups.id AS subgroupId,
  HymnSubgroups.name AS subgroupName,
  HymnGroups.id AS groupId,
  HymnGroups.name AS groupName
FROM Hymns
LEFT JOIN HymnSubgroups ON Hymns.groupId = HymnSubgroups.id
LEFT JOIN HymnGroups ON HymnSubgroups.groupId = HymnGroups.id;
''';
