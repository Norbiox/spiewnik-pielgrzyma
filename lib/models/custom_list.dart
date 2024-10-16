import 'package:isar/isar.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:spiewnik_pielgrzyma/utils/list.dart';

part 'custom_list.g.dart';

@collection
class CustomList {
  Id id = Isar.autoIncrement;

  String? name;
  int? index;
  List<int> hymnsIds;

  CustomList(this.name, this.index, {List<int>? hymnsOrder})
      : hymnsIds = hymnsOrder ?? [];

  void addHymn(Hymn hymn) {
    if (hymnsIds.contains(hymn.id)) return;
    hymnsIds = [...hymnsIds, hymn.id];
  }

  void removeHymn(Hymn hymn) {
    if (!hymnsIds.contains(hymn.id)) return;
    hymnsIds = hymnsIds.where((id) => id != hymn.id).toList();
  }

  void reorderHymns(int oldIndex, int newIndex) {
    hymnsIds = moveItem(hymnsIds, oldIndex, newIndex);
  }
}
