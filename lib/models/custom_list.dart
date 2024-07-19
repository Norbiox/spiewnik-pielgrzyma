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

  void addHymn(Hymn hymn) {
    if (hymns.contains(hymn)) return;
    hymns.add(hymn);
    hymnsOrder.add(hymn.id);
  }

  void removeHymn(Hymn hymn) {
    if (!hymnsOrder.contains(hymn.id)) return;
    hymns.remove(hymn);
    hymnsOrder.remove(hymn.id);
  }

  void reorderHymns(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = hymnsOrder.removeAt(oldIndex);
    hymnsOrder.insert(newIndex, item);
  }

  Hymn getHymnByIndex(int index) {
    return hymns.firstWhere((h) => h.id == hymnsOrder[index]);
  }
}
