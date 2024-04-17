import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:spiewnik_pielgrzyma/hymns/model/hymn.dart';
import 'package:spiewnik_pielgrzyma/hymns/lib/provider.dart';

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

  void remove(Hymn hymn) {
    hymnNumbers.removeWhere((el) => el == hymn.number);
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
