# Archive Custom Lists Instead of Deleting

**Issue:** #23
**Date:** 2026-03-28

## Summary

Custom lists should never be hard-deleted. Instead, they are archived and can be restored from settings. This preserves user data while keeping the main lists view clean.

## Approach

Separate storage keys for archived lists (parallel to active list keys). Archive moves data from active to archived keys; restore moves it back.

## Data Layer (`lib/infra/db.dart`)

New SharedPreferences keys:

- `archivedCustomLists` — ordered list of archived list IDs
- `archivedCustomList:name:{id}` — archived list name
- `archivedCustomList:hymnsIds:{id}` — archived list hymn IDs

New functions:

- `archiveCustomList(CustomList list, SharedPreferences prefs)` — copy data to archived keys, delete from active keys
- `restoreCustomList(CustomList list, SharedPreferences prefs)` — copy data to active keys (prepended to front), delete from archived keys
- `loadArchivedCustomLists(SharedPreferences prefs)` — load all archived lists (same pattern as `loadCustomLists`)

## Provider (`lib/app/providers/custom_lists/provider.dart`)

New methods on `CustomListProvider`:

- `archiveList(CustomList list)` — calls `archiveCustomList()`, notifies listeners
- `restoreList(CustomList list)` — calls `restoreCustomList()`, notifies listeners
- `getArchivedLists()` — calls `loadArchivedCustomLists()`

Existing `deleteList()` remains but is no longer called from the UI.

## UI Changes

### Custom lists view (`lib/app/widgets/custom_lists/list_tile.dart`)

- Replace `Icons.delete` with `Icons.archive_outlined`
- Change dialog text to inform about archiving: "Na pewno chcesz zarchiwizować listę {name}?"
- Call `provider.archiveList(list)` instead of `provider.deleteList(list)`

### Settings page (`lib/settings/page.dart`)

- Add new section "Przywracanie list" after the "Ulubione" section
- Contains a `ListTile` that navigates to `/settings/archived-lists`

### Archived lists page (new: `lib/settings/archived_lists_page.dart`)

- AppBar title: "Przywracanie list"
- `ListView` of archived lists, each showing:
  - List name
  - Hymn count
  - `Icons.unarchive` button on the right
- Tapping unarchive calls `provider.restoreList(list)` (no confirmation dialog — it's safe and reversible)
- Empty state text when no archived lists exist

### Routing (`lib/router.dart`)

- Add `/settings/archived-lists` route pointing to `ArchivedListsPage`

## Behavior

- Restored lists appear at the top of the active lists
- No permanent deletion of archived lists (they accumulate)
- The `CustomList` model is unchanged — no new fields needed
