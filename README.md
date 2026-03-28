# Wallet

<p align="center">
  <img src="assets/icon/Original-Colour.svg" width="160" height="160" alt="Wallet Logo">
</p>

<p align="center">
  Offline-first personal finance app built with Flutter.
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-black.svg" alt="License MIT"></a>
  <img src="https://img.shields.io/badge/Flutter-3.5%2B-02569B.svg" alt="Flutter 3.5+">
  <img src="https://img.shields.io/badge/Android-Verified-3DDC84.svg" alt="Android verified">
</p>

## 📌 Repository Status

| Area | Status | Quick Link |
| ---- | ------ | ---------- |
| Release | Android release pipeline configured | [codemagic.yaml](codemagic.yaml) |
| Tests | Baseline suite available and expanding | [test](test) |
| Docs | Setup, contribution, and security docs available | [README.md](README.md), [CONTRIBUTING.md](CONTRIBUTING.md), [SECURITY.md](SECURITY.md) |

## ✨ Highlights

- 🔒 Privacy-first: core finance workflows work without cloud sync
- 🧠 Smart local insights: spending trends generated on-device
- ⚡ Fast local storage: Isar-backed data with generated adapters
- 📊 Complete money toolkit: transactions, budgets, goals, recurring, loans, labels
- 🎨 Polished UI: Material 3 styling with expressive animations

## 📱 Platform Status

- ✅ Verified: Android
- 🧪 Present in repository but not claimed as verified in this document: iOS, Windows, Linux, macOS

## 🚀 Quick Start

### Requirements

- Flutter SDK 3.5.0+
- Dart SDK 3.5.0+ (bundled with Flutter)
- Java 17 (Android toolchain)
- Android SDK
- VS Code or Android Studio

Environment check:

```bash
flutter doctor -v
```

### Setup

1. Clone with submodules (required for local Isar generator dependency).

```bash
git clone --recursive https://github.com/mrdarksidetm/Wallet.git
cd Wallet
```

1. Install dependencies.

```bash
flutter pub get
```

1. Generate code.

```bash
dart run build_runner build --delete-conflicting-outputs
```

1. Run the app.

```bash
flutter run
```

## 🛠️ Development

```bash
# Static analysis
flutter analyze

# All tests
flutter test

# Focused insights tests
flutter test test/features/insights/financial_insight_service_test.dart

# Re-generate code after model/provider changes
dart run build_runner build --delete-conflicting-outputs

# Release APKs
flutter build apk --release --split-per-abi

# Release App Bundle
flutter build appbundle --release
```

Repository release helper:

```bash
./build_release.sh
```

## 🧱 Architecture

Hybrid clean architecture plus feature modules:

```text
lib/
    app/           routing and app shell
    core/          database, services, theme, utilities
    data/          data abstractions and support models
    domain/        entities and business contracts
    features/      feature modules (accounts, budgets, insights, transactions, ...)
    presentation/  legacy presentation layer
    shared/        reusable UI and common helpers
```

Technical stack:

- Riverpod for state management and dependency injection
- GoRouter for navigation
- Isar for local persistence
- Local auth and privacy controls for device-only protection

## 📚 Project Docs

- Full feature and model specification: [SPEC.md](SPEC.md)
- Contribution guide: [CONTRIBUTING.md](CONTRIBUTING.md)
- Android CI workflow: [codemagic.yaml](codemagic.yaml)
- Security policy: [SECURITY.md](SECURITY.md)

## 🧰 Troubleshooting

- Build fails after pulling updates: run `flutter pub get` then code generation.
- Generated file or Isar errors: run build_runner with `--delete-conflicting-outputs`.
- Android Gradle issues: confirm Java 17 with `java -version`.
- Tests are currently growing: run existing suites before opening a PR.

## 📄 License

MIT © [Abhi](LICENSE)
