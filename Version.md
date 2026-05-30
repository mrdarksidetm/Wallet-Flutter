# Project Version History - Wallet (Improv)

## [2026-05-30 16:25] - CI/CD Integration
- **Action:** Added GitHub Actions workflow for automated APK builds.
- **Workflow:** `.github/workflows/build_apks.yml`
- **Features:**
  - Automated builds for `Universal`, `arm64-v8a`, and `armeabi-v7a` architectures.
  - Multi-stage build process with `build_runner` code generation.
  - Detailed error reporting (fail-safe) with log capture on failure.
  - Support for Android signing via GitHub Secrets (`KEYSTORE_BASE64`, etc.).
  - Artifact retention for APKs and debug symbols.
- **Status:** 100% (Workflow implemented and ready for repository integration).

## [2026-05-30 16:45] - Flutter 3.44 & Icon Compatibility Fix
- **Action:** Upgraded project to Flutter 3.44.x (Latest Stable 2026) and resolved icon package conflicts.
- **Changes:**
  - **Dependency Upgrade:** Replaced `material_design_icons_flutter` with `flutter_material_design_icons` (modern drop-in replacement).
  - **Dependency Upgrade:** Upgraded `font_awesome_flutter` to `^11.0.0`.
  - **Bug Fix:** Resolved `IconData` final class error caused by Flutter 3.22+ breaking changes.
  - **CI Improvement:** Upgraded GitHub Actions environment to Flutter 3.44.x.
  - **CI Improvement:** Refined fail-safe logging in `.github/workflows/build_apks.yml` (removed `--verbose` to reduce log bloat, added smarter error pattern matching).
- **Status:** 100% (Compatibility issues resolved and CI optimized).
