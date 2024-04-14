import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list.dart';

class CustomList {
  String name;
  List<String> hymnNumbers;

  CustomList(this.name, this.hymnNumbers);

  List<Hymn> get hymns {
    return hymnNumbers
        .map((number) => GetIt.I<HymnsListProvider>()
            .hymnsList
            .firstWhere((element) => element.number == number))
        .toList();
  }

  void add(Hymn hymn) {
    hymnNumbers.add(hymn.number);
  }

  @override
  int get hashCode =>
      Object.hashAll([name.hashCode + Object.hashAll(hymnNumbers)]);

  @nonVirtual
  @override
  bool operator ==(Object other) => hashCode == other.hashCode;

  @override
  String toString() => "CustomList('$name', $hymnNumbers)";
}

class NonUniqueListName extends ArgumentError {}

class CustomLists extends ListBase<CustomList> {
  List<CustomList> l = [];

  CustomLists();

  @override
  set length(int newLength) {
    l.length = newLength;
  }

  @override
  int get length => l.length;

  @override
  CustomList operator [](int index) => l[index];

  @override
  void operator []=(int index, CustomList item) {
    if (l.any((CustomList el) => el.name == item.name) &&
        (l.length <= index || l[index].name != item.name)) {
      throw NonUniqueListName();
    }

    l[index] = item;
  }

  @override
  void add(CustomList element) {
    if (l.any((CustomList el) => el.name == element.name)) {
      throw NonUniqueListName();
    }
    l.add(element);
  }
}
