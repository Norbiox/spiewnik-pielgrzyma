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
