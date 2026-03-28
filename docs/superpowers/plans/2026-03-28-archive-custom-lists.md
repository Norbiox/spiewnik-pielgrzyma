# Archive Custom Lists Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace hard-deletion of custom lists with archiving, and add a settings page to restore archived lists.

**Architecture:** Parallel SharedPreferences keys for archived lists (`archivedCustomLists`, `archivedCustomList:name:{id}`, `archivedCustomList:hymnsIds:{id}`). Archive moves data from active to archived keys; restore moves it back to the front. New `/settings/archived-lists` route for the restore UI.

**Tech Stack:** Flutter, SharedPreferences, Provider/watch_it, go_router, GetIt

---

### Task 1: Add archive/restore db functions

**Files:**
- Modify: `lib/infra/db.dart`
- Create: `test/infra/db_test.dart`

- [ ] **Step 1: Write tests for archive, restore, and load archived functions**

Create `test/infra/db_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/infra/db.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('archiveCustomList', () {
    test('moves list from active to archived keys', () {
      final list = CustomList('abc', 'My List', hymnsIds: [1, 2, 3]);
      saveCustomList(list, prefs);

      archiveCustomList(list, prefs);

      // Active keys removed
      expect(prefs.getStringList('customLists'), isEmpty);
      expect(prefs.getString('customList:name:abc'), isNull);
      expect(prefs.getStringList('customList:hymnsIds:abc'), isNull);

      // Archived keys present
      expect(prefs.getStringList('archivedCustomLists'), ['abc']);
      expect(prefs.getString('archivedCustomList:name:abc'), 'My List');
      expect(
          prefs.getStringList('archivedCustomList:hymnsIds:abc'), ['1', '2', '3']);
    });

    test('preserves other active lists when archiving one', () {
      final list1 = CustomList('a', 'List A', hymnsIds: [1]);
      final list2 = CustomList('b', 'List B', hymnsIds: [2]);
      saveCustomList(list1, prefs);
      saveCustomList(list2, prefs);

      archiveCustomList(list1, prefs);

      expect(prefs.getStringList('customLists'), ['b']);
      expect(prefs.getString('customList:name:b'), 'List B');
    });
  });

  group('restoreCustomList', () {
    test('moves list from archived to active keys at front', () {
      // Set up an existing active list
      final existing = CustomList('x', 'Existing', hymnsIds: [10]);
      saveCustomList(existing, prefs);

      // Archive a list, then restore it
      final list = CustomList('abc', 'My List', hymnsIds: [1, 2, 3]);
      saveCustomList(list, prefs);
      archiveCustomList(list, prefs);

      restoreCustomList(list, prefs);

      // Active keys restored, at front
      expect(prefs.getStringList('customLists'), ['abc', 'x']);
      expect(prefs.getString('customList:name:abc'), 'My List');
      expect(
          prefs.getStringList('customList:hymnsIds:abc'), ['1', '2', '3']);

      // Archived keys removed
      expect(prefs.getStringList('archivedCustomLists'), isEmpty);
      expect(prefs.getString('archivedCustomList:name:abc'), isNull);
      expect(prefs.getStringList('archivedCustomList:hymnsIds:abc'), isNull);
    });
  });

  group('loadArchivedCustomLists', () {
    test('returns empty list when no archived lists', () {
      expect(loadArchivedCustomLists(prefs), isEmpty);
    });

    test('loads archived lists with correct data', () {
      final list = CustomList('abc', 'My List', hymnsIds: [1, 2, 3]);
      saveCustomList(list, prefs);
      archiveCustomList(list, prefs);

      final archived = loadArchivedCustomLists(prefs);

      expect(archived.length, 1);
      expect(archived[0].id, 'abc');
      expect(archived[0].name, 'My List');
      expect(archived[0].hymnsIds, [1, 2, 3]);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `fvm flutter test test/infra/db_test.dart`
Expected: Compilation errors — `archiveCustomList`, `restoreCustomList`, `loadArchivedCustomLists` don't exist yet.

- [ ] **Step 3: Implement archive/restore/load functions in db.dart**

Add to `lib/infra/db.dart` after the existing custom lists section:

```dart
// ARCHIVED CUSTOM LISTS

const String archivedCustomListsKey = 'archivedCustomLists';
const String archivedCustomListHymnsIdsKey = 'archivedCustomList:hymnsIds:';
const String archivedCustomListNameKey = 'archivedCustomList:name:';

