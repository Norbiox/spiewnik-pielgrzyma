# Shared Custom Lists

**Issue:** #31
**Date:** 2026-08-31

## Summary

Two or more users can collaborate on a single custom list. The owner shares a link; recipients
open it, confirm a dialog, and the list appears in their app. Edits by any participant propagate
to the others while they have the list open. The owner deleting the list removes it for everyone;
a member deleting it only leaves the list.

Until now the app has had no backend, no accounts and no social features. This is the first
feature that introduces all three.

## Design Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Identity | Supabase Anonymous Sign-In | Real `user_id` and JWT without an onboarding flow; `linkIdentity()` later upgrades the same account to email/OAuth without data migration |
| Sync | Realtime WebSocket only while a shared list is open | Instant where the user is looking, zero battery cost otherwise — the app is used outdoors on weak networks |
| Offline | Read-only | Shared lists stay readable offline (singing is the point), editing is disabled with a message. Removes an entire class of merge problems |
| Backend | Supabase | Postgres + Realtime + Anonymous Auth + RLS out of the box; pure-Dart SDK; project already provisioned |
| Invite link | Permanent token, no expiry, no revocation | Matches the actual scenario — a pilgrimage group drops a link into a group chat |
| Platforms | Android + web | Android opens the app via App Links; without the app, Android goes to Google Play and desktop opens the web build |

### Backend alternatives considered

- **Cloudflare Durable Objects + D1** — runs on infrastructure the project already uses (the
  search worker), one Durable Object per list is a natural fit, and nothing ever pauses. Rejected
  because anonymous identity and authorization would have to be hand-written, and a future move to
  real accounts would mean building an auth system from scratch.
- **Firebase Firestore** — realtime and anonymous auth out of the box, no pausing. Rejected
  because of APK size and per-document-read billing; its offline cache is redundant since the app
  keeps its own cache in `SharedPreferences`.

## Architecture

```
Widget  ──intent──▶  CustomListProvider  ──▶  SharedPreferences (cache, source of truth for rendering)
                            │
                            └──▶ SharedListGateway ──▶ Supabase (REST + Realtime)
```

Rendering always reads from the local cache. `CustomListProvider.getLists()` stays synchronous, so
no existing view needs a `FutureBuilder`. The network is a side channel: after a successful write
or a realtime event it updates the cache and calls `notifyListeners()`.

`SharedListGateway` is an abstract class so tests can substitute a fake. No new dev dependency.

## Supabase Schema

```sql
create table shared_lists (
  id                  uuid primary key,              -- client-supplied, same UUID as the local list
  share_token         uuid not null unique default gen_random_uuid(),
  owner_id            uuid not null references auth.users(id) on delete cascade,
  name                text not null,
  hymns_ids           int[] not null default '{}',
  archived_hymns_ids  int[] not null default '{}',
  version             bigint not null default 1
);

create table shared_list_members (
  list_id  uuid references shared_lists(id) on delete cascade,
  user_id  uuid references auth.users(id)   on delete cascade,
  primary key (list_id, user_id)
);
```

`id` is supplied by the client and is the same UUID the list already uses locally. Because of that,
the `/custom-lists/:id` route, the `SharedPreferences` keys and the whole existing UI layer are
untouched. `share_token` is deliberately separate from `id` so that a list identifier is not also
an access key.

### Row Level Security

| Table | Operation | Allowed to |
|---|---|---|
| `shared_lists` | `select`, `update` | owner or member |
| `shared_lists` | `delete` | owner only |
| `shared_lists` | `insert` | `owner_id = auth.uid()` |
| `shared_list_members` | `delete` | own row only (= "leave list") |

Membership is checked with `exists (select 1 from shared_list_members where list_id = id and user_id = auth.uid())`.

### Joining by token

Joining is a chicken-and-egg problem: reading the list requires membership, and becoming a member
requires knowing the list. Two `security definer` functions are the only place that bypasses RLS:

- `preview_shared_list(p_token uuid) returns (id uuid, name text, hymns_count int)` — feeds the
  confirmation dialog, `stable`, read-only
- `join_shared_list(p_token uuid) returns uuid` — inserts the membership row with
  `on conflict do nothing`, returns the list id, raises when the token is unknown

Both are granted to `authenticated` and revoked from `anon`.

### Schema management

The schema lives in `supabase/migrations/` under version control, created with
`supabase migration new` and applied with `supabase db push` against the single linked project.
Supabase's own branching feature is not used: it is unavailable on the Free plan and costs about
$0.32 per branch per day on Pro, which buys nothing at the scale of two tables, four policies and
two functions. Versioned migrations give the part that actually matters.

### Abuse prevention on anonymous sign-in

Supabase strongly recommends invisible CAPTCHA or Cloudflare Turnstile for anonymous sign-ins. This
design deliberately ships without it, for now:

