import 'package:spiewnik_pielgrzyma/domain/custom_lists/model.dart';
import 'package:spiewnik_pielgrzyma/domain/custom_lists/repository.dart';
import 'package:spiewnik_pielgrzyma/seed/entity.dart';
import 'package:sqflite/sqflite.dart';

String _tablename = 'CustomLists';

class SqliteCustomListRepository extends CustomListRepository {
  Database database;
  late List<CustomList> _cache;

  static Future<SqliteCustomListRepository> create(Database database) async {
    var repository = SqliteCustomListRepository._internal(database);
    repository._cache = await repository._load();
    return repository;
  }

  SqliteCustomListRepository._internal(this.database);

  Future<List<CustomList>> _load() async {
    var lists = await database.query(_tablename, orderBy: 'orderIndex');
    return lists
        .map((e) => CustomList(
              e['id'].toString(),
              e['name'].toString(),
              DateTime.parse(e['createdAt'].toString()),
              DateTime.parse(e['modifiedAt'].toString()),
              e['hymnsIds'].toString().split('|').toList(),
            ))
        .toList();
  }

  @override
  Future<CustomList> getById(EntityId listId) async {
    try {
      return _cache.firstWhere((element) => element.id == listId);
    } on StateError {
      throw CustomListNotFoundException();
    }
  }

  @override
  Future<List<CustomList>> getAll() async {
    return _cache;
  }

  @override
  Future<void> save(CustomList list) async {
    var index = _cache.indexWhere((element) => element.id == list.id);
    if (index == -1) {
      throw CustomListNotFoundException();
    }
    _cache[index] = list;
    saveAll(_cache);
    notifyListeners();
  }

  @override
  Future<void> saveAll(List<CustomList> list) async {
    var toRemove = _cache
        .where((element) => list.where((el) => el.id == element.id).isEmpty);

    Batch batch = database.batch();

    for (final (index, element) in list.indexed) {
      if (_cache.where((el) => el == element).isEmpty) {
        batch.insert(_tablename, {
          'id': element.id,
          'createdAt': element.createdAt.toIso8601String(),
          'modifiedAt': element.modifiedAt.toIso8601String(),
          'name': element.name,
          'orderIndex': index,
          'hymnsIds': element.hymns.join('|')
        });
      } else {
        batch.update(
            _tablename,
            {
              'createdAt': element.createdAt.toIso8601String(),
              'modifiedAt': element.modifiedAt.toIso8601String(),
              'name': element.name,
              'orderIndex': index,
              'hymnsIds': element.hymns.join('|')
            },
            where: 'id = ?',
            whereArgs: [element.id]);
      }
    }

    for (final list in toRemove) {
      batch.delete(_tablename, where: 'id = ?', whereArgs: [list.id]);
    }

    await batch.commit(noResult: true);
    _cache = await _load();
    notifyListeners();
  }

  @override
  Future<void> remove(CustomList list) async {
    var index = _cache.indexWhere((element) => element.id == list.id);
    if (index == -1) {
      throw CustomListNotFoundException();
    }
    _cache.removeAt(index);
    saveAll(_cache);
    notifyListeners();
  }
}

void createTable(Batch batch) {
  batch.execute('''CREATE TABLE $_tablename (
    id TEXT PRIMARY KEY,
    createdAt TEXT DEFAULT "${DateTime.now().toString()}" NOT NULL,
    modifiedAt TEXT DEFAULT "${DateTime.now().toString()}" NOT NULL,
    name TEXT NOT NULL,
    orderIndex INTEGER NOT NULL,
    hymnsIds TEXT DEFAULT ""
    )''');
}
