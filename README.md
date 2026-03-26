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
   flutter pub get
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
   Or directly: `flutter run`

### Available Commands

- `make run` - Run app in debug mode
- `make emul` - Launch Android emulator (Pixel 3a API 34)
- `make test` - Run static analysis and linting
- `make build_web` - Build web release

### Architecture & Documentation

See [CLAUDE.md](CLAUDE.md) for detailed architecture documentation, state management, navigation, and API design.

### Environment Variables

The app requires a `.env` file (copy from `.env.example`):

- `PDF_ENCRYPTION_KEY` - Secret key for PDF encryption (ask project owner or check GitHub Actions secrets)
- `PDF_LINK_BASE` - Base URL for PDF downloads (default: `https://spiewnikpielgrzyma.norbertchmiel.pl/note_files/`)

The `.env` file is git-ignored and should NOT be committed.

### Release Builds

For release builds, Android signing is required:
- See `.github/workflows/release.yml` for CI/CD configuration
- Release builds are triggered on the `release` branch and signed automatically in GitHub Actions

### Disaster Recovery

If your development machine fails:
1. Clone the repository again
2. Follow steps 2-4 above
3. All dependencies and configuration will be restored from git

All project code is version-controlled in git. The only non-recoverable item is `PDF_ENCRYPTION_KEY` (a secret) — store it in a password manager or ask the project owner for recovery.
