# Flutter Intelligent Search Integration Plan

## Current State

Search is purely keyword-based, running client-side in `HymnsSearchEngine` (`lib/app/providers/hymns/search_engine.dart`). It scores hymns by number match (+100/+50), title match (+40), and text match (+10), with Polish diacritic normalization. Results update with 300ms debounce via `SearchAppBar`.

## Goal

Add an optional "intelligent search" mode that calls the semantic search API when the device is online, falling back to the existing keyword search when offline.

## Integration Points

### 1. Search API Client

Create `lib/app/services/search_api.dart`:
- HTTP client calling `POST /search` with `{"query": "...", "top_k": 20}`
- Configurable base URL via `.env` (`SEARCH_API_BASE`)
- Returns list of `{hymn_number, score}` pairs
- Timeout handling (e.g. 3s) — fall back to keyword search on timeout

### 2. Hybrid Scoring in HymnsSearchEngine

Update `lib/app/providers/hymns/search_engine.dart`:
- Keep existing `calculateScore()` as the keyword scorer
- When online and intelligent search enabled: call API, merge scores
- Proposed merge: `keyword_score + 0.5 * (semantic_score * 100)` (normalize semantic 0-1 to match keyword scale)
- When offline or API unavailable: use keyword-only scoring (current behavior)

### 3. UI Changes

**SearchAppBar** (`lib/app/widgets/shared/search_app_bar.dart`):
- No changes needed — already has 300ms debounce which is suitable for API calls

**HymnsListPage / FavoritesPage**:
- Search becomes async when using API — need to handle loading state
- Show subtle indicator when semantic search is active vs keyword-only

**Settings**:
- Toggle for "Intelligent search" (enabled by default when online)
- Persist preference in SharedPreferences

### 4. Configuration

Add to `.env`:
```
SEARCH_API_BASE=https://search.spiewnik.example.com
```

Register the search API client in `main.dart:setup()` via GetIt.

### 5. Connectivity Handling

- Use `connectivity_plus` package to detect online/offline state
- When offline: skip API call entirely, use keyword search
- When API returns error or times out: fall back to keyword search silently

## Implementation Order

1. Add search API client service
2. Add connectivity check
3. Update `HymnsSearchEngine` with hybrid scoring
4. Add async search support to pages (loading state)
5. Add settings toggle
6. Update `.env.example` with `SEARCH_API_BASE`

## Key Files to Modify

- `lib/app/services/search_api.dart` — new
- `lib/app/providers/hymns/search_engine.dart` — hybrid scoring
- `lib/app/providers/hymns/provider.dart` — async search support
- `lib/app/widgets/home/bottom_navigation.dart` — handle async results
- `lib/main.dart` — register search API service
- `.env` / `.env.example` — add `SEARCH_API_BASE`
- `pubspec.yaml` — add `connectivity_plus`, `http`
