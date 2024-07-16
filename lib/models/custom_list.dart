import 'package:objectbox/objectbox.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';

@Entity()
class CustomList {
  @Id()
  int id = 0;

  String? name;
  int? index;
  List<int> hymnsOrder;

  CustomList(this.name, this.index, {List<int>? hymnsOrder})
      : hymnsOrder = hymnsOrder ?? [];

  final hymns = ToMany<Hymn>();

  Map<int, int> get hymnsOrderMap {
    return {for (int i = 0; i < hymnsOrder.length; i++) hymnsOrder[i]: i};
  }
}
