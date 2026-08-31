# Shared Custom Lists Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let two or more users collaborate on one custom list, shared by link, with edits propagating live while a list is open.

**Architecture:** Supabase (Postgres + RLS + Realtime + anonymous auth) stores shared lists as one row each. The local `SharedPreferences` cache stays the source of truth for rendering, so `CustomListProvider` remains synchronous and no existing view needs restructuring. Writes are optimistic with a version check; on conflict the client re-applies the *intent* to fresh state rather than overwriting it.

**Tech Stack:** Flutter 3.41.6 (via fvm), `supabase_flutter` ^2.17.2, `share_plus` ^13.3.0, `go_router`, `get_it` / `watch_it`, `connectivity_plus`, Supabase CLI.

**Spec:** `docs/superpowers/specs/2026-08-31-shared-custom-lists-design.md`

## Global Constraints

- Flutter is pinned to 3.41.6 in `.fvmrc`; every command runs through `fvm` (`fvm flutter`, `fvm dart`).
- `fvm flutter analyze --fatal-infos` must report `No issues found!` — the pre-commit hook enforces it and will reject the commit otherwise.
- User-facing strings are Polish. Code, comments, commit messages and documentation are English.
- The app targets Android and web. iOS is out of scope for this feature.
- Package name / applicationId: `pl.norbertchmiel.spiewnik_pielgrzyma`.
- Domain: `spiewnikpielgrzyma.norbertchmiel.pl`.
- Play app signing SHA-256: `90:C4:FF:90:97:1C:05:1D:80:7B:BC:E4:46:7A:1B:7E:56:DD:45:6D:7C:1B:84:A7:75:71:16:A1:4E:D8:46:90`
- Env vars: `SUPABASE_URL` (`https://<project-ref>.supabase.co`) and `SUPABASE_PUBLISHABLE_KEY` (`sb_publishable_...`).
- Shared lists are editable online only. Offline they render from cache and editing is disabled.
- No new dev dependencies. Test doubles are hand-written fakes.

## File Structure

**Created:**

| Path | Responsibility |
|---|---|
| `supabase/migrations/<ts>_shared_lists.sql` | Tables, RLS policies, RPC functions |
| `.github/workflows/supabase-keepalive.yml` | Pings the API so the free project never pauses |
| `lib/infra/supabase.dart` | Client bootstrap and on-demand anonymous sign-in |
| `lib/app/providers/custom_lists/gateway.dart` | `SharedListGateway` interface + `SharedListPreview` |
| `lib/app/providers/custom_lists/supabase_gateway.dart` | Supabase implementation of the interface |
| `lib/app/widgets/utils/list_action.dart` | Runs a provider intent and surfaces failures as a snackbar |
| `lib/app/widgets/custom_lists/join_page.dart` | The "add shared list?" screen behind `/dolacz` |
| `web/dolacz.html` | Static landing page: Android → Play, desktop → web build |
| `web/.well-known/assetlinks.json` | Digital Asset Links statement for App Links |
| `test/app/providers/custom_lists/sync_test.dart` | Retry, rollback and delete-detection against a fake gateway |

**Modified:** `lib/models/custom_list.dart`, `lib/infra/db.dart`, `lib/app/providers/custom_lists/provider.dart`, `lib/main.dart`, `lib/router.dart`, the six custom-list widgets, `android/app/src/main/AndroidManifest.xml`, `.github/workflows/release.yml`, `.env.example`, `pubspec.yaml`, `test/infra/db_test.dart`, `test/app/providers/custom_lists/provider_test.dart`.

---

### Task 1: Supabase schema, policies and keepalive

**Files:**
- Create: `supabase/migrations/20260831000000_shared_lists.sql`
- Create: `.github/workflows/supabase-keepalive.yml`
- Modify: `.gitignore`

**Interfaces:**
- Consumes: nothing.
- Produces: tables `public.shared_lists` and `public.shared_list_members`; RPC `public.preview_shared_list(uuid)` returning `(id uuid, name text, hymns_count int)`; RPC `public.join_shared_list(uuid)` returning `uuid`.

- [ ] **Step 1: Link the Supabase CLI to the project**

```bash
mise use -g supabase   # or: npm i -g supabase
supabase login
supabase link --project-ref <project-ref>
```

`<project-ref>` is the subdomain of `SUPABASE_URL`, also visible in the dashboard address bar.

- [ ] **Step 2: Enable anonymous sign-in and tighten the rate limit**

In the dashboard: Authentication → Sign In / Providers → enable **Anonymous sign-ins**. Then Authentication → Rate Limits → lower "anonymous sign-in" from 30 to 10 requests per hour per IP.

- [ ] **Step 3: Create the migration file**

```bash
supabase migration new shared_lists
```

- [ ] **Step 4: Write the migration**

Paste into the generated `supabase/migrations/<timestamp>_shared_lists.sql`:

```sql
create table public.shared_lists (
  id                  uuid primary key,
  share_token         uuid not null unique default gen_random_uuid(),
  owner_id            uuid not null references auth.users(id) on delete cascade,
  name                text not null,
  hymns_ids           int[] not null default '{}',
  archived_hymns_ids  int[] not null default '{}',
  version             bigint not null default 1
);

create table public.shared_list_members (
  list_id  uuid references public.shared_lists(id) on delete cascade,
  user_id  uuid references auth.users(id)          on delete cascade,
  primary key (list_id, user_id)
);

create index shared_list_members_user_id_idx on public.shared_list_members (user_id);

alter table public.shared_lists        enable row level security;
alter table public.shared_list_members enable row level security;

-- Supabase grants CRUD to anon/authenticated by default; strip anon entirely.
revoke all on public.shared_lists, public.shared_list_members from anon;

-- Members may edit contents, but never reassign ownership or the invite token.
revoke update on public.shared_lists from authenticated;
grant  update (name, hymns_ids, archived_hymns_ids, version)
       on public.shared_lists to authenticated;

create or replace function public.is_list_participant(p_list_id uuid)
returns boolean language sql stable security invoker set search_path = '' as $$
  select exists (
    select 1 from public.shared_lists l
    where l.id = p_list_id and l.owner_id = (select auth.uid())
  ) or exists (
    select 1 from public.shared_list_members m
    where m.list_id = p_list_id and m.user_id = (select auth.uid())
  );
$$;

create policy shared_lists_select on public.shared_lists
  for select to authenticated using (public.is_list_participant(id));

create policy shared_lists_update on public.shared_lists
  for update to authenticated using (public.is_list_participant(id));

create policy shared_lists_insert on public.shared_lists
  for insert to authenticated with check (owner_id = (select auth.uid()));

create policy shared_lists_delete on public.shared_lists
  for delete to authenticated using (owner_id = (select auth.uid()));

create policy members_select on public.shared_list_members
  for select to authenticated using (user_id = (select auth.uid()));

create policy members_delete on public.shared_list_members
  for delete to authenticated using (user_id = (select auth.uid()));
-- Deliberately no INSERT policy: joining is only possible through join_shared_list().

create or replace function public.preview_shared_list(p_token uuid)
returns table (id uuid, name text, hymns_count int)
language sql stable security definer set search_path = '' as $$
  select l.id, l.name, cardinality(l.hymns_ids)
  from public.shared_lists l
  where l.share_token = p_token;
$$;

create or replace function public.join_shared_list(p_token uuid)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_id uuid;
begin
  select l.id into v_id from public.shared_lists l where l.share_token = p_token;
  if v_id is null then
    raise exception 'list_not_found' using errcode = 'no_data_found';
  end if;
  insert into public.shared_list_members (list_id, user_id)
  values (v_id, auth.uid())
  on conflict do nothing;
  return v_id;
end;
$$;

revoke all on function public.preview_shared_list(uuid) from public, anon;
revoke all on function public.join_shared_list(uuid)    from public, anon;
grant execute on function public.preview_shared_list(uuid) to authenticated;
grant execute on function public.join_shared_list(uuid)    to authenticated;

alter publication supabase_realtime add table public.shared_lists;
```

