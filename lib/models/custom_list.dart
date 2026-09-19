import 'package:spiewnik_pielgrzyma/models/hymn.dart';

class CustomList {
  String id;
  String name;
  List<int> hymnsIds;
  List<int> archivedHymnsIds;

  /// Invite token. Null means the list is private and lives only on this device.
  String? shareToken;

  /// Whether this device's user created the list. Owners may delete it for
  /// everyone; members may only leave it.
  bool isOwner;

  /// Server-side optimistic-locking counter. Meaningless for private lists.
  int version;

  CustomList(
    this.id,
    this.name, {
    List<int>? hymnsIds,
    List<int>? archivedHymnsIds,
    this.shareToken,
    this.isOwner = false,
    this.version = 0,
  })  : hymnsIds = hymnsIds ?? [],
        archivedHymnsIds = archivedHymnsIds ?? [];

  bool get isShared => shareToken != null;

  CustomList copy() => CustomList(
        id,
        name,
        hymnsIds: [...hymnsIds],
        archivedHymnsIds: [...archivedHymnsIds],
        shareToken: shareToken,
        isOwner: isOwner,
        version: version,
      );

  void addHymn(Hymn hymn) {
    if (hymnsIds.contains(hymn.id)) return;
    hymnsIds = [...hymnsIds, hymn.id];
  }

  void removeHymn(Hymn hymn) {
    if (!hymnsIds.contains(hymn.id)) return;
    hymnsIds = hymnsIds.where((id) => id != hymn.id).toList();
  }

  /// Moves [hymnId] directly in front of [beforeHymnId], or to the end when
  /// [beforeHymnId] is null or no longer present.
  ///
  /// Expressed with ids rather than indices so that it can be re-applied to
  /// state another user has changed in the meantime.
  void moveHymnBefore(int hymnId, int? beforeHymnId) {
    hymnsIds = _moved(hymnsIds, hymnId, beforeHymnId);
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

  void moveArchivedHymnBefore(int hymnId, int? beforeHymnId) {
    archivedHymnsIds = _moved(archivedHymnsIds, hymnId, beforeHymnId);
  }

  static List<int> _moved(List<int> ids, int hymnId, int? beforeHymnId) {
    if (!ids.contains(hymnId)) return ids;
    final rest = ids.where((id) => id != hymnId).toList();
    final at = beforeHymnId == null ? -1 : rest.indexOf(beforeHymnId);
    rest.insert(at < 0 ? rest.length : at, hymnId);
    return rest;
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
