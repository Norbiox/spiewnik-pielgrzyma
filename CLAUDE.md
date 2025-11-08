# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Śpiewnik Pielgrzyma is a Flutter mobile application for browsing and displaying Christian hymns. The app provides hymn browsing, search functionality, favorites management, custom playlists, and PDF viewing capabilities.

## Development Commands

### Build and Run
- `flutter run` - Run the app in debug mode
- `flutter emulators --launch Pixel_9` - Launch Android emulator

### Testing and Analysis  
- `flutter analyze` - Run static analysis and linting
- `flutter test` - Run unit tests

### Makefile shortcuts
- `make run` - Run the app
- `make emul` - Launch emulator
- `make test` - Run analysis
- `make build_web` - Build web release

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

## Key Features
- Hymn browsing with search functionality
- Favorites management with persistent storage
- Custom hymn playlists
- PDF viewing with encryption support
- Dark/light theme support
- Responsive UI with material design
