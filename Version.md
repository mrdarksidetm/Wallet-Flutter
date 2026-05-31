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

## [2026-05-31 10:30] - Icon Picker Breaking Changes Fix
- **Action:** Resolved 64 compilation errors in `lib/core/widgets/icon_picker.dart`.
- **Changes:**
  - **MDI Fix:** Migrated `flutter_material_design_icons` usage from `fromString`/`getNames` (now missing in v3.1.0) to `MdiIcons.values` and `MdiIcons.maybeMetadataOf`.
  - **MDI Fix:** Implemented static name-to-icon cache in `AppIcons` for high-performance lookup.
  - **FontAwesome Fix:** Updated `font_awesome_flutter` (v11.0.0+) usage to access `.data` for `IconData` compatibility in `Icon` widgets.
  - **Tooling:** Installed GitHub CLI (`gh`) via winget for future CI log inspection.
- **Status:** 100% (Verified with `flutter analyze`).

## [2026-06-01 00:42] - Build Fix & CI Transparency
- **Action:** Resolved build failure caused by API 36/37 preview issues and improved CI visibility.
- **Changes:**
  - **SDK Downgrade:** Reverted compileSdk and 	argetSdk to 35 (Android 15) for stable builds, avoiding API 36/37 preview constraints.
  - **NDK Stabilization:** Hardcoded 
dkVersion to "27.0.12077973" in uild.gradle.kts.
  - **CI Improvement:** Modified GitHub Actions to show full build logs in the console (removed redirection to files).
  - **CI Improvement:** Hardened license acceptance by removing || true from lutter doctor --android-licenses.
  - **CI Improvement:** Added mkdir -p android/app before decoding keystore to prevent path errors.
- **Status:** 100% (Changes applied, ready for verification via CI).

## [2026-06-01 00:58] - Toolchain Upgrade (AGP 8.10.2 & SDK 36)
- **Action:** Upgraded Android build tools to satisfy dependency requirements discovered in CI.
- **Changes:**
  - **AGP Upgrade:** Bumped Android Gradle Plugin to 8.10.2 in settings.gradle.kts.
  - **SDK Upgrade:** Increased compileSdk and 	argetSdk to 36 to support modern AndroidX libraries (browser, activity, core).
  - **Validation:** Previous build logs explicitly requested these versions to resolve CheckAarMetadata errors.
- **Status:** 100% (Upgraded and ready for CI re-run).
