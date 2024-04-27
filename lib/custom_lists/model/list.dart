import 'dart:collection';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:spiewnik_pielgrzyma/custom_lists/database/query.dart';
import 'package:spiewnik_pielgrzyma/hymns/model/hymn.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class CustomList {
  final String id;
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

  factory CustomList.create(String name, int orderingIndex) {
    Uuid uuid = const Uuid();
    DateTime now = DateTime.now();
    return CustomList(
        uuid.v1(), name, orderingIndex, now, now, List<Hymn>.from([]));
  }

  UnmodifiableListView<Hymn> get hymns => UnmodifiableListView(_hymns);
}