- [ ] **Step 5: Apply the migration**

Run: `supabase db push`
Expected: `Finished supabase db push.` with the migration listed as applied.

- [ ] **Step 6: Verify that RLS actually blocks an unauthenticated caller**

```bash
export SUPABASE_URL=https://<project-ref>.supabase.co
export KEY=sb_publishable_...

curl -s "$SUPABASE_URL/rest/v1/shared_lists?select=*" -H "apikey: $KEY"
curl -s -o /dev/null -w '%{http_code}\n' -X POST "$SUPABASE_URL/rest/v1/shared_lists" \
     -H "apikey: $KEY" -H "Content-Type: application/json" \
     -d '{"id":"00000000-0000-0000-0000-000000000001","name":"x","owner_id":"00000000-0000-0000-0000-000000000002"}'
```

Expected: the first prints `[]` — a read blocked by RLS returns an empty array, not an error, so any rows here mean RLS is off. The second prints `401`.

- [ ] **Step 7: Check the Security Advisor**

Dashboard → Advisors → Security Advisor.
Expected: no findings for `shared_lists`, `shared_list_members`, or any of the three functions. In particular no "RLS disabled in public" and no "function search_path mutable".

- [ ] **Step 8: Add the keepalive workflow**

Create `.github/workflows/supabase-keepalive.yml`:

```yaml
name: Supabase keepalive

# Free Supabase projects pause after 7 days without traffic. This app is
# seasonal, so out of pilgrimage season nothing would touch the API.
on:
  schedule:
    - cron: '0 5 */3 * *'
  workflow_dispatch:

jobs:
  ping:
    runs-on: ubuntu-latest
    steps:
      - name: Ping the Data API
        run: |
          code=$(curl -s -o /dev/null -w '%{http_code}' \
            "${{ secrets.SUPABASE_URL }}/rest/v1/shared_lists?select=id&limit=1" \
            -H "apikey: ${{ secrets.SUPABASE_PUBLISHABLE_KEY }}")
          echo "HTTP $code"
          test "$code" = "200"
```

- [ ] **Step 9: Add the GitHub secrets**

In the repository: Settings → Secrets and variables → Actions → New repository secret. Add `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`.

- [ ] **Step 10: Run the workflow once by hand**

Actions → Supabase keepalive → Run workflow.
Expected: green, log shows `HTTP 200`.

- [ ] **Step 11: Save the cleanup query for dormant anonymous accounts**

Anonymous accounts are never removed automatically, and each one counts toward MAU. Append to the
migration file as a comment, so the query lives next to the schema it depends on rather than in
someone's shell history:

```sql
-- Run by hand from the SQL editor when anonymous user count grows.
--
-- NOT the query from the Supabase docs: owner_id cascades, so deleting every
-- anonymous account older than 30 days would take live shared lists with it.
-- These two NOT EXISTS clauses are what keep participants alive.
--
-- delete from auth.users u
-- where u.is_anonymous
--   and u.created_at < now() - interval '30 days'
--   and not exists (select 1 from public.shared_lists        where owner_id = u.id)
--   and not exists (select 1 from public.shared_list_members where user_id  = u.id);
```

- [ ] **Step 12: Ignore local Supabase artefacts**

Append to `.gitignore`:

```
# Supabase CLI local state
supabase/.branches
supabase/.temp
```

- [ ] **Step 13: Commit**

```bash
git add supabase/migrations .github/workflows/supabase-keepalive.yml .gitignore
git commit -m "feat: add Supabase schema and RLS for shared lists"
```

---

### Task 2: Supabase client bootstrap

**Files:**
- Create: `lib/infra/supabase.dart`
- Modify: `pubspec.yaml`, `.env.example`, `lib/main.dart`, `.github/workflows/release.yml`

**Interfaces:**
- Consumes: Task 1's project.
- Produces: `Future<void> initSupabase()`, `SupabaseClient get supabase`, `Future<String> ensureSignedIn()` returning the current user id, signing in anonymously on first use.

- [ ] **Step 1: Add the dependency**

```bash
fvm flutter pub add supabase_flutter
```

Expected: `pubspec.yaml` gains `supabase_flutter: ^2.17.2` or newer.

- [ ] **Step 2: Add the env vars**

Append to `.env.example`:

```
# Supabase project URL, e.g. https://abcdefgh.supabase.co
SUPABASE_URL=xxx
# Publishable Supabase key (sb_publishable_...), safe to ship in the client
SUPABASE_PUBLISHABLE_KEY=xxx
```

Then put the real values in your local `.env` (which is gitignored).

- [ ] **Step 3: Write the bootstrap**

Create `lib/infra/supabase.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initializes the Supabase client. Makes no network call, so it is safe to
/// run at startup even offline.
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );
}

SupabaseClient get supabase => Supabase.instance.client;

/// Returns the current user id, creating an anonymous account on first use.
///
/// Sign-in is deliberately lazy: it happens when a user first shares or joins
/// a list, never at startup, so users who never touch sharing never get an
/// account.
Future<String> ensureSignedIn() async {
  final existing = supabase.auth.currentUser;
  if (existing != null) return existing.id;
  final response = await supabase.auth.signInAnonymously();
  return response.user!.id;
}
```

- [ ] **Step 4: Call it from main**

In `lib/main.dart`, inside `main()`, between `await dotenv.load();` and `setup();`:

```dart
  await dotenv.load();
  await initSupabase();
  setup();
```

Add the import:

```dart
import 'package:spiewnik_pielgrzyma/infra/supabase.dart';
```

- [ ] **Step 5: Pass the secrets through CI**

In `.github/workflows/release.yml`, both the `release-android` and `release-web` jobs have a `Create .env file` step. Append two lines to each:

```yaml
          echo "SUPABASE_URL=${{ secrets.SUPABASE_URL }}" >> .env
          echo "SUPABASE_PUBLISHABLE_KEY=${{ secrets.SUPABASE_PUBLISHABLE_KEY }}" >> .env
```

`.github/workflows/analyse.yml` needs no change: it writes an empty `.env`, and unit tests never
run `main()`, so `dotenv` is never read there.

- [ ] **Step 6: Verify the app still starts**

Run: `fvm flutter run -d chrome`
Expected: the app opens as before. No account is created yet — check Authentication → Users in the dashboard, it stays empty.

- [ ] **Step 7: Verify analysis and tests**

Run: `fvm flutter analyze --fatal-infos && fvm flutter test`
Expected: `No issues found!` and all tests pass.

- [ ] **Step 8: Commit**

```bash
git add pubspec.yaml pubspec.lock .env.example lib/infra/supabase.dart lib/main.dart .github/workflows
git commit -m "feat: initialize Supabase client with lazy anonymous sign-in"
```

---

### Task 3: Sharing metadata on the model and in local storage

