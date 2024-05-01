import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/infra/persistence/sqlite/database.dart';
import 'package:spiewnik_pielgrzyma/infra/persistence/sqlite/hymns_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  WidgetsFlutterBinding.ensureInitialized();

  group('Test migrations', () {
    test('Test "isFavorite" column is added to "Hymns" table', () async {
      var db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
          options: databaseOptions);

      expect(
          await db.query('Hymns').then((value) => value[0]['isFavorite']), 0);

      await db.close();
    });
  });

  group('Test queries', () {
    test('Test getHymnsList returns all hymns', () async {
      var db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
          options: databaseOptions);
      expect(
          await db.rawQuery(getHymnsList).then((value) => value.length), 875);
      await db.close();
    });
  });
}
