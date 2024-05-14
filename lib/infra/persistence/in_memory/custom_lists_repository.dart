import 'package:spiewnik_pielgrzyma/domain/custom_lists/model.dart';
import 'package:spiewnik_pielgrzyma/domain/custom_lists/repository.dart';
import 'package:spiewnik_pielgrzyma/seed/entity.dart';

class InMemoryCustomListRepository extends CustomListRepository {
  late Map<EntityId, CustomList> _database = {};

  InMemoryCustomListRepository() {
    _database = {};
  }

  @override
  Future<CustomList> getById(EntityId listId) async {
    if (!_database.containsKey(listId)) {
      throw CustomListNotFoundException();
    }
    return _database[listId]!;
  }

  @override
  Future<List<CustomList>> getAll() async {
    return _database.entries.map((e) => e.value).toList();
  }

  @override
  Future<void> save(CustomList list) async {
    _database[list.id] = list;
  }

  @override
  Future<void> saveAll(List<CustomList> list) async {
    for (var l in list) {
      save(l);
    }
  }

  @override
  Future<void> remove(CustomList list) async {
    if (!_database.containsKey(list.id)) {
      throw CustomListNotFoundException();
    }
    _database.remove(list.id);
  }
}