**Files:**
- Modify: `lib/models/custom_list.dart`, `lib/infra/db.dart`
- Test: `test/infra/db_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `CustomList` fields `String? shareToken`, `bool isOwner`, `int version`; getter `bool get isShared`; method `CustomList copy()`. Storage keys `sharedListTokenKey`, `sharedListOwnerKey`, `sharedListVersionKey`.

- [ ] **Step 1: Write the failing tests**

Append to `test/infra/db_test.dart`, inside `main()`:

```dart
  group('shared list metadata', () {
    test('round-trips token, ownership and version', () {
      final list = CustomList('id-1', 'Shared',
          hymnsIds: [1, 2],
          shareToken: 'tok-1',
          isOwner: true,
          version: 7);

      saveCustomList(list, prefs);
      final loaded = loadCustomLists(prefs).first;

      expect(loaded.shareToken, 'tok-1');
      expect(loaded.isOwner, isTrue);
      expect(loaded.version, 7);
      expect(loaded.isShared, isTrue);
    });

    test('a list without a token loads as private', () {
      saveCustomList(CustomList('id-2', 'Private', hymnsIds: [3]), prefs);
      final loaded = loadCustomLists(prefs).first;

      expect(loaded.shareToken, isNull);
      expect(loaded.isOwner, isFalse);
      expect(loaded.version, 0);
      expect(loaded.isShared, isFalse);
    });

    test('deleting a list clears its sharing metadata', () {
      final list = CustomList('id-3', 'Shared', shareToken: 'tok-3', version: 2);
      saveCustomList(list, prefs);
      deleteCustomList(list, prefs);

      expect(prefs.getString('$sharedListTokenKey${list.id}'), isNull);
      expect(prefs.getBool('$sharedListOwnerKey${list.id}'), isNull);
      expect(prefs.getInt('$sharedListVersionKey${list.id}'), isNull);
    });
  });
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `fvm flutter test test/infra/db_test.dart`
Expected: FAIL — the compiler rejects the named arguments `shareToken`, `isOwner`, `version` and the undefined constants `sharedListTokenKey`, `sharedListOwnerKey`, `sharedListVersionKey`.

- [ ] **Step 3: Extend the model**

In `lib/models/custom_list.dart`, replace the fields and constructor:

```dart
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
```

Leave the existing methods (`addHymn`, `removeHymn`, `archiveHymn`, …) untouched.

- [ ] **Step 4: Extend the storage layer**

In `lib/infra/db.dart`, add the keys next to the existing custom-list keys:

```dart
const String sharedListTokenKey = 'sharedList:token:';
const String sharedListOwnerKey = 'sharedList:owner:';
const String sharedListVersionKey = 'sharedList:version:';
```

In `loadCustomLists`, replace the `customLists.add(...)` call with:

```dart
    customLists.add(CustomList(
      id,
      name,
      hymnsIds: hymnsIds,
      archivedHymnsIds: archivedHymnsIds,
      shareToken: prefs.getString('$sharedListTokenKey$id'),
      isOwner: prefs.getBool('$sharedListOwnerKey$id') ?? false,
      version: prefs.getInt('$sharedListVersionKey$id') ?? 0,
    ));
```

In `saveCustomList`, after the existing `setStringList` calls and before the `customListsKey` block:

```dart
  final token = list.shareToken;
  if (token != null) {
    prefs.setString('$sharedListTokenKey${list.id}', token);
    prefs.setBool('$sharedListOwnerKey${list.id}', list.isOwner);
    prefs.setInt('$sharedListVersionKey${list.id}', list.version);
  } else {
    prefs.remove('$sharedListTokenKey${list.id}');
    prefs.remove('$sharedListOwnerKey${list.id}');
    prefs.remove('$sharedListVersionKey${list.id}');
  }
```

In `deleteCustomList`, add three removals next to the existing ones:

```dart
  prefs.remove('$sharedListTokenKey${list.id}');
  prefs.remove('$sharedListOwnerKey${list.id}');
  prefs.remove('$sharedListVersionKey${list.id}');
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `fvm flutter test test/infra/db_test.dart`
Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
fvm flutter analyze --fatal-infos
git add lib/models/custom_list.dart lib/infra/db.dart test/infra/db_test.dart
git commit -m "feat: persist sharing metadata alongside custom lists"
```

---

### Task 4: Id-based reordering

**Files:**
- Modify: `lib/models/custom_list.dart`
- Test: `test/models/custom_list_test.dart` (create)

**Interfaces:**
- Consumes: Task 3's `CustomList`.
- Produces: `void moveHymnBefore(int hymnId, int? beforeHymnId)` and `void moveArchivedHymnBefore(int hymnId, int? beforeHymnId)`. A null `beforeHymnId` moves the hymn to the end. Replaces `reorderHymns(int, int)` and `reorderArchivedHymns(int, int)`.

**Why:** the retry path re-applies a mutation to state someone else has already changed. An index captured before their edit points at a different hymn afterwards; an id does not.

- [ ] **Step 1: Write the failing tests**

Create `test/models/custom_list_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';

void main() {
  group('moveHymnBefore', () {
    test('moves a hymn in front of another', () {
      final list = CustomList('id', 'L', hymnsIds: [1, 2, 3, 4]);
      list.moveHymnBefore(4, 2);
      expect(list.hymnsIds, [1, 4, 2, 3]);
    });

    test('a null target moves the hymn to the end', () {
      final list = CustomList('id', 'L', hymnsIds: [1, 2, 3]);
      list.moveHymnBefore(1, null);
      expect(list.hymnsIds, [2, 3, 1]);
    });

    test('survives a concurrent insertion, which an index would not', () {
      // The user drags hymn 4 in front of hymn 2. Meanwhile someone else
      // prepends hymn 9, shifting every index by one.
      final concurrent = CustomList('id', 'L', hymnsIds: [9, 1, 2, 3, 4]);
      concurrent.moveHymnBefore(4, 2);
      expect(concurrent.hymnsIds, [9, 1, 4, 2, 3]);
    });

    test('ignores a hymn that is no longer in the list', () {
      final list = CustomList('id', 'L', hymnsIds: [1, 2]);
      list.moveHymnBefore(7, 1);
      expect(list.hymnsIds, [1, 2]);
    });

    test('appends when the target is no longer in the list', () {
      final list = CustomList('id', 'L', hymnsIds: [1, 2, 3]);
      list.moveHymnBefore(1, 99);
      expect(list.hymnsIds, [2, 3, 1]);
    });
  });

  group('moveArchivedHymnBefore', () {
    test('reorders the archive independently', () {
      final list = CustomList('id', 'L',
          hymnsIds: [1], archivedHymnsIds: [5, 6, 7]);
      list.moveArchivedHymnBefore(7, 5);
      expect(list.archivedHymnsIds, [7, 5, 6]);
      expect(list.hymnsIds, [1]);
    });
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `fvm flutter test test/models/custom_list_test.dart`
Expected: FAIL — `The method 'moveHymnBefore' isn't defined for the type 'CustomList'`.

- [ ] **Step 3: Implement the methods**

In `lib/models/custom_list.dart`, replace `reorderHymns` with:

```dart
  /// Moves [hymnId] directly in front of [beforeHymnId], or to the end when
  /// [beforeHymnId] is null or no longer present.
  ///
  /// Expressed with ids rather than indices so that it can be re-applied to
  /// state another user has changed in the meantime.
  void moveHymnBefore(int hymnId, int? beforeHymnId) {
    hymnsIds = _moved(hymnsIds, hymnId, beforeHymnId);
  }
```

Replace `reorderArchivedHymns` with:

```dart
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
```

Remove the now-unused `import 'package:spiewnik_pielgrzyma/utils/list.dart';` if nothing else in the file uses `moveItem`.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `fvm flutter test test/models/custom_list_test.dart`
Expected: all six tests pass.

- [ ] **Step 5: Fix the two call sites so the app still compiles**

`lib/app/widgets/custom_lists/custom_list.dart:70` — replace the `onReorder` body of `_hymnsList`:

```dart
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) newIndex -= 1;
        final hymnId = list.hymnsIds[oldIndex];
        final rest = list.hymnsIds.where((id) => id != hymnId).toList();
        final beforeHymnId = newIndex < rest.length ? rest[newIndex] : null;
        list.moveHymnBefore(hymnId, beforeHymnId);
        provider.save(list);
      },
```