List<CustomList> loadArchivedCustomLists(SharedPreferences prefs) {
  final List<String> ids = prefs.getStringList(archivedCustomListsKey) ?? [];
  final List<CustomList> lists = [];
  for (final id in ids) {
    final List<int> hymnsIds =
        (prefs.getStringList('$archivedCustomListHymnsIdsKey$id') ?? [])
            .map((e) => int.parse(e))
            .toList();
    final String name = prefs.getString('$archivedCustomListNameKey$id') ?? '';
    lists.add(CustomList(id, name, hymnsIds: hymnsIds));
  }
  return lists;
}

void archiveCustomList(CustomList list, SharedPreferences prefs) {
  // Copy to archived keys
  prefs.setString('$archivedCustomListNameKey${list.id}', list.name);
  prefs.setStringList('$archivedCustomListHymnsIdsKey${list.id}',
      list.hymnsIds.map((e) => e.toString()).toList());
  final archivedIds = prefs.getStringList(archivedCustomListsKey) ?? [];
  if (!archivedIds.contains(list.id)) {
    prefs.setStringList(archivedCustomListsKey, [list.id, ...archivedIds]);
  }
  // Remove from active keys
  deleteCustomList(list, prefs);
}

void restoreCustomList(CustomList list, SharedPreferences prefs) {
  // Copy to active keys (prepend to front)
  prefs.setString('$customListNameKey${list.id}', list.name);
  prefs.setStringList('$customListHymnsIdsKey${list.id}',
      list.hymnsIds.map((e) => e.toString()).toList());
  final activeIds = prefs.getStringList(customListsKey) ?? [];
  prefs.setStringList(customListsKey, [list.id, ...activeIds]);
  // Remove from archived keys
  prefs.remove('$archivedCustomListNameKey${list.id}');
  prefs.remove('$archivedCustomListHymnsIdsKey${list.id}');
  prefs.setStringList(
      archivedCustomListsKey,
      (prefs.getStringList(archivedCustomListsKey) ?? [])
          .where((e) => e != list.id)
          .toList());
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `fvm flutter test test/infra/db_test.dart`
Expected: All 5 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/infra/db.dart test/infra/db_test.dart
git commit -m "feat: add archive/restore db functions for custom lists (#23)"
```

---

### Task 2: Add provider methods

**Files:**
- Modify: `lib/app/providers/custom_lists/provider.dart`
- Create: `test/app/providers/custom_lists/provider_test.dart`

- [ ] **Step 1: Write tests for provider archive, restore, getArchivedLists**

Create `test/app/providers/custom_lists/provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';

void main() {
  late SharedPreferences prefs;
  late CustomListProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    provider = CustomListProvider(prefs);
  });

  test('archiveList moves list to archived and notifies', () {
    provider.createNewList('Test List');
    final list = provider.getLists().first;

    var notified = false;
    provider.addListener(() => notified = true);

    provider.archiveList(list);

    expect(provider.getLists(), isEmpty);
    expect(provider.getArchivedLists().length, 1);
    expect(provider.getArchivedLists().first.name, 'Test List');
    expect(notified, isTrue);
  });

  test('restoreList moves list back to active at front and notifies', () {
    provider.createNewList('First');
    provider.createNewList('Second');
    final second = provider.getLists().first; // 'Second' is at front

    provider.archiveList(second);

    var notified = false;
    provider.addListener(() => notified = true);

    final archived = provider.getArchivedLists().first;
    provider.restoreList(archived);

    final lists = provider.getLists();
    expect(lists.length, 2);
    expect(lists[0].name, 'Second');
    expect(lists[1].name, 'First');
    expect(provider.getArchivedLists(), isEmpty);
    expect(notified, isTrue);
  });

  test('getArchivedLists returns empty when none archived', () {
    expect(provider.getArchivedLists(), isEmpty);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `fvm flutter test test/app/providers/custom_lists/provider_test.dart`
Expected: Compilation errors — `archiveList`, `restoreList`, `getArchivedLists` don't exist yet.

- [ ] **Step 3: Add methods to CustomListProvider**

Add to `lib/app/providers/custom_lists/provider.dart` inside the `CustomListProvider` class, after the existing `deleteList` method:

```dart
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
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `fvm flutter test test/app/providers/custom_lists/provider_test.dart`
Expected: All 3 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/app/providers/custom_lists/provider.dart test/app/providers/custom_lists/provider_test.dart
git commit -m "feat: add archive/restore methods to CustomListProvider (#23)"
```

---

### Task 3: Update custom list tile to archive instead of delete

**Files:**
- Modify: `lib/app/widgets/custom_lists/list_tile.dart`

- [ ] **Step 1: Replace delete icon with archive icon**

In `lib/app/widgets/custom_lists/list_tile.dart`, change:

```dart
icon: const Icon(Icons.delete),
```

to:

```dart
icon: const Icon(Icons.archive_outlined),
```

- [ ] **Step 2: Rename dialog method and update text**

Rename `_showDeleteListDialog` to `_showArchiveListDialog` and update the dialog content text.

Change:

```dart
onPressed: () async {
  await _showDeleteListDialog(context, list);
},
```

to:

```dart
onPressed: () async {
  await _showArchiveListDialog(context, list);
},
```

Rename the method and update its contents:

```dart
Future<void> _showArchiveListDialog(
    BuildContext context, CustomList list) async {
  CustomListProvider provider = GetIt.I<CustomListProvider>();

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text("Na pewno chcesz zarchiwizować listę ${list.name}?"),
        actions: <Widget>[
          FilledButton.tonal(
            child: const Text("Nie"),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
              child: const Text("Tak"),
              onPressed: () {
                provider.archiveList(list);
                Navigator.pop(context);
              })
        ],
      );
    },
  );
}
```

- [ ] **Step 3: Run analysis**

Run: `fvm flutter analyze`
Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/app/widgets/custom_lists/list_tile.dart
git commit -m "feat: replace delete with archive in custom list tile (#23)"
```

---

### Task 4: Create archived lists page

**Files:**
- Create: `lib/settings/archived_lists_page.dart`

- [ ] **Step 1: Create the ArchivedListsPage widget**

Create `lib/settings/archived_lists_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:watch_it/watch_it.dart';

class ArchivedListsPage extends WatchingWidget {
  const ArchivedListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = GetIt.I<CustomListProvider>();
    watch(provider);

    final List<CustomList> archivedLists = provider.getArchivedLists();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Przywracanie list'),
      ),
      body: archivedLists.isEmpty
          ? const Center(
              child: Text('Brak zarchiwizowanych list'),
            )
          : ListView.builder(
              itemCount: archivedLists.length,
              itemBuilder: (context, index) {
                final list = archivedLists[index];
                return ListTile(
                  title: Text(list.name),
                  subtitle: Text('pieśni: ${list.hymnsIds.length}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.unarchive),
                    onPressed: () => provider.restoreList(list),
                  ),
                );
              },
            ),
    );
  }
}
```

- [ ] **Step 2: Run analysis**

Run: `fvm flutter analyze`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/settings/archived_lists_page.dart
git commit -m "feat: add archived lists restore page (#23)"
```

