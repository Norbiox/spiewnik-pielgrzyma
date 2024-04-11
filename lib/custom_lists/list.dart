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