`lib/app/widgets/custom_lists/custom_list.dart:114` — the same for `_hymnsArchive`, using `list.archivedHymnsIds` and `list.moveArchivedHymnBefore`.

- [ ] **Step 6: Verify the whole suite and analysis**

Run: `fvm flutter analyze --fatal-infos && fvm flutter test`
Expected: `No issues found!` and all tests pass.

- [ ] **Step 7: Commit**

```bash
git add lib/models/custom_list.dart lib/app/widgets/custom_lists/custom_list.dart test/models/custom_list_test.dart
git commit -m "refactor: reorder hymns by id instead of index"
```

---

### Task 5: Gateway interface and provider intents with retry

**Files:**
- Create: `lib/app/providers/custom_lists/gateway.dart`
- Modify: `lib/app/providers/custom_lists/provider.dart`
- Test: `test/app/providers/custom_lists/sync_test.dart` (create)

**Interfaces:**
- Consumes: Tasks 3 and 4.
- Produces:
  - `abstract class SharedListGateway` with `Future<CustomList?> fetch(String id)`, `Future<List<CustomList>> fetchAll(List<String> ids)`, `Future<CustomList> create(CustomList list)`, `Future<int?> update(CustomList list)`, `Future<void> delete(String id)`, `Future<void> leave(String id)`, `Future<SharedListPreview?> preview(String token)`, `Future<String> join(String token)`, `SharedListSubscription subscribe(String id, {required void Function(CustomList) onChange, required void Function() onDelete})`.
  - `class SharedListPreview { final String id; final String name; final int hymnsCount; }`
  - `abstract class SharedListSubscription { Future<void> close(); }`
  - `CustomListProvider` intent methods, all `Future<void>`: `addHymn`, `removeHymn`, `archiveHymn`, `restoreHymn`, `removeHymnFromArchive`, `addHymnToArchive`, `moveHymn`, `moveArchivedHymn`, `rename`.

- [ ] **Step 1: Define the gateway**

Create `lib/app/providers/custom_lists/gateway.dart`:

```dart
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
```

- [ ] **Step 2: Write the failing tests**

Create `test/app/providers/custom_lists/sync_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/gateway.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';

Hymn hymn(int id) => Hymn(id, '$id', 'Title $id', 'G', 'S', const []);

/// Records calls and lets each test script the responses it needs.
class FakeGateway implements SharedListGateway {
  /// Server-side state, keyed by list id.
  final Map<String, CustomList> rows = {};

  /// Versions that [update] should reject before accepting anything.
  int rejectUpdates = 0;

  /// When true, [update] throws instead of answering.
  bool failNetwork = false;

  int updateCalls = 0;

  @override
  Future<int?> update(CustomList list) async {
    updateCalls++;
    if (failNetwork) throw Exception('offline');
    if (rejectUpdates > 0) {
      rejectUpdates--;
      return null;
    }
    final stored = rows[list.id]!;
    stored.name = list.name;
    stored.hymnsIds = [...list.hymnsIds];
    stored.archivedHymnsIds = [...list.archivedHymnsIds];
    stored.version = stored.version + 1;
    return stored.version;
  }

  @override
  Future<CustomList?> fetch(String id) async => rows[id]?.copy();

  @override
  Future<List<CustomList>> fetchAll(List<String> ids) async =>
      ids.map((id) => rows[id]).whereType<CustomList>().map((l) => l.copy()).toList();

  @override
  Future<CustomList> create(CustomList list) async {
    final stored = list.copy()
      ..shareToken = 'token-${list.id}'
      ..isOwner = true
      ..version = 1;
    rows[list.id] = stored;
    return stored.copy();
  }

  @override
  Future<void> delete(String id) async => rows.remove(id);

  @override
  Future<void> leave(String id) async => rows.remove(id);

  @override
  Future<SharedListPreview?> preview(String token) async => null;

  @override
  Future<String> join(String token) async => throw UnimplementedError();

  @override
  SharedListSubscription subscribe(String id,
          {required void Function(CustomList) onChange,
          required void Function() onDelete}) =>
      throw UnimplementedError();
}

void main() {
  late SharedPreferences prefs;
  late FakeGateway gateway;
  late CustomListProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    gateway = FakeGateway();
    provider = CustomListProvider(prefs, gateway: gateway);
  });

  /// Creates a list locally and marks it shared, both locally and on the fake
  /// server, without going through the share UI.
  CustomList givenSharedList({List<int> hymnsIds = const []}) {
    final list = CustomList('list-1', 'Pielgrzymka',
        hymnsIds: [...hymnsIds], shareToken: 'token-1', isOwner: true, version: 1);
    provider.save(list);
    gateway.rows['list-1'] = list.copy();
    return list;
  }

  test('a successful push stores the version the server returned', () async {
    final list = givenSharedList(hymnsIds: [1]);

    await provider.addHymn(list, hymn(2));

    expect(gateway.rows['list-1']!.hymnsIds, [1, 2]);
    expect(provider.getList('list-1').version, 2);
    expect(provider.getList('list-1').hymnsIds, [1, 2]);
  });

  test('a version conflict re-applies the intent to fresh state', () async {
    final list = givenSharedList(hymnsIds: [1]);
    // Someone else added hymn 9 and bumped the version.
    gateway.rows['list-1']!
      ..hymnsIds = [1, 9]
      ..version = 5;
    gateway.rejectUpdates = 1;

    await provider.addHymn(list, hymn(2));

    expect(gateway.updateCalls, 2);
    // The other user's hymn survived and ours was added on top of it.
    expect(provider.getList('list-1').hymnsIds, [1, 9, 2]);
  });

  test('a reorder survives a conflict because it is expressed with ids',
      () async {
    final list = givenSharedList(hymnsIds: [1, 2, 3, 4]);
    gateway.rows['list-1']!
      ..hymnsIds = [9, 1, 2, 3, 4]
      ..version = 5;
    gateway.rejectUpdates = 1;

    await provider.moveHymn(list, 4, 2);

    expect(provider.getList('list-1').hymnsIds, [9, 1, 4, 2, 3]);
  });

  test('a network failure rolls the local change back', () async {
    final list = givenSharedList(hymnsIds: [1]);
    gateway.failNetwork = true;

    await expectLater(provider.addHymn(list, hymn(2)), throwsException);

    expect(provider.getList('list-1').hymnsIds, [1]);
  });

  test('pushing to a list the owner deleted removes it locally', () async {
    final list = givenSharedList(hymnsIds: [1]);
    gateway.rejectUpdates = 1;
    gateway.rows.remove('list-1');

    await provider.addHymn(list, hymn(2));

    expect(provider.getLists(), isEmpty);
  });

  test('a private list never touches the gateway', () async {
    provider.createNewList('Prywatna');
    final list = provider.getLists().first;

    await provider.addHymn(list, hymn(1));

    expect(gateway.updateCalls, 0);
    expect(provider.getList(list.id).hymnsIds, [1]);
  });
}
```

- [ ] **Step 3: Run the tests to verify they fail**

Run: `fvm flutter test test/app/providers/custom_lists/sync_test.dart`
Expected: FAIL — `CustomListProvider` has no `gateway` named parameter and no `addHymn` / `moveHymn` methods.

- [ ] **Step 4: Rewrite the provider**

Replace `lib/app/providers/custom_lists/provider.dart` with:

