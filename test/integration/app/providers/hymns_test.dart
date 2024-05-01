import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/search_engine.dart';
import 'package:spiewnik_pielgrzyma/domain/hymns/model.dart';
import 'package:spiewnik_pielgrzyma/infra/persistence/sqlite/database.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymns/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  WidgetsFlutterBinding.ensureInitialized();

  test('hymns are loaded with all expected fields', () async {
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

  test('toggleIsFavorite', () async {
    var db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
        options: databaseOptions);

    final provider = HymnsListProvider(db);
    await Future.delayed(const Duration(seconds: 1));

    bool currentState = await provider.toggleIsFavorite(provider.hymnsList[8]);
    expect(currentState, true);
    expect(provider.hymnsList[8].isFavorite, true);
    expect(await db.query('Hymns').then((value) => value[8]['isFavorite']), 1);

    bool currentState2 = await provider.toggleIsFavorite(provider.hymnsList[8]);
    expect(currentState2, false);
    expect(provider.hymnsList[8].isFavorite, false);
    expect(await db.query('Hymns').then((value) => value[8]['isFavorite']), 0);
  });

  group('Test SearchEngine', () {
    HymnsSearchEngine engine = HymnsSearchEngine();
    List<Hymn> hymns = [
      Hymn(0, "1", "001.txt", "Pieśń pierwsza", "group", "subgroup",
          ["Jednak", "druga"]),
      Hymn(1, "2", "002.txt", "Pieśń druga", "group", "subgroup", []),
      Hymn(2, "10", "010.txt", "Pieśń dziesiąta", "group", "subgroup", []),
      Hymn(3, "20", "020.txt", "Pieśń dwudziesta", "group", "subgroup",
          ["Niechaj teraz, za Twą wolą"]),
    ];

    test("should return full list if query is empty", () {
      expect(engine.search(hymns, ""), hymns);
    });

    test("should order hymns by score", () {
      expect(engine.search(hymns, "2"), <Hymn>[hymns[1], hymns[3]]);
    });

    test("should order hymns with same score by index", () {
      expect(engine.search(hymns, "pieśń"), hymns);
    });

    test("should ignore polish letters", () {
      expect(engine.search(hymns, "piesn"), hymns);
    });

    test("should find by part of word", () {
      expect(engine.search(hymns, "ier"), <Hymn>[hymns[0]]);
    });

    test("should score by part of title higher than part of text", () {
      expect(engine.search(hymns, "druga"), <Hymn>[hymns[1], hymns[0]]);
    });

    test("should ignore special characters", () {
      expect(engine.search(hymns, "teraz za twa"), <Hymn>[hymns[3]]);
    });
  });
}
