import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/infra/persistence/sqlite/database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  WidgetsFlutterBinding.ensureInitialized();

  group('Test migrations', () {
    test('CustomLists table is created', () async {
      var db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
          options: databaseOptions);

      await db.query('CustomLists');

      await db.close();
    });
  });
}
