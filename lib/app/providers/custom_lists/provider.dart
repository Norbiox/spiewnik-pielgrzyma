import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/gateway.dart';
import 'package:spiewnik_pielgrzyma/infra/db.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';

/// A change to a list, expressed so that it can be applied more than once —
/// to the local copy first, and again to fresh server state after a conflict.
typedef ListMutation = void Function(CustomList list);

/// How many times a push retries after losing a version race before giving up.
const int _maxPushAttempts = 3;

class CustomListProvider with ChangeNotifier {
  SharedPreferences prefs;
  final SharedListGateway? gateway;

  CustomListProvider(this.prefs, {this.gateway});

  List<CustomList> getLists() {
    return loadCustomLists(prefs);
  }

  void createNewList(String name) {
    List<CustomList> allLists = getLists();
    if (allLists.any((e) => e.name == name)) {
      throw Exception('List with name $name already exists');
    }
    CustomList list = CustomList(const Uuid().v4(), name);
    save(list);
  }

  void deleteList(CustomList list) {
    deleteCustomList(list, prefs);
    notifyListeners();
  }

  void archiveList(CustomList list) {
    archiveCustomList(list, prefs);
    notifyListeners();
  }

  void restoreList(CustomList list) {
    restoreCustomList(list, prefs);
    notifyListeners();
  }

  List<CustomList> getArchivedLists() {
    return loadArchivedCustomLists(prefs);
  }

  void reindex(List<CustomList> lists) {
    updateCustomListsOrder(lists, prefs);
    notifyListeners();
  }

  void save(CustomList list) {
    saveCustomList(list, prefs);
    notifyListeners();
  }

  CustomList getList(String listId) {
    return getLists().firstWhere((e) => e.id == listId);
  }

  // Intents. Each applies locally first so the UI reacts immediately, then
  // pushes to the server when the list is shared.

  Future<void> addHymn(CustomList list, Hymn hymn) =>
      _mutate(list, (l) => l.addHymn(hymn));

  Future<void> removeHymn(CustomList list, Hymn hymn) =>
      _mutate(list, (l) => l.removeHymn(hymn));

  Future<void> archiveHymn(CustomList list, Hymn hymn) =>
      _mutate(list, (l) => l.archiveHymn(hymn));

  Future<void> restoreHymn(CustomList list, Hymn hymn) =>
      _mutate(list, (l) => l.restoreHymn(hymn));

  Future<void> removeHymnFromArchive(CustomList list, Hymn hymn) =>
      _mutate(list, (l) => l.removeHymnFromArchive(hymn));

  Future<void> addHymnToArchive(CustomList list, Hymn hymn) =>
      _mutate(list, (l) => l.addHymnToArchive(hymn));

  Future<void> moveHymn(CustomList list, int hymnId, int? beforeHymnId) =>
      _mutate(list, (l) => l.moveHymnBefore(hymnId, beforeHymnId));

  Future<void> moveArchivedHymn(
          CustomList list, int hymnId, int? beforeHymnId) =>
      _mutate(list, (l) => l.moveArchivedHymnBefore(hymnId, beforeHymnId));

  Future<void> rename(CustomList list, String name) =>
      _mutate(list, (l) => l.name = name);

  /// Replaces the local copy with server state. Used by realtime and pull.
  void applyRemote(CustomList remote) {
    saveCustomList(remote, prefs);
    notifyListeners();
  }

  /// Deletes a shared list for everyone. Owner only.
  Future<void> deleteSharedList(CustomList list) async {
    await gateway?.delete(list.id);
    deleteCustomList(list, prefs);
    notifyListeners();
  }

  /// Drops this device's membership. The list stays alive for everyone else.
  Future<void> leaveSharedList(CustomList list) async {
    await gateway?.leave(list.id);
    deleteCustomList(list, prefs);
    notifyListeners();
  }

  /// Refreshes every shared list from the server.
  Future<void> refreshSharedLists() async {
    final gateway = this.gateway;
    if (gateway == null) return;

    final shared = getLists().where((l) => l.isShared).toList();
    if (shared.isEmpty) return;

    final remote = await gateway.fetchAll(shared.map((l) => l.id).toList());
    final remoteById = {for (final l in remote) l.id: l};

    for (final local in shared) {
      final fresh = remoteById[local.id] ?? await _rejoin(local, gateway);
      if (fresh == null) {
        deleteCustomList(local, prefs);
      } else {
        fresh.shareToken = local.shareToken;
        saveCustomList(fresh, prefs);
      }
    }
    notifyListeners();
  }

  /// Last resort for a shared list we hold a token for but can no longer read.
  ///
  /// Usually it is genuinely deleted. But this device may instead have lost the
  /// anonymous account that held its membership, and the stored token is enough
  /// to get back in — as a member, not as the owner. Returns null when the list
  /// really is gone.
  Future<CustomList?> _rejoin(
      CustomList local, SharedListGateway gateway) async {
    final token = local.shareToken;
    if (token == null) return null;
    try {
      await gateway.join(token);
      return await gateway.fetch(local.id);
    } catch (_) {
      return null;
    }
  }

  /// Uploads a private list so it can be shared. Returns it with its token and
  /// version filled in. Calling it on an already-shared list is a no-op.
  Future<CustomList> shareList(CustomList list) async {
    if (list.isShared) return list;
    final gateway = this.gateway;
    if (gateway == null) throw Exception('Sharing is unavailable');

    final shared = await gateway.create(list);
    saveCustomList(shared, prefs);
    notifyListeners();
    return shared;
  }

  Future<void> _mutate(CustomList list, ListMutation mutation) async {
    final before = list.copy();
    mutation(list);
    saveCustomList(list, prefs);
    notifyListeners();

    final gateway = this.gateway;
    if (!list.isShared || gateway == null) return;

    try {
      await _push(list, mutation, gateway);
    } catch (_) {
      saveCustomList(before, prefs);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _push(
      CustomList list, ListMutation mutation, SharedListGateway gateway) async {
    var candidate = list;

    for (var attempt = 0; attempt < _maxPushAttempts; attempt++) {
      final newVersion = await gateway.update(candidate);
      if (newVersion != null) {
        candidate.version = newVersion;
        saveCustomList(candidate, prefs);
        notifyListeners();
        return;
      }

      final fresh = await gateway.fetch(candidate.id);
      if (fresh == null) {
        // The owner deleted it while we were writing.
        deleteCustomList(candidate, prefs);
        notifyListeners();
        return;
      }

      fresh.shareToken = candidate.shareToken;
      fresh.isOwner = candidate.isOwner;
      mutation(fresh);
      candidate = fresh;
    }

    throw Exception('Could not save the list: too many version conflicts');
  }
}
