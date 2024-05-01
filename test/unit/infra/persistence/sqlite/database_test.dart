import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/infra/persistence/sqlite/database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  WidgetsFlutterBinding.ensureInitialized();

  test('Test database is created and populated with hymns', () async {
    var db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
        options: databaseOptions);

    expect(await db.query('HymnGroups').then((value) => value.length), 4);
    expect(await db.query('HymnSubgroups').then((value) => value.length), 25);
    expect(await db.query('Hymns').then((value) => value.length), 875);

    await db.close();
  });
}
