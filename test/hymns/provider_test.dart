import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/database.dart';
import 'package:spiewnik_pielgrzyma/hymns/lib/provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  WidgetsFlutterBinding.ensureInitialized();

  test('Test hymns are loaded with all expected fields', () async {
    var db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
        options: databaseOptions);
    db.update('Hymns', {'isFavorite': 1}, where: 'id = 1');

    final provider = HymnsListProvider(db);
    await Future.delayed(const Duration(seconds: 1));

    expect(provider.hymnsList[0].id, 1);
    expect(provider.hymnsList[0].number, '1');
    expect(provider.hymnsList[0].title, 'Alleluja, chwalcie Pana');
    expect(provider.hymnsList[0].group, 'I. Bóg Trójjedyny');
    expect(provider.hymnsList[0].subgroup, '1. Chwała i dziękczynienie');
    expect(provider.hymnsList[0].isFavorite, true);

    await db.close();
  });
}
