# 📊 Project Wallet Statistics (Flutter)

Live tracking of the **Project Wallet** development lifecycle. 📈🏦

---

## 💎 Version Control
- **Current Version**: `2.0.4` 💎
- **Codename**: "The Expressive Motion"  skating_objects
- **Build Date**: June 1, 2026 📅
- **Flutter SDK**: `>=3.5.0` 💙
- **Primary Design**: Material 3 Expressive (Editorial Style) ✨

## 🚀 Implementation Status (v2.0.4 Audit)

### **💾 1. Database & Core (100%)**
- [x] Isar Database implementation. 📁
- [x] **FIXED**: Android Release Build (Keystore path resolution and build directory mismatch). 🛠️
- [x] **UPDATED**: `codemagic.yaml` with correct keystore path mapping. 🚦
- [x] **FIXED**: `libisar.so` dlopen error on Android arm64 by enforcing native lib extraction. 📂
- [x] **NEW**: Added `personId` to `TransactionModel` for high-performance filtering. ⚡
- [x] **UPDATED**: Loan model now correctly persists `dueDate`. ⏳
- [x] **UPDATED**: `TransactionService` now atomically syncs `personId` on all writes. ⛓️
- [x] **FIXED**: Missing `libisar.so` binaries in local `isar_flutter_libs` (Android/iOS). 🛠️
- [x] **FIXED**: Build failure caused by AGP/Gradle version mismatch and SDK 36 requirements. Upgraded to AGP 9.2.0 and Gradle 9.4.1. 🚀
- [x] **FIXED**: Plugin SDK conflicts by forcing `compileSdk 36` across all subprojects and upgrading NDK to `28.2.13676358`. 🛠️
- [x] **STABILIZED**: Build pipeline by synchronizing Kotlin plugin IDs and adding explicit CI cleanup steps. 🏗️

### **📱 2. UI & Navigation (100%)**
- [x] **FIXED**: `ReportsPage` undefined method `_showCategoryDetails`. 📊
- [x] **NEW**: `Hero` animations for transaction icons and category elements. 🦸‍♂️
- [x] **NEW**: Smart Search in `IconPickerWidget` with keyword-to-icon mapping. 🔍
- [x] **NEW**: Person Profile Editor with name editing and image cropping. 👤
- [x] **NEW**: Tap-and-hold (Long Press) to delete contacts in People tab. 🗑️

### **✨ 3. Features (100%)**
- [x] **NEW**: Bill Splitter -> Loan Integration. Finalize splits directly into debt entries. 💸
- [x] **NEW**: Goal styling with custom color pickers and smart icons. 🎨
- [x] **FIXED**: Loan Due Date bug - now correctly saved and displayed. 📅
- [x] **FIXED**: Person Transaction History - now correctly loads and merges both loans and transactions. 📊
- [x] **IMPROVED**: "Choose Icon" experience with better search and Material 3 iconography. ✨
- [x] **NEW**: GitHub Actions CI/CD Integration. Automated multi-ABI APK builds (`Universal`, `arm64-v8a`, `arm-v7a`) with detailed fail-safe logging. 🚀

---

## 📈 Metrics

- **Total Lines of Code**: ~14,280 📝
- **Total Files**: 84 📂
- **Performance**: 120 FPS target (Maintained) ⚡
- **APK Size**: ~21.8MB 📦

---

## 🛠️ Recent Fixes (v2.0.4 Update)

- **🏗️ Pipeline Stabilization**: Fixed the "missing APK" issue in CI by adding explicit `flutter clean` and directory management to the workflow. Synchronized Kotlin plugin IDs to `org.jetbrains.kotlin.android` for modern AGP 9.x compliance.
- **🛠️ Plugin SDK Harmonization**: Added a `subprojects` override in `build.gradle.kts` to force all Flutter plugins to compile and target **SDK 36**. This resolves the `CheckAarMetadata` failure where plugins like `file_picker` were using SDK 34 while their dependencies required SDK 36.
- **💾 NDK Upgrade**: Upgraded to **NDK 28.2.13676358** as required by the latest versions of `device_info_plus` and other ecosystem plugins in the Android 16 (SDK 36) environment.
- **💎 Kotlin Upgrade**: Bumped Kotlin to **2.2.20** to ensure long-term compatibility with the Flutter build toolchain and avoid deprecation warnings.

---
*Built with ❤️ for the Flutter Community.* 💼✨
