import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:spiewnik_pielgrzyma/utils/list.dart';

class CustomList {
  String id;
  String name;
  List<int> hymnsIds;
  List<int> archivedHymnsIds;

  CustomList(this.id, this.name,
      {List<int>? hymnsIds, List<int>? archivedHymnsIds})
      : hymnsIds = hymnsIds ?? [],
        archivedHymnsIds = archivedHymnsIds ?? [];

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

  // archived hymns

  void archiveHymn(Hymn hymn) {
    if (!hymnsIds.contains(hymn.id) || archivedHymnsIds.contains(hymn.id)) {
      return;
    }
    archivedHymnsIds = [...archivedHymnsIds, hymn.id];
    hymnsIds = hymnsIds.where((id) => id != hymn.id).toList();
  }

  void restoreHymn(Hymn hymn) {
    if (hymnsIds.contains(hymn.id) || !archivedHymnsIds.contains(hymn.id)) {
      return;
    }
    archivedHymnsIds = archivedHymnsIds.where((id) => id != hymn.id).toList();
    hymnsIds = [...hymnsIds, hymn.id];
  }

  void reorderArchivedHymns(int oldIndex, int newIndex) {
    archivedHymnsIds = moveItem(archivedHymnsIds, oldIndex, newIndex);
  }

  void removeHymnFromArchive(Hymn hymn) {
    if (!archivedHymnsIds.contains(hymn.id)) return;
    archivedHymnsIds = archivedHymnsIds.where((id) => id != hymn.id).toList();
  }

  void addHymnToArchive(Hymn hymn) {
    if (archivedHymnsIds.contains(hymn.id)) return;
    archivedHymnsIds = [...archivedHymnsIds, hymn.id];
  }
}
