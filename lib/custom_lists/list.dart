import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymn.dart';
import 'package:spiewnik_pielgrzyma/hymns/hymns_list.dart';

class CustomList extends Equatable {
  final String name;
  final List<String> hymnNumbers;

  const CustomList(this.name, this.hymnNumbers);

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
  List<Object> get props => [name, hymnNumbers];
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
    if (l.any((CustomList element) => element.name == item.name) &&
        (l.length <= index || l[index].name != item.name)) {
      throw NonUniqueListName();
    }

    l[index] = item;
  }

  @override
  void add(CustomList item) {
    if (l.any((CustomList element) => element.name == item.name)) {
      throw NonUniqueListName();
    }
    l.add(item);
  }
}
