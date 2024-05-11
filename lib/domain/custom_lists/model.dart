import 'dart:collection';

import 'package:clock/clock.dart';
import 'package:spiewnik_pielgrzyma/seed/entity.dart';
import 'package:uuid/uuid.dart';

class CustomList extends Entity {
  String _name;
  late DateTime createdAt;
  late List<EntityId> _hymns;

  CustomList(super.id, this._name, this.createdAt, super.modifiedAt,
      [hymns = const <EntityId>[]]) {
    _hymns = List<EntityId>.from(hymns);
  }

  factory CustomList.create(String name) {
    Uuid uuid = const Uuid();
    DateTime now = clock.now();
    return CustomList(uuid.v1(), name, now, now, List<EntityId>.from([]));
  }

  UnmodifiableListView<EntityId> get hymns => UnmodifiableListView(_hymns);

  String get name => _name;

  void rename(String newName) {
    recordModificationTime(() {
      _name = newName;
    });
  }

  void addHymn(EntityId hymnId) {
    recordModificationTime(() {
      if (_hymns.contains(hymnId)) {
        throw Exception("List already contains this hymn");
      }
      _hymns.add(hymnId);
    });
  }

  void removeHymn(EntityId hymnId) {
    recordModificationTime(() {
      if (!_hymns.contains(hymnId)) {
        throw Exception("Hymn not found in the list");
      }
      _hymns.removeWhere((el) => el == hymnId);
    });
  }

  void changeHymnOrdering(EntityId hymnId, int newIndex) {
    recordModificationTime(() {
      if (!_hymns.contains(hymnId)) {
        throw Exception("Hymn not found in the list");
      }
      int currentIndex = _hymns.indexOf(hymnId);
      _hymns.removeAt(currentIndex);
      _hymns.insert(newIndex, hymnId);
    });
  }
}
