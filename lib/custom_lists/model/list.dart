import 'dart:collection';

import 'package:spiewnik_pielgrzyma/hymns/model/hymn.dart';

class CustomList {
  late int id;
  String name;
  late int orderingIndex;
  late DateTime createdAt;
  late DateTime modifiedAt;
  late List<Hymn> _hymns;

  CustomList(
      this.id, this.name, this.orderingIndex, this.createdAt, this.modifiedAt,
      [hymns = const <Hymn>[]]) {
    _hymns = List<Hymn>.from(hymns);
  }

  UnmodifiableListView<Hymn> get hymns => UnmodifiableListView(_hymns);
}
