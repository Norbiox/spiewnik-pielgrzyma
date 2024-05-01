import 'dart:collection';

import 'package:clock/clock.dart';
import 'package:spiewnik_pielgrzyma/seed/entity.dart';
import 'package:uuid/uuid.dart';

class CustomList extends Entity {
  String _name;
  late DateTime createdAt;
  late List<int> _hymns;

  CustomList(super.id, this._name, this.createdAt, super.modifiedAt,
      [hymns = const <int>[]]) {
    _hymns = List<int>.from(hymns);
  }

  factory CustomList.create(String name) {
    Uuid uuid = const Uuid();
    DateTime now = clock.now();
    return CustomList(uuid.v1(), name, now, now, List<int>.from([]));
  }

  UnmodifiableListView<int> get hymns => UnmodifiableListView(_hymns);

  String get name => _name;

  void rename(String newName) {
    recordModificationTime(() {
      _name = newName;
    });
  }

  void addHymn(int hymnId) {
    recordModificationTime(() {
      if (_hymns.contains(hymnId)) {
        throw Exception("List already contains this hymn");
      }
      _hymns.add(hymnId);
    });
  }

  void removeHymn(int hymnId) {
    recordModificationTime(() {
      if (!_hymns.contains(hymnId)) {
        throw Exception("Hymn not found in the list");
      }
      _hymns.removeWhere((el) => el == hymnId);
    });
  }

  void changeHymnOrdering(int hymnId, int newIndex) {
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
