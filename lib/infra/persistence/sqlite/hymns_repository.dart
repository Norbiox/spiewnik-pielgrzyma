import 'package:spiewnik_pielgrzyma/domain/hymns/model.dart';
import 'package:spiewnik_pielgrzyma/domain/hymns/repository.dart';
import 'package:spiewnik_pielgrzyma/seed/entity.dart';
import 'package:sqflite/sqflite.dart';

class SqliteHymnRepository extends HymnRepository {
  Database db;

  SqliteHymnRepository(this.db);

  @override
  Hymn getById(EntityId hymnId) {}

  @override
  List<Hymn> getAll() {}

  @override
  void save(Hymn hymn) {}
}