```dart
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
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `fvm flutter test test/app/providers/custom_lists/sync_test.dart`
Expected: all six tests pass.

- [ ] **Step 6: Run the whole suite**

Run: `fvm flutter test`
Expected: `test/app/providers/custom_lists/provider_test.dart` still passes — none of its behaviour changed.

- [ ] **Step 7: Commit**

```bash
fvm flutter analyze --fatal-infos
git add lib/app/providers/custom_lists test/app/providers/custom_lists
git commit -m "feat: push list mutations to the gateway with conflict retry"
```

---

### Task 6: Supabase implementation of the gateway

**Files:**
- Create: `lib/app/providers/custom_lists/supabase_gateway.dart`
- Modify: `lib/main.dart`

**Interfaces:**
- Consumes: Task 2's `supabase` and `ensureSignedIn()`, Task 5's `SharedListGateway`.
- Produces: `class SupabaseSharedListGateway implements SharedListGateway`, registered in `get_it` as `SharedListGateway`.

- [ ] **Step 1: Write the implementation**

Create `lib/app/providers/custom_lists/supabase_gateway.dart`:

```dart
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/gateway.dart';
import 'package:spiewnik_pielgrzyma/infra/supabase.dart';
import 'package:spiewnik_pielgrzyma/models/custom_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String _table = 'shared_lists';

class SupabaseSharedListGateway implements SharedListGateway {
  CustomList _fromRow(Map<String, dynamic> row) {
    final currentUserId = supabase.auth.currentUser?.id;
    return CustomList(
      row['id'] as String,
      row['name'] as String,
      hymnsIds: (row['hymns_ids'] as List).cast<int>(),
      archivedHymnsIds: (row['archived_hymns_ids'] as List).cast<int>(),
      shareToken: row['share_token'] as String?,
      isOwner: row['owner_id'] == currentUserId,
      version: row['version'] as int,
    );
  }

  @override
  Future<CustomList?> fetch(String id) async {
    final rows = await supabase.from(_table).select().eq('id', id);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<List<CustomList>> fetchAll(List<String> ids) async {
    if (ids.isEmpty) return [];
    final rows = await supabase.from(_table).select().inFilter('id', ids);
    return rows.map(_fromRow).toList();
  }

  @override
  Future<CustomList> create(CustomList list) async {
    final userId = await ensureSignedIn();
    final row = await supabase
        .from(_table)
        .insert({
          'id': list.id,
          'owner_id': userId,
          'name': list.name,
          'hymns_ids': list.hymnsIds,
          'archived_hymns_ids': list.archivedHymnsIds,
        })
        .select()
        .single();
    return _fromRow(row);
  }

  @override
  Future<int?> update(CustomList list) async {
    final rows = await supabase
        .from(_table)
        .update({
          'name': list.name,
          'hymns_ids': list.hymnsIds,
          'archived_hymns_ids': list.archivedHymnsIds,
          'version': list.version + 1,
        })
        .eq('id', list.id)
        .eq('version', list.version)
        .select('version');
    if (rows.isEmpty) return null;
    return rows.first['version'] as int;
  }

  @override
  Future<void> delete(String id) async {
    await supabase.from(_table).delete().eq('id', id);
  }

  @override
  Future<void> leave(String id) async {
    final userId = await ensureSignedIn();
    await supabase
        .from('shared_list_members')
        .delete()
        .eq('list_id', id)
        .eq('user_id', userId);
  }

  @override
  Future<SharedListPreview?> preview(String token) async {
    await ensureSignedIn();
    final rows = await supabase
        .rpc('preview_shared_list', params: {'p_token': token}) as List;
    if (rows.isEmpty) return null;
    final row = rows.first as Map<String, dynamic>;
    return SharedListPreview(
      row['id'] as String,
      row['name'] as String,
      row['hymns_count'] as int,
    );
  }

  @override
  Future<String> join(String token) async {
    await ensureSignedIn();
    final id =
        await supabase.rpc('join_shared_list', params: {'p_token': token});
    return id as String;
  }

  @override
  SharedListSubscription subscribe(
    String id, {
    required void Function(CustomList) onChange,
    required void Function() onDelete,
  }) {
    final channel = supabase.channel('shared_list:$id')
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: _table,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: id,
        ),
        callback: (payload) => onChange(_fromRow(payload.newRecord)),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: _table,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: id,
        ),
        callback: (_) => onDelete(),
      );
    channel.subscribe();
    return _ChannelSubscription(channel);
  }
}

class _ChannelSubscription implements SharedListSubscription {
  final RealtimeChannel _channel;

  _ChannelSubscription(this._channel);

  @override
  Future<void> close() => supabase.removeChannel(_channel);
}
```

- [ ] **Step 2: Register it and wire it into the provider**

In `lib/main.dart`, inside `setup()`, add before the `CustomListProvider` registration:

```dart
  getIt.registerSingleton<SharedListGateway>(SupabaseSharedListGateway());
```

Then change the `CustomListProvider` registration to pass it:

```dart
  getIt.registerSingletonWithDependencies<CustomListProvider>(
      () => CustomListProvider(getIt.get<SharedPreferences>(),
          gateway: getIt.get<SharedListGateway>()),
      dependsOn: [SharedPreferences]);
```

Add the imports:

```dart
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/gateway.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/supabase_gateway.dart';
```

- [ ] **Step 3: Verify analysis and tests**

Run: `fvm flutter analyze --fatal-infos && fvm flutter test`
Expected: `No issues found!` and all tests pass. The unit tests keep using `FakeGateway`, so nothing hits the network.

- [ ] **Step 4: Commit**

```bash
git add lib/app/providers/custom_lists/supabase_gateway.dart lib/main.dart
git commit -m "feat: implement the shared list gateway against Supabase"
```

---

### Task 7: Route widget callbacks through the provider intents

**Files:**
- Create: `lib/app/widgets/utils/list_action.dart`
- Modify: `lib/app/widgets/custom_lists/hymn_tile.dart`, `archived_hymn_tile.dart`, `custom_list.dart`, `search_hymn.dart`, `add_hymn_to_custom_list_dialog.dart`, `custom_list_page.dart`

**Interfaces:**
- Consumes: Task 5's intent methods.
- Produces: `Future<void> runListAction(BuildContext context, Future<void> Function() action)` — awaits an intent and shows a Polish snackbar if it throws.

- [ ] **Step 1: Write the shared helper**

Create `lib/app/widgets/utils/list_action.dart`:

```dart
import 'package:flutter/material.dart';

/// Runs a list mutation and reports failure to the user.
///
/// The mutation has already been applied locally by the time this returns, so
/// the UI is responsive; a throw means the change was rolled back and the user
/// needs to know.
Future<void> runListAction(
    BuildContext context, Future<void> Function() action) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Nie udało się zapisać zmiany. Sprawdź połączenie.'),
      ),
    );
  }
}
```

- [ ] **Step 2: Replace the call sites**

Every place that mutates a list in place and then calls `provider.save(list)` becomes a single intent call. The pattern:

```dart
// before
list.addHymn(hymn);
provider.save(list);

// after
runListAction(context, () => provider.addHymn(list, hymn));
```

Apply it to, in each file, every `list.<method>(hymn); provider.save(list);` pair:

- `hymn_tile.dart` — `archiveHymn`, `removeHymn`
- `archived_hymn_tile.dart` — `restoreHymn`, `removeHymnFromArchive`
- `search_hymn.dart` and `add_hymn_to_custom_list_dialog.dart` — `addHymn`
- `custom_list_page.dart` — the `onSubmitted` handler becomes
  `runListAction(context, () => provider.rename(list, value))`

In `custom_list.dart`, the two `onReorder` handlers keep the index-to-id conversion added in Task 4 but call the provider instead of mutating:

```dart
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) newIndex -= 1;
        final hymnId = list.hymnsIds[oldIndex];
        final rest = list.hymnsIds.where((id) => id != hymnId).toList();
        final beforeHymnId = newIndex < rest.length ? rest[newIndex] : null;
        runListAction(context, () => provider.moveHymn(list, hymnId, beforeHymnId));
      },
