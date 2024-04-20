import 'package:flutter/services.dart';
import 'package:sqflite/sqlite_api.dart';

Future onConfigure(Database db) async {
  await db.execute('PRAGMA foreign_keys = ON');
}

Future onCreate(Database db, int version) async {
  var batch = db.batch();
  String hymnsSql = await rootBundle.loadString("assets/hymns.sql");
  batch.execute(hymnsSql);
  await batch.commit();
}

Future onUpgrade(Database db, int oldVersion, int newVersion) async {
  var batch = db.batch();
  await batch.commit();
}

OpenDatabaseOptions databaseOptions = OpenDatabaseOptions(
  version: 0,
  onConfigure: onConfigure,
  onCreate: onCreate,
  onUpgrade: onUpgrade,
  onDowngrade: onDatabaseDowngradeDelete,
);