- sign-in fires only on the first share or join, never at app start, so the exposed surface is a
  handful of calls per day rather than a public registration endpoint
- the default IP rate limit of 30 requests per hour already applies and can be lowered under
  Authentication → Rate Limits
- CAPTCHA would land at the single highest-friction moment — a user who just tapped a friend's
  invite link — and needs a webview on Flutter

`signInAnonymously(captchaToken: ...)` accepts a token, so adding Turnstile later is a config change
plus one widget, not a rework. Revisit if Auth Logs show abuse.

### Cleaning up dormant anonymous users

Anonymous accounts are never removed automatically. The cleanup query from the Supabase docs
(`delete from auth.users where is_anonymous is true and created_at < now() - interval '30 days'`)
**must not be used as written**: `owner_id` cascades, so it would delete the shared lists of every
owner whose account is older than 30 days — precisely the lists that have been working longest.
The safe form skips users who still own or belong to a list:

```sql
delete from auth.users u
where u.is_anonymous
  and u.created_at < now() - interval '30 days'
  and not exists (select 1 from public.shared_lists        where owner_id = u.id)
  and not exists (select 1 from public.shared_list_members where user_id  = u.id);
```

## Local Storage

`CustomList` gains three fields: `String? shareToken`, `bool isOwner`, `int version`, plus
`bool get isShared => shareToken != null`. A `null` token means "private list" — nothing else in
the app needs to know more.

Three new keys in `db.dart`, alongside the existing ones:

- `sharedList:token:{id}`
- `sharedList:owner:{id}`
- `sharedList:version:{id}`

No migration is required. A missing token key means a private list, so every list created before
this feature keeps working untouched.

## Mutations and Conflict Resolution

Today widgets do `list.addHymn(h); provider.save(list);` — mutate in place, then write the whole
object. That cannot survive a retry after a conflict, because the *intent* is lost.

The provider gains intent methods and widgets call one line instead of two:

```dart
provider.addHymn(list, hymn);
provider.archiveHymn(list, hymn);
provider.moveHymn(list, hymnId, beforeHymnId);   // ids, not indices
provider.rename(list, name);
```

Each intent: apply locally, `notifyListeners()` so the UI reacts immediately, then — if the list is
shared — push it.

```sql
update shared_lists set ..., version = version + 1
where id = ? and version = ?
```

Zero rows updated means someone else got there first. The client refetches the current state,
**re-applies the intent rather than the result**, and retries, up to three attempts. A network
error rolls the local change back and shows a "could not save" snackbar.

`moveHymn` takes `beforeHymnId` instead of an index precisely so that the retry is meaningful: after
someone else's change an index points at a different hymn, an id does not.

Call sites to update: `hymn_tile.dart`, `archived_hymn_tile.dart`, `custom_list.dart` (both
`onReorder` handlers), `search_hymn.dart`, `add_hymn_to_custom_list_dialog.dart`,
`custom_list_page.dart` (rename).

### Why one row per list

A row per hymn with fractional indexing would merge concurrent edits without retries, but it is
roughly three times the code. With editing restricted to online-only, the conflict window is
seconds wide. Not worth it.

## Realtime and Pull

The subscription lives in `_CustomListWidgetState`: `initState` opens it, `dispose` closes it. The
filter is `id=eq.<uuid>`, and only shared lists subscribe.

- `UPDATE` → write to the cache, notify
- `DELETE` → remove locally, pop the page, snackbar "the owner deleted this list"

Plain pull (no WebSocket) happens at three moments: app start, return from background
(`AppLifecycleState.resumed`), and entering the custom lists tab. All shared lists refresh in a
single `select ... in (...)`.

## Offline

`connectivity_plus` is already in `pubspec.yaml`. When offline, editing affordances on a shared
list are disabled and a banner explains why. The list itself stays fully readable from the cache.

## Deletion and Leaving

Swiping a shared list does **not** archive it — archiving plus sharing would be a third state with
its own synchronization, which nobody asked for. Instead the swipe opens a role-dependent dialog:

- member → "Czy opuścić listę *X*? Zniknie tylko u Ciebie." → deletes their own membership row
- owner → "Ta lista jest współdzielona, zostanie usunięta u wszystkich, którzy z niej korzystają.
  Kontynuować?" → deletes the row, the cascade removes members

Private lists keep the current swipe-to-archive behaviour unchanged.

## Sharing and Deep Links

An `Icons.share` button in the `CustomListPage` app bar. The first tap on a private list signs in
anonymously, inserts the row, gets a token and opens the native share sheet (`share_plus`, a new
dependency). The system sheet already contains "Copy" and every messenger, so a separate copy
button is unnecessary.

Link format: `https://spiewnikpielgrzyma.norbertchmiel.pl/dolacz.html?t=<token>`