```

and the archive one with `list.archivedHymnsIds` and `provider.moveArchivedHymn`.

- [ ] **Step 3: Verify analysis**

Run: `fvm flutter analyze --fatal-infos`
Expected: `No issues found!`. If it complains about `use_build_context_synchronously`, the `ScaffoldMessenger.of(context)` call in `runListAction` must stay *before* the `await`, which it does.

- [ ] **Step 4: Verify by hand that private lists still behave**

Run: `fvm flutter run`
Add, archive, restore, remove and reorder hymns in a private list. Everything must work exactly as before, with no snackbars.

- [ ] **Step 5: Commit**

```bash
fvm flutter test
git add lib/app/widgets
git commit -m "refactor: express list edits as provider intents"
```

---

### Task 8: Share a list

**Files:**
- Modify: `pubspec.yaml`, `lib/app/providers/custom_lists/provider.dart`, `lib/app/widgets/custom_lists/custom_list_page.dart`

**Interfaces:**
- Consumes: Task 6's gateway.
- Produces: `Future<CustomList> shareList(CustomList list)` on `CustomListProvider` — uploads a private list and returns it with its token; `String shareUrl(CustomList list)`.

- [ ] **Step 1: Add the dependency**

```bash
fvm flutter pub add share_plus
```

Expected: `pubspec.yaml` gains `share_plus: ^13.3.0` or newer.

- [ ] **Step 2: Add the provider method**

In `lib/app/providers/custom_lists/provider.dart`, add:

```dart
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
```

- [ ] **Step 3: Add the share button**

In `lib/app/widgets/custom_lists/custom_list_page.dart`, add to the `AppBar`:

```dart
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Udostępnij listę',
            onPressed: () => _share(context, list),
          ),
        ],
```

and the method on the same class:

```dart
  static const String _shareBase =
      'https://spiewnikpielgrzyma.norbertchmiel.pl/dolacz.html';

  Future<void> _share(BuildContext context, CustomList list) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final shared = await provider.shareList(list);
      await SharePlus.instance.share(ShareParams(
        text: 'Śpiewnik Pielgrzyma — lista „${shared.name}”:\n'
            '$_shareBase?t=${shared.shareToken}',
      ));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Nie udało się udostępnić listy. Sprawdź połączenie.'),
        ),
      );
    }
  }
```

Add the imports:

```dart
import 'package:share_plus/share_plus.dart';
```

- [ ] **Step 4: Verify end to end**

Run: `fvm flutter run`
Open a list, tap share. Expected: the system share sheet opens with a link containing a UUID token. In the dashboard, Authentication → Users now shows one anonymous user, and Table Editor → `shared_lists` shows one row with `owner_id` matching it.

- [ ] **Step 5: Verify that the token is not the list id**

In the dashboard, confirm `share_token` differs from `id` on that row.

- [ ] **Step 6: Commit**

```bash
fvm flutter analyze --fatal-infos && fvm flutter test
git add pubspec.yaml pubspec.lock lib/app/providers/custom_lists/provider.dart lib/app/widgets/custom_lists/custom_list_page.dart
git commit -m "feat: share a custom list through the system share sheet"
```

---

### Task 9: Share marker, leaving and deleting

**Files:**
- Modify: `lib/app/providers/custom_lists/provider.dart`, `lib/app/widgets/custom_lists/list_tile.dart`, `lib/app/widgets/custom_lists/custom_list_page.dart`

**Interfaces:**
- Consumes: Task 6's gateway, Task 8's `shareList`.
- Produces: `Future<void> deleteSharedList(CustomList list)` and `Future<void> leaveSharedList(CustomList list)` on `CustomListProvider`.

- [ ] **Step 1: Add the provider methods**

```dart
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
```

- [ ] **Step 2: Mark shared lists in the list of lists**

In `lib/app/widgets/custom_lists/list_tile.dart`, add to the inner `ListTile`:

```dart
        trailing: list.isShared
            ? const Icon(Icons.share, size: 18)
            : null,
```

- [ ] **Step 3: Mark the shared list on its own page**

In `lib/app/widgets/custom_lists/custom_list_page.dart`, replace the whole `AppBar` with:

```dart
      appBar: AppBar(
        title: Row(children: [
          if (list.isShared)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.share, size: 18),
            ),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: list.name),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Kliknij aby nazwać listę",
                hintStyle: Theme.of(context).textTheme.titleLarge,
              ),
              onSubmitted: (value) =>
                  runListAction(context, () => provider.rename(list, value)),
            ),
          ),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Udostępnij listę',
            onPressed: () => _share(context, list),
          ),
        ],
      ),
```

- [ ] **Step 4: Replace the swipe behaviour for shared lists**

In `lib/app/widgets/custom_lists/list_tile.dart`, the `Dismissible` currently archives unconditionally. Shared lists get a confirmation instead, and are never archived — archiving plus sharing would be a third state to synchronize.

Change `Dismissible` to use `confirmDismiss` and branch on the role:

```dart
      confirmDismiss: (direction) async {
        if (!list.isShared) return true;
        return await _confirmSharedRemoval(context, list) ?? false;
      },
      onDismissed: (direction) => _archiveList(context, list),
```

and add:

```dart
  Future<bool?> _confirmSharedRemoval(BuildContext context, CustomList list) {
    final provider = GetIt.I<CustomListProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final message = list.isOwner
        ? 'Ta lista jest współdzielona, zostanie usunięta u wszystkich, '
            'którzy z niej korzystają. Kontynuować?'
        : 'Czy opuścić listę „${list.name}”? Zniknie tylko u Ciebie.';

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Nie'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context, true);
              try {
                if (list.isOwner) {
                  await provider.deleteSharedList(list);
                } else {
                  await provider.leaveSharedList(list);
                }
              } catch (_) {
                messenger.showSnackBar(const SnackBar(
                  content: Text('Nie udało się. Sprawdź połączenie.'),
                ));
              }
            },
            child: const Text('Tak'),
          ),
        ],
      ),
    );
  }
```

Because the removal already happened inside the dialog, guard `_archiveList` so it only runs for private lists:

```dart
  Future<void> _archiveList(BuildContext context, CustomList list) async {
    if (list.isShared) return;
    // ... the existing body unchanged
  }
```

- [ ] **Step 5: Verify by hand**

Run: `fvm flutter run`
- A private list still swipes to archive with the Undo snackbar.
- A shared list you own shows the owner dialog; confirming removes the row from `shared_lists` in the dashboard.
- Reject the dialog and the list stays put.

- [ ] **Step 6: Commit**

```bash
fvm flutter analyze --fatal-infos && fvm flutter test
git add lib/app/providers/custom_lists/provider.dart lib/app/widgets/custom_lists
git commit -m "feat: mark shared lists and confirm leaving or deleting them"
```

---

### Task 10: Live updates, pull refresh and the offline lock

**Files:**
- Modify: `lib/app/providers/custom_lists/provider.dart`, `lib/app/widgets/custom_lists/custom_list.dart`, `lib/app/widgets/custom_lists/custom_list_page.dart`

**Interfaces:**
- Consumes: Task 6's `subscribe` and `fetchAll`.
- Produces: `Future<void> refreshSharedLists()` on `CustomListProvider`.

- [ ] **Step 1: Add the pull method**

In `lib/app/providers/custom_lists/provider.dart`:

```dart
  /// Refreshes every shared list from the server. Lists that came back missing
  /// were deleted by their owner and are dropped locally.
  Future<void> refreshSharedLists() async {
    final gateway = this.gateway;
    if (gateway == null) return;

    final shared = getLists().where((l) => l.isShared).toList();
    if (shared.isEmpty) return;

    final remote = await gateway.fetchAll(shared.map((l) => l.id).toList());
    final remoteById = {for (final l in remote) l.id: l};

    for (final local in shared) {
      final fresh = remoteById[local.id];
      if (fresh == null) {
        deleteCustomList(local, prefs);
      } else {
        fresh.shareToken = local.shareToken;
        saveCustomList(fresh, prefs);
      }
    }
    notifyListeners();
  }
