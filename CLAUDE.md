# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Behavioral foundation

You don't code. You provide me help and guidance and I code.
When I need you to help me with a feature/bug/refactoring/etc, I'll describe the problem and you'll provide me with guidance and help, not with the solution itself.
You remember, I'm a python programmer, not a flutter one. I learn dart/flutter by the way of doing this project.
I'm a backend developer, not a frontend one, so you guide me especially with the UI/UX stuff.
When you propose a new concept, pattern or idea, try to provide me with useful links and references to documentation/articles/etc. so I can learn more about it and understand it better.
When there's a decision to make, try to provide me explanations and justifications so I can understand the tradeoffs and decide for myself.
Sometimes, I might ask you to design and code a feature or resolve a bug.
Then follow these rules:
- Don't assume. Don't hide confusion. Surface tradeoffs.
- Minimum code that solves the problem. Nothing speculative.
- Touch only what you must. Clean up only your own mess.
- Define success criteria. Loop until verified.

## Project Overview

Śpiewnik Pielgrzyma is a Flutter mobile application for browsing and displaying Christian hymns. The app provides hymn browsing, search functionality, favorites management, custom playlists, and PDF viewing capabilities.

## Monorepo Structure

| Directory | Description |
|---|---|
| `lib/` | Flutter app source |
| `search-worker/` | Cloudflare Worker for semantic search (TypeScript) |
| `scripts/` | Build-time scripts (embedding generation) |
| `docs/` | Design docs and ADRs |
| `assets/` | Hymn data (CSV + JSON) |

Tools managed via `mise` (`mise.toml`). Secrets managed via `fnox` (`fnox.toml`, encrypted with age).

## Development Commands

### Flutter App
- `fvm flutter run` - Run the app in debug mode
- `fvm flutter emulators --launch Pixel_9` - Launch Android emulator
- `fvm flutter analyze` - Run static analysis and linting
- `fvm flutter test` - Run unit tests
- `make run` / `make emul` / `make analyze` / `make test` / `make build_web` - Makefile shortcuts

### Search Worker (`search-worker/`)
- `mise r search-worker:dev` - Local dev against real CF infra
- `mise r search-worker:deploy` - Deploy to Cloudflare

### Embedding Generation
- `fnox exec -- uv run --project search-worker --group dev python scripts/generate_embeddings_bge_m3.py` - Regenerate BGE-M3 embeddings (needs `CLOUDFLARE_ACCOUNT_ID` + `CLOUDFLARE_API_TOKEN` from fnox)
- After regeneration, upload to KV: `wrangler kv key put --namespace-id=<id> --remote "hymns_embeddings_bge_m3.bin" --path=search-worker/data/hymns_embeddings_bge_m3.bin`

## Architecture

### Dependency Injection
- Uses `get_it` for service locator pattern
- Services registered in `main.dart:setup()`
- Key services: `EncryptionService`, `ThemeProvider`, `SharedPreferences`, hymns data, providers

### State Management
- Provider pattern with `provider` package and `watch_it` for reactive updates
- Main providers:
  - `HymnsListProvider` - manages hymn list, search, and favorites
  - `CustomListProvider` - manages custom playlists
  - `HymnPdfProvider` - handles PDF downloads and encryption
  - `ThemeProvider` - manages light/dark theme state

### Navigation
- Uses `go_router` for declarative routing
- Routes defined in `router.dart`
- Main routes: home (`/`), favorites (`/favorites`), custom lists (`/custom-lists`), hymn details (`/hymn/:id`)

### Data Layer
- Hymn metadata loaded from `assets/hymns.csv`
- Hymn texts loaded from `assets/hymns_texts.json`
- Persistence via `SharedPreferences` for favorites and custom lists
- Database operations abstracted in `infra/db.dart`

### Core Models
- `Hymn` - represents a hymn with id, number, title, group, subgroup, text, and favorite status
- `CustomList` - represents user-created hymn playlists

### Widget Organization
- `app/widgets/` contains feature-specific UI components:
  - `hymns/` - hymn browsing and display
  - `favorites/` - favorites management  
  - `custom_lists/` - custom playlist management
  - `home/` - main navigation and theme controls
  - `menu/` - app menu
  - `utils/` - shared UI utilities

### Environment Configuration
- Uses `flutter_dotenv` for environment variables
- Requires `.env` file with `PDF_ENCRYPTION_KEY` and `PDF_LINK_BASE`
- PDF encryption handled by `EncryptionService` using `encrypt` package

### Localization
- Configured for Polish locale (`pl_PL`)
- Uses `flutter_localizations` and `syncfusion_localizations`

## Search Worker

Cloudflare Worker in `search-worker/` serving semantic search over hymns.

- **Model**: `@cf/baai/bge-m3` via Cloudflare Workers AI, truncated to 384 dims (Matryoshka)
- **Embeddings**: pre-computed at build time, stored in Workers KV (binding: `SPIEWNIK_PIELGRZYMA`)
- **Endpoint**: `POST https://spiewnik-pielgrzyma-search.norbertchmiel-it.workers.dev/search`
- **Request**: `{"query": "...", "top_k": 20}`
- **Response**: `{"results": [{"hymn_number": "123", "verse_index": 0, "score": 0.87}, ...]}`
- **KV upload**: always use `--remote` flag with `wrangler kv key put`, otherwise writes go to local storage only
- **Secrets**: `CLOUDFLARE_ACCOUNT_ID` and `CLOUDFLARE_API_TOKEN` in `fnox.toml`

## CI/CD & Release

- **CI**: Every push/PR to `master` runs formatting, `fvm flutter analyze --fatal-infos`, and `fvm flutter test` (`.github/workflows/analyse.yml`)
- **Release**: Triggered by pushing a `v*` tag to `master`. Builds Android appbundle, uploads to Google Play internal track, deploys web, and creates a GitHub Release (`.github/workflows/release.yml`)
- **Versioning**: Version is derived from the git tag (e.g., `v1.3.0` → `1.3.0`), build number from GitHub Actions run number
- **Web deploy**: SCP to hosting server, requires `WEB_HOST_USER`, `WEB_HOST`, `WEB_HOST_PATH` GitHub Secrets

## Key Features
- Hymn browsing with search functionality
- Favorites management with persistent storage
- Custom hymn playlists
- PDF viewing with encryption support
- Dark/light theme support
- Responsive UI with material design