| Situation | Result |
|---|---|
| Android, app installed | App Link opens the app, `go_router` handles `/dolacz?t=` |
| Android, no app | `dolacz.html` detects Android and redirects to Google Play |
| Desktop | `dolacz.html` redirects to the web build |

`dolacz.html` is a static file in `web/`, about 20 lines, and loads instantly instead of waiting for
the multi-megabyte Flutter bundle. Because the path is a real file on the server, **no SPA rewrite
configuration is needed** — the existing `scp` deploy is enough. Flutter web uses the default hash
URL strategy, so the web build's own route is `/#/dolacz?t=<token>`.

### Join screen

Route `/dolacz?t=<token>`. Calls `preview_shared_list`, shows "Czy chcesz dodać udostępnioną ci
listę *X*?" with Tak/Nie. "Tak" calls `join_shared_list`, saves locally and navigates to
`/custom-lists/<id>`. "Nie" navigates to `/custom-lists`. If the user is already a member or is the
owner, the dialog is skipped. An unknown token shows "Ta lista już nie istnieje".

An `Icons.share` marker appears as `trailing` in `CustomListTileWidget` and in the
`CustomListPage` app bar.

## Infrastructure Fixes Required

1. **`android/app/src/main/AndroidManifest.xml`** — the current intent filter claims the *entire*
   host, including `/note_files/*.pdf`. Narrow it to `android:pathPrefix="/dolacz"`.
2. **`web/.well-known/assetlinks.json`** — does not exist, so `autoVerify` fails and App Links do
   not work at all on Android 12+. Needs the SHA-256 fingerprint of the Play App Signing key.
3. **`.github/workflows/release.yml`** — `scp -r build/web/*` skips dotfiles, so `.well-known/`
   would never reach the server. Change to `build/web/.` or add a second `scp`.
4. **Secrets** — `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` in `.env`, `.env.example`, and both
   the Android and web jobs of the release workflow. Supabase has replaced the legacy `anon` JWT
   with a publishable key (`sb_publishable_...`, found under Settings → API Keys); the legacy key is
   deprecated by end of 2026. The publishable key is safe to ship in the client — RLS is the actual
   guard, which is why the policies must be complete before anything reaches production. Verify at
   implementation time that the installed `supabase_flutter` version accepts the new key format.

## Testing

Existing tests are plain unit tests over `SharedPreferences.setMockInitialValues({})` with no
mocking framework. This feature follows the same pattern using a hand-written fake gateway.

| Area | Test |
|---|---|
| Mutation intents | `moveHymn(id, beforeId)` produces the same result applied before and after someone else's change |
| Conflict retry | fake gateway rejects the first write (stale version) → intent re-applies to fresh state → second write succeeds |
| Rollback | fake gateway throws a network error → local state returns to what it was before the mutation |
| Storage | round-trip of a shared list through `db.dart` (token, owner, version); a list without a token reads back as private |

RLS, realtime and App Links are verified manually — testing them in Dart proves nothing.

## Success Criteria

1. `fvm flutter analyze --fatal-infos` and `fvm flutter test` pass
2. The scenario from issue #31, steps 1 through 5b, works end to end on two physical devices
3. A change by user1 appears for user2 **with the list open** in under about 2 seconds
4. `adb shell pm get-app-links pl.norbertchmiel.spiewnik_pielgrzyma` reports `verified` for the domain
5. The link opens Google Play on Android without the app, and the web build on desktop
6. In airplane mode a shared list still renders and editing is blocked with a message
7. The owner deleting a list removes it for a member — immediately if the list is open, otherwise on
   the next pull
8. Every pre-existing private list works unchanged after the update

## Implementation Phases

Each phase leaves the app in a working state. Phases 1 and 2 can ship with no user-visible change.

1. **Infrastructure** — schema, RLS and RPC functions as a migration in `supabase/migrations/`;
   `supabase_flutter` in pubspec; on-demand anonymous sign-in; secrets in `.env` and the release
   workflow; lowered anonymous sign-in rate limit
2. **Sync without UI** — `SharedListGateway`, refactor mutations to intents, retry and rollback,
   cache in `db.dart`, the tests above
3. **Sharing UX** — share button and `share_plus`, share marker icon, delete/leave dialogs, offline
   edit lock, realtime subscription in `CustomListWidget`
4. **Deep links** — `dolacz.html`, `assetlinks.json`, narrowed manifest filter, `scp` fix, the
   `/dolacz` route and join screen

## Known Risk

The Supabase free plan pauses a project after seven days without traffic. This app is seasonal, so
that will happen out of pilgrimage season and shared lists would break until the project is manually
resumed. Phase 1 adds a scheduled GitHub Actions workflow that pings the API every three days.

## Out of Scope

Deliberately deferred until there is evidence they are needed: token revocation, member lists,
offline editing with a queue, iOS Universal Links, archiving shared lists, push notifications about
changes, change history, CAPTCHA on anonymous sign-in (rationale above), Supabase branching.
