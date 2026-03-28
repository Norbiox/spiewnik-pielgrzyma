# Śpiewnik Pielgrzyma

Aplikacja do przeglądania i wyświetlania pieśni chrześcijańskich ze Śpiewnika Pielgrzyma.

## Development Setup

### Prerequisites

- **Flutter 3.35.6** (check `.flutter-version` for the required version)
  - Install from [flutter.dev](https://flutter.dev/docs/get-started/install)
  - Or use FVM: `fvm install` (after installing FVM)
- **Android SDK** (installed with Flutter)
- **Git** with SSH configured for GitHub (or HTTPS access)
- **Linux** (tested on kernel 6.19+)

### Getting Started

1. **Clone the repository**
   ```bash
   git clone git@github.com:Norbiox/spiewnik-pielgrzyma.git
   cd spiewnik-pielgrzyma
   ```

2. **Set up Flutter**
   - If using FVM: `fvm use` (auto-selects version from `.flutter-version`)
   - Otherwise, ensure Flutter 3.35.6 is installed: `flutter --version`

3. **Install dependencies**
   ```bash
   fvm flutter pub get
   ```

4. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` and fill in `PDF_ENCRYPTION_KEY` (get from project owner)

5. **Launch Android emulator**
   ```bash
   make emul
   ```

6. **Run the app**
   ```bash
   make run
   ```
   Or directly: `fvm flutter run`

### Available Commands

- `make run` - Run app in debug mode
- `make emul` - Launch Android emulator
- `make analyze` - Run static analysis and linting
- `make test` - Run analysis + unit tests
- `make build_web` - Build web release
- `make deploy_web` - Build and deploy web version

### Architecture & Documentation

See [CLAUDE.md](CLAUDE.md) for detailed architecture documentation, state management, navigation, and API design.

### Environment Variables

The app requires a `.env` file (copy from `.env.example`):

- `PDF_ENCRYPTION_KEY` - Secret key for PDF encryption (ask project owner or check GitHub Actions secrets)
- `PDF_LINK_BASE` - Base URL for PDF downloads (default: `https://spiewnikpielgrzyma.norbertchmiel.pl/note_files/`)

The `.env` file is git-ignored and should NOT be committed.

## Development & Release Flow

### Development

All work happens on `master` or in short-lived `feature/*` branches merged back to `master`. On every push/PR to `master`, CI runs formatting checks, static analysis, and tests.

### Releasing

Releases are triggered by pushing a version tag:

```bash
git tag v1.3.0
git push origin v1.3.0
```

This automatically:
1. Computes the version using GitVersion
2. Builds the Android appbundle (signed in CI)
3. Uploads to Google Play **internal testing** track (immediately available)
4. Builds and deploys the web version
5. Creates a GitHub Release with auto-generated notes

Production promotion is done manually from Play Console after verifying the internal build.

### Versioning

Versioning is handled by [GitVersion](https://gitversion.net/) in Mainline mode. Patch version increments automatically on `master`, minor on `feature/*` branches. No manual version bumps needed.

### Disaster Recovery

If your development machine fails:
1. Clone the repository again
2. Follow steps 2-4 above
3. All dependencies and configuration will be restored from git

All project code is version-controlled in git. The only non-recoverable item is `PDF_ENCRYPTION_KEY` (a secret) — store it in a password manager or ask the project owner for recovery.
