import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:spiewnik_pielgrzyma/utils/list.dart';

class CustomList {
  String id;
  String name;
  List<int> hymnsIds;

  CustomList(this.id, this.name, {List<int>? hymnsIds})
      : hymnsIds = hymnsIds ?? [];

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
