import 'dart:collection';

import 'package:spiewnik_pielgrzyma/custom_lists/model/list.dart';

class NonUniqueListName extends ArgumentError {}

class ListOfCustomLists {
  List<CustomList> _innerList = [];

  ListOfCustomLists([List<CustomList> initialValue = const []]) {
    validate(initialValue);
    _innerList = initialValue;
  }

  void validate(List<CustomList> list) {
    if (list.map((e) => e.name).toSet().length < list.length) {
      throw NonUniqueListName();
    }
  }

  List<CustomList> get elements => UnmodifiableListView(_innerList);

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

  void setIndex(CustomList list, int newIndex) {
    int index = _innerList.indexOf(list);
    _innerList.removeAt(index);
    _innerList.insert(newIndex, list);
  }

  void rename(CustomList list, String newName) {
    int index = _innerList.indexOf(list);
    List<CustomList> newList = List.from(_innerList)
      ..insert(index, CustomList(newName, list.hymnNumbers));
    validate(newList);
    _innerList = newList;
  }
}
