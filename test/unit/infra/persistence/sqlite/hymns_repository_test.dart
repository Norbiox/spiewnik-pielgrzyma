import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/domain/hymns/model.dart';
import 'package:spiewnik_pielgrzyma/domain/hymns/repository.dart';
import 'package:spiewnik_pielgrzyma/infra/persistence/sqlite/database.dart';
import 'package:spiewnik_pielgrzyma/infra/persistence/sqlite/hymns_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  WidgetsFlutterBinding.ensureInitialized();

  group('Test SqliteHymnsRepository', () {
    test('get hymn by its ID', () async {
      var repository = await SqliteHymnRepository.create(
          await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
              options: databaseOptions));
      var hymn = await repository.getById('1');
      expect(hymn.number, '1');
      expect(hymn.title, 'Alleluja, chwalcie Pana');
      expect(hymn.group, 'I. Bóg Trójjedyny');
      expect(hymn.subgroup, '1. Chwała i dziękczynienie');
      expect(hymn.text.isNotEmpty, true);
      expect(hymn.isFavorite, false);
    });

    test('exception raised when asked for non-existing hymn', () async {
      var repository = await SqliteHymnRepository.create(
          await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
              options: databaseOptions));
      expectLater(
          () => repository.getById('0'), throwsA(isA<HymnNotFoundException>()));
    });

    test('get all hymns', () async {
      var repository = await SqliteHymnRepository.create(
          await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
              options: databaseOptions));
      expectLater(await repository.getAll().then((hymns) => hymns.length), 875);
    });

    test('save saves hymn state', () async {
      // given
      var repository = await SqliteHymnRepository.create(
          await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
              options: databaseOptions));
      var hymn = await repository.getById('1');
      hymn.toggleIsFavorite();
      // when
      repository.save(hymn);
      // then
      var newRepository = await SqliteHymnRepository.create(
          await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
              options: databaseOptions));
      var savedHymn = await newRepository.getById('1');
      expect(savedHymn.isFavorite, hymn.isFavorite);
      expect(savedHymn.modifiedAt, hymn.modifiedAt);
    });

    test('exception raised when trying to save non-existing hymn', () async {
      var repository = await SqliteHymnRepository.create(
          await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
              options: databaseOptions));
      var hymn = Hymn('0', DateTime.now(), '0', '', '', '', []);
      expectLater(
          () => repository.save(hymn), throwsA(isA<HymnNotFoundException>()));
    });
  });
}