```

- [ ] **Step 2: Subscribe while a shared list is open**

In `lib/app/widgets/custom_lists/custom_list.dart`, extend `_CustomListWidgetState`:

```dart
  SharedListSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();

    final provider = GetIt.I<CustomListProvider>();
    final list = provider.getList(widget.listId);
    if (!list.isShared) return;

    unawaited(provider.refreshSharedLists());
    _subscription = GetIt.I<SharedListGateway>().subscribe(
      widget.listId,
      onChange: (remote) {
        remote.shareToken = list.shareToken;
        provider.applyRemote(remote);
      },
      onDelete: () {
        provider.deleteList(list);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lista została usunięta przez właściciela'),
        ));
        context.pop();
      },
    );
  }

  @override
  void dispose() {
    unawaited(_subscription?.close());
    scrollController.dispose();
    super.dispose();
  }
```

Add the imports: `dart:async` for `unawaited`, `package:go_router/go_router.dart`, and the gateway.

- [ ] **Step 3: Refresh when the app returns from the background**

In the same state class, mix in `WidgetsBindingObserver`:

```dart
class _CustomListWidgetState extends State<CustomListWidget>
    with WidgetsBindingObserver {
```

register in `initState` with `WidgetsBinding.instance.addObserver(this)`, remove it in `dispose` with `WidgetsBinding.instance.removeObserver(this)`, and add:

```dart
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(GetIt.I<CustomListProvider>().refreshSharedLists());
    }
  }
```

- [ ] **Step 4: Lock editing when offline**

A shared list stays readable offline but must not be editable. `connectivity_plus` is already a
dependency; a `StreamBuilder` on `onConnectivityChanged` reacts the moment the connection drops,
which a one-shot `checkConnectivity()` would not.

In `lib/app/widgets/custom_lists/custom_list_page.dart`, replace the whole `build` method:

```dart
  @override
  Widget build(BuildContext context) {
    final CustomList list = provider.getList(listId);

    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      initialData: const <ConnectivityResult>[],
      builder: (context, snapshot) {
        final offline = snapshot.data!.contains(ConnectivityResult.none);
        // Private lists are local, so they stay editable with no connection.
        final locked = list.isShared && offline;

        return Scaffold(
          appBar: AppBar(
            // ... unchanged from Task 9, Step 3
          ),
          body: Column(children: [
            if (locked)
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.secondaryContainer,
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Brak połączenia — listy współdzielonej nie można teraz edytować',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomListWidget(listId: list.id, locked: locked),
              ),
            ),
          ]),
          floatingActionButton: locked
              ? null
              : FloatingActionButton(
                  onPressed: () => showSearch(
                      context: context,
                      delegate: SearchForHymnToAddToCustomList(
                          provider: hymnsProvider,
                          hymns: hymnsProvider.getAll(),
                          listId: listId)),
                  tooltip: "Dodaj pieśń do listy",
                  child: const Icon(Icons.add),
                ),
        );
      },
    );
  }
```

Add the import `package:connectivity_plus/connectivity_plus.dart`.

- [ ] **Step 5: Disable the drag handles when locked**

In `lib/app/widgets/custom_lists/custom_list.dart`, add the flag to the widget:

```dart
class CustomListWidget extends WatchingStatefulWidget {
  final String listId;
  final bool locked;

  const CustomListWidget({super.key, required this.listId, this.locked = false});
```

and in both `ReorderableListView.builder` calls, replace `buildDefaultDragHandles: true` with:

```dart
      buildDefaultDragHandles: !widget.locked,
```

- [ ] **Step 6: Verify with two clients**

Run the app on a device and `fvm flutter run -d chrome` in parallel, both joined to the same list (use Task 12's join flow, or insert the membership row by hand in the dashboard for now).
Expected: adding a hymn on one side appears on the other within about two seconds while both have the list open.

- [ ] **Step 7: Verify the offline lock**

Turn on airplane mode with a shared list open.
Expected: the list still renders, the banner appears, the add button is gone and the drag handles
disappear. A private list opened in airplane mode stays fully editable.

- [ ] **Step 8: Commit**

```bash
fvm flutter analyze --fatal-infos && fvm flutter test
git add lib/app/providers/custom_lists/provider.dart lib/app/widgets/custom_lists
git commit -m "feat: sync shared lists live and block editing offline"
```

---

### Task 11: The join screen

**Files:**
- Create: `lib/app/widgets/custom_lists/join_page.dart`
- Modify: `lib/router.dart`

**Interfaces:**
- Consumes: Task 6's `preview` and `join`.
- Produces: route `/dolacz?t=<token>` rendering `JoinListPage`.

- [ ] **Step 1: Write the page**

Create `lib/app/widgets/custom_lists/join_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/gateway.dart';
import 'package:spiewnik_pielgrzyma/app/providers/custom_lists/provider.dart';

/// Landing screen for an invite link. Previews the list, asks, then joins.
class JoinListPage extends StatefulWidget {
  final String token;

  const JoinListPage({super.key, required this.token});

  @override
  State<JoinListPage> createState() => _JoinListPageState();
}

class _JoinListPageState extends State<JoinListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final gateway = GetIt.I<SharedListGateway>();
    final provider = GetIt.I<CustomListProvider>();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    SharedListPreview? preview;
    try {
      preview = await gateway.preview(widget.token);
    } catch (_) {
      preview = null;
    }

    if (!mounted) return;

