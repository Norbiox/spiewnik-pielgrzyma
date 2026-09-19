import 'package:spiewnik_pielgrzyma/models/custom_list.dart';

/// What a shared list looks like before you join it.
class SharedListPreview {
  final String id;
  final String name;
  final int hymnsCount;

  const SharedListPreview(this.id, this.name, this.hymnsCount);
}

/// A live subscription to one shared list.
abstract class SharedListSubscription {
  Future<void> close();
}

/// The remote side of shared lists. Abstract so tests can substitute a fake.
abstract class SharedListGateway {
  /// Returns null when the list no longer exists or is not visible.
  Future<CustomList?> fetch(String id);

  Future<List<CustomList>> fetchAll(List<String> ids);

  /// Uploads a private list, returning it with its token and version filled in.
  Future<CustomList> create(CustomList list);

  /// Returns the new version, or null when [list.version] was stale.
  Future<int?> update(CustomList list);

  /// Deletes the list for everyone. Owner only.
  Future<void> delete(String id);

  /// Drops this user's membership. Members only.
  Future<void> leave(String id);

  Future<SharedListPreview?> preview(String token);

  /// Joins by token and returns the list id.
  Future<String> join(String token);

  SharedListSubscription subscribe(
    String id, {
    required void Function(CustomList) onChange,
    required void Function() onDelete,
  });
}
