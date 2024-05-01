import 'package:spiewnik_pielgrzyma/domain/custom_lists/model.dart';
import 'package:spiewnik_pielgrzyma/domain/custom_lists/repository.dart';
import 'package:spiewnik_pielgrzyma/seed/entity.dart';

class InMemoryCustomListRepository extends CustomListRepository {
  late Map<EntityId, CustomList> _database = {};

  InMemoryCustomListRepository();

  @override
  CustomList getById(EntityId listId) {
    if (!_database.containsKey(listId)) {
      throw CustomListNotFoundException();
    }
    return _database[listId]!;
  }

  @override
  List<CustomList> getAll() {
    return _database.entries.map((e) => e.value).toList();
  }

  @override
  void save(CustomList list) {
    _database[list.id] = list;
  }

  @override
  void saveAll(List<CustomList> list) {
    for (var l in list) {
      save(l);
    }
  }

  @override
  void remove(CustomList list) {
    if (!_database.containsKey(list.id)) {
      throw CustomListNotFoundException();
    }
    _database.remove(list.id);
  }
}
