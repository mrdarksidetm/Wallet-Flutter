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
