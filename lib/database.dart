import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:sqflite/sqlite_api.dart';

Future<List<String>> loadSqlFromAssets(String assetPath) async {
  return await rootBundle
      .loadString(assetPath)
      .then((value) => value.split(";"));
}

Future onConfigure(Database db) async {
  await db.execute('PRAGMA foreign_keys = ON');
}

Future onCreate(Database db, int version) async {
  log("Running onCreate database migration");
  var batch = db.batch();

  for (var sql in await loadSqlFromAssets("assets/hymns.sql")) {
    sql = sql.trim();
    if (sql.isEmpty) continue;
    log("Running following SQL: $sql");
    batch.execute(sql);
  }

  await batch.commit();
  var tables = await db.query("sqlite_master");
  log("Tables created: ${tables.length}");
}

Future onUpgrade(Database db, int oldVersion, int newVersion) async {
  log("Running onUpgrade database migration");
  var batch = db.batch();
  await batch.commit();
}

OpenDatabaseOptions databaseOptions = OpenDatabaseOptions(
  version: 1,
  onConfigure: onConfigure,
  onCreate: onCreate,
  onUpgrade: onUpgrade,
  onDowngrade: onDatabaseDowngradeDelete,
);