    if (preview == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Ta lista już nie istnieje')),
      );
      router.go('/custom-lists');
      return;
    }

    // Already have it? Skip the dialog and just open it.
    final known = provider.getLists().where((l) => l.id == preview.id);
    if (known.isNotEmpty) {
      router.go('/custom-lists/${preview.id}');
      return;
    }

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Text(
            'Czy chcesz dodać udostępnioną ci listę „${preview!.name}”?\n'
            'Pieśni: ${preview.hymnsCount}'),
        actions: [
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Nie'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tak'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (accepted != true) {
      router.go('/custom-lists');
      return;
    }

    try {
      final id = await gateway.join(widget.token);
      final joined = await gateway.fetch(id);
      if (joined == null) throw Exception('list_not_found');
      joined.shareToken = widget.token;
      provider.applyRemote(joined);
      if (!mounted) return;
      router.go('/custom-lists/$id');
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Nie udało się dodać listy')),
      );
      router.go('/custom-lists');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
```

- [ ] **Step 2: Add the route**

In `lib/router.dart`, add a top-level route next to `/custom-lists`:

```dart
  GoRoute(
      path: '/dolacz',
      builder: (BuildContext context, GoRouterState state) =>
          JoinListPage(token: state.uri.queryParameters['t'] ?? '')),
```

The manifest sets `pathPrefix="/dolacz"` in Task 12, and `dolacz.html` redirects the web build to `/#/dolacz?t=…`. Both land on this route.

Add the import.

- [ ] **Step 3: Verify with a hand-made link**

Run: `fvm flutter run -d chrome`, then open
`http://localhost:<port>/#/dolacz?t=<share_token from the dashboard>` in a second browser profile.
Expected: the dialog appears with the list name and hymn count; "Tak" adds the list and navigates to it; a row appears in `shared_list_members`.

- [ ] **Step 4: Verify the rejection and unknown-token paths**

Repeat with "Nie" — expect a return to `/custom-lists` with no membership row. Then try `?t=00000000-0000-0000-0000-000000000000` — expect the "Ta lista już nie istnieje" snackbar.

- [ ] **Step 5: Commit**

```bash
fvm flutter analyze --fatal-infos && fvm flutter test
git add lib/app/widgets/custom_lists/join_page.dart lib/router.dart
git commit -m "feat: add the invite link landing screen"
```

---

### Task 12: Deep link plumbing

**Files:**
- Create: `web/dolacz.html`, `web/.well-known/assetlinks.json`
- Modify: `android/app/src/main/AndroidManifest.xml`, `.github/workflows/release.yml`

**Interfaces:**
- Consumes: Task 11's `/dolacz` route.
- Produces: working App Links on Android and a working browser fallback.

**Order matters here.** The manifest change must ship before `assetlinks.json` reaches the server. The current filter claims the whole host, so publishing the statement first would make the app start intercepting every link to the domain, including the privacy policy page, the web build and the PDFs under `/note_files/`.

- [ ] **Step 1: Narrow the intent filter**

In `android/app/src/main/AndroidManifest.xml`, replace the two `<data>` elements inside the `autoVerify` filter:

```xml
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="https"
                      android:host="spiewnikpielgrzyma.norbertchmiel.pl"
                      android:pathPrefix="/dolacz" />
            </intent-filter>
```

`http` is dropped deliberately — App Links verification requires HTTPS, and an `http` entry only invites downgrade.

- [ ] **Step 2: Write the landing page**

Create `web/dolacz.html`:

```html
<!DOCTYPE html>
<html lang="pl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Śpiewnik Pielgrzyma — udostępniona lista</title>
</head>
<body>
  <p>Otwieram udostępnioną listę…</p>
  <script>
    // Reached only when the app did not intercept the link: either it is not
    // installed, or this is a desktop browser.
    var token = new URLSearchParams(location.search).get('t') || '';
    var isAndroid = /Android/i.test(navigator.userAgent);
    location.replace(isAndroid
      ? 'https://play.google.com/store/apps/details?id=pl.norbertchmiel.spiewnik_pielgrzyma'
      : '/#/dolacz?t=' + encodeURIComponent(token));
  </script>
  <noscript>
    <p>Włącz JavaScript albo
      <a href="https://play.google.com/store/apps/details?id=pl.norbertchmiel.spiewnik_pielgrzyma">
        zainstaluj aplikację</a>.</p>
  </noscript>
</body>
</html>
```

- [ ] **Step 3: Write the Digital Asset Links statement**

Create `web/.well-known/assetlinks.json`:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "pl.norbertchmiel.spiewnik_pielgrzyma",
      "sha256_cert_fingerprints": [
        "90:C4:FF:90:97:1C:05:1D:80:7B:BC:E4:46:7A:1B:7E:56:DD:45:6D:7C:1B:84:A7:75:71:16:A1:4E:D8:46:90"
      ]
    }
  }
]
```

The fingerprint is the Play **app signing** key, not the upload key. The debug keystore is deliberately absent — including it would let anyone holding that keystore claim the domain's links.

- [ ] **Step 4: Fix the web deploy so dotfiles ship**

In `.github/workflows/release.yml`, the `Deploy web` step uses a glob that skips `.well-known`. Replace:

```yaml
        run: scp -i ~/.ssh/deploy_key -r build/web/. ${{ secrets.WEB_HOST_USER }}@${{ secrets.WEB_HOST }}:${{ secrets.WEB_HOST_PATH }}
```

- [ ] **Step 5: Confirm the build actually carries the files**

Run: `fvm flutter build web --release && ls -a build/web build/web/.well-known`
Expected: `dolacz.html` and `.well-known/assetlinks.json` are both present.

- [ ] **Step 6: Release and verify the statement is served correctly**

After the release workflow has deployed:

```bash
curl -sI https://spiewnikpielgrzyma.norbertchmiel.pl/.well-known/assetlinks.json
```

Expected: `HTTP/2 200` and `content-type: application/json`, with no redirect. A `text/html` content type is the usual silent failure — fix it in the web server config if it appears.

Then confirm Google can read it:

```bash
curl -s "https://digitalassetlinks.googleapis.com/v1/statements:list?\
source.web.site=https://spiewnikpielgrzyma.norbertchmiel.pl&\
relation=delegate_permission/common.handle_all_urls"
```

Expected: a statement listing the package name, and `"maxAge"` present with no errors.

- [ ] **Step 7: Verify App Links on a device**

Install the build from the Play internal track, then:

```bash
adb shell pm verify-app-links --re-verify pl.norbertchmiel.spiewnik_pielgrzyma
adb shell pm get-app-links pl.norbertchmiel.spiewnik_pielgrzyma
```

Expected: `spiewnikpielgrzyma.norbertchmiel.pl: verified`. If it says `legacy_failure` or `none`, the statement is not being served correctly — go back to Step 6.

For a locally built debug APK, verification will not pass because that fingerprint is not in the statement. Test it with:

```bash
adb shell pm set-app-links-user-selection --package pl.norbertchmiel.spiewnik_pielgrzyma \
    --user cur true spiewnikpielgrzyma.norbertchmiel.pl
```

- [ ] **Step 8: Walk the whole scenario from the issue**

On two devices:
1. user1 creates a list and adds hymns
2. user1 taps share and sends the link over a messenger
3. user2 taps the link → the app opens on the dialog
4. user2 taps "Nie" → lands on the custom lists tab, nothing added
5. user2 taps the link again, taps "Tak" → the list is added and opens
6. both see the share marker on the list and in the list of lists
7. user1 adds a hymn → it appears for user2 within about two seconds
8. user2 deletes the list → it disappears only for user2
9. user1 deletes the list → the owner dialog appears, and it disappears for everyone

Then, on a phone without the app installed, tap the link: expect Google Play. On a desktop browser: expect the web build's join dialog.

- [ ] **Step 9: Commit**

```bash
fvm flutter analyze --fatal-infos && fvm flutter test
git add web android/app/src/main/AndroidManifest.xml .github/workflows/release.yml
git commit -m "feat: verify App Links and add the invite link landing page"
```

---

## Verification Against the Spec's Success Criteria

Run through these once Task 12 is done. They are the spec's list, with the task that satisfies each.

| # | Criterion | Covered by |
|---|---|---|
| 1 | `analyze --fatal-infos` and `test` pass | every task's final step |
| 2 | Issue scenario 1→5b works on two devices | Task 12, Step 8 |
| 3 | Change propagates in under ~2s with the list open | Task 10, Step 6 |
| 4 | `pm get-app-links` reports `verified` | Task 12, Step 7 |
| 5 | Android without the app → Play; desktop → web build | Task 12, Step 8 |
| 6 | Airplane mode: readable, not editable | Task 10, Step 7 |
| 7 | Owner deletion propagates | Task 12, Step 8 |
| 8 | Pre-existing private lists unchanged | Task 7, Step 4 |
| 9 | Security Advisor clean; raw key gets `[]` and 401 | Task 1, Steps 6-7 |
| 10 | A non-participant gets `[]` and cannot PATCH `owner_id` | see below |

Criterion 10 needs one manual check that no task performs, because it needs two accounts. With two anonymous JWTs (grab them from `supabase.auth.currentSession!.accessToken` in a debug build of each client):

```bash
# user B, not a participant of user A's list
curl -s "$SUPABASE_URL/rest/v1/shared_lists?select=*&id=eq.<user A's list id>" \
     -H "apikey: $KEY" -H "Authorization: Bearer $JWT_B"
# expected: []

curl -s -o /dev/null -w '%{http_code}\n' -X PATCH \
     "$SUPABASE_URL/rest/v1/shared_lists?id=eq.<list id>" \
     -H "apikey: $KEY" -H "Authorization: Bearer $JWT_B" \
     -H "Content-Type: application/json" -d '{"owner_id":"<user B id>"}'
# expected: 403 — owner_id is not in the column-level UPDATE grant
```

Do this after Task 12 and record the result.