---

### Task 5: Add route and settings entry

**Files:**
- Modify: `lib/router.dart`
- Modify: `lib/settings/page.dart`

- [ ] **Step 1: Add route for archived lists page**

In `lib/router.dart`, add the import at the top:

```dart
import 'package:spiewnik_pielgrzyma/settings/archived_lists_page.dart';
```

Add a new child route under the `settings` route. Change:

```dart
GoRoute(
    path: 'settings',
    builder: (BuildContext context, GoRouterState state) =>
        const SettingsPage()),
```

to:

```dart
GoRoute(
    path: 'settings',
    builder: (BuildContext context, GoRouterState state) =>
        const SettingsPage(),
    routes: <RouteBase>[
      GoRoute(
          path: 'archived-lists',
          builder: (BuildContext context, GoRouterState state) =>
              const ArchivedListsPage()),
    ]),
```

- [ ] **Step 2: Add "Przywracanie list" section to settings page**

In `lib/settings/page.dart`, add the import at the top:

```dart
import 'package:get_it/get_it.dart';
```

In the `ListView` children, after the `_ConfirmFavoriteRemovalTile()` and its `Divider()`, add:

```dart
// Archived lists section
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Text(
    'Przywracanie list',
    style: Theme.of(context).textTheme.titleMedium,
  ),
),
ListTile(
  leading: const Icon(Icons.archive_outlined),
  title: const Text('Zarchiwizowane listy'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => context.push('/settings/archived-lists'),
),
const Divider(),
```

- [ ] **Step 3: Run analysis**

Run: `fvm flutter analyze`
Expected: No issues found.

- [ ] **Step 4: Run all tests**

Run: `fvm flutter test`
Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/router.dart lib/settings/page.dart
git commit -m "feat: add archived lists route and settings entry (#23)"
```
