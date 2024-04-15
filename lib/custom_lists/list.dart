import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list.dart';

class CustomList {
  final String name;
  List<String> hymnNumbers;

  CustomList(this.name, [this.hymnNumbers = const <String>[]]) {
    hymnNumbers = List.from(hymnNumbers);
  }

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

class CustomLists {
  List<CustomList> _innerList = [];

  CustomLists([List<CustomList> initialValue = const []]) {
    validate(initialValue);
    _innerList = initialValue;
  }

  void validate(List<CustomList> list) {
    if (list.map((e) => e.name).toSet().length < list.length) {
      throw NonUniqueListName();
    }
  }

  set length(int newLength) {
    _innerList.length = newLength;
  }

  int get length => _innerList.length;

  CustomList operator [](int index) => _innerList[index];

  void add(CustomList list) {
    List<CustomList> newList = List.from(_innerList)..add(list);
    validate(newList);
    _innerList = newList;
  }

  void remove(CustomList list) {
    _innerList.removeWhere((el) => el.name == list.name);
  }
}
