import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/database.dart';
import 'package:spiewnik_pielgrzyma/hymns/database/query.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  WidgetsFlutterBinding.ensureInitialized();

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
