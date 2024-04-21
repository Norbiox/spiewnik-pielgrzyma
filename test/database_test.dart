import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/database.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  WidgetsFlutterBinding.ensureInitialized();

  test('Test database is created and populated with hymns', () async {
    var factory = databaseFactoryFfi;
    var db = await factory.openDatabase(inMemoryDatabasePath,
        options: databaseOptions);

    expect(await db.query('HymnGroups').then((value) => value.length), 4);
    expect(await db.query('HymnSubgroups').then((value) => value.length), 25);
    expect(await db.query('Hymns').then((value) => value.length), 875);

    await db.close();
  });
}
