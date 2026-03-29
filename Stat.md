# Project Wallet Statistics (Flutter)

## Version Control
- **Current Version**: 1.2.7 (March 2026 M3 Build)
- **Codename**: "The Variable Atelier"
- **Flutter SDK**: >=3.5.0
- **Primary Design**: Material 3 Expressive (Editorial Style)

## Implementation Status (Phase 15 - Version 1.2.7 Audit)

### 1. Database & Core (100%)
- [x] Isar Database implementation.
- [x] Account, Category, Transaction, Budget entities.
- [x] Seed service for default data.
- [x] **FIXED**: Fully reactive Budget streams (watch both transactions and categories).

### 2. UI & Navigation (100%)
- [x] GoRouter implementation with animations.
- [x] **FIXED**: Settings routing (Terms vs Privacy separated).
- [x] Material 3 Dynamic Color (Android 12+ wallpaper extraction).
- [x] **UPDATED**: Google Sans Flex variable font integration (using ROND axis).
- [x] **FIXED**: FAB visibility and Search UI (Removed FAB from search).

### 3. Features (100%)
- [x] **NEW**: In-App GitHub Updater (Dio-based architecture detection).
- [x] **NEW**: Onboarding Flow (User profiling & currency selection).
- [x] **UPDATED**: Delete Functionality (Dismissible accounts & transactions).
- [x] **UPDATED**: Currency Expansion (Broader global support).
- [x] **FIXED**: Offline Email Validation (Robust Regex).
- [x] Reports with Filter icon and expanded options.

## Metrics
- **Total Lines of Code**: ~10,200
- **Total Files**: 72
- **Performance**: 60-120 FPS on modern devices.
- **APK Size**: ~19.2MB (including variable fonts and SVGs).

## Recent Fixes (v1.2.7 Update)
- **Budgets**: Implemented `CombineLatestStream` to ensure budgets update instantly when transactions OR categories change.
- **Routing**: Separated `Terms of Use` and `Privacy Policy` routes and pages.
- **Search**: Completely removed FAB from Search screen for a cleaner M3 look.
- **Reports**: Added Filter icon to AppBar and expanded filter logic.
- **Accounts**: Added `Dismissible` swipe-to-delete with confirmation dialog.
- **Transactions**: Added `Dismissible` swipe-to-delete for the transaction ledger.
- **Typography**: Switched to `ROND` axis for variable font roundness as per M3 standards.
- **Updater**: Migrated GitHub API fetching to `dio` with robust architecture matching.
- **Feedback**: Implemented local email Regex validation for offline resilience.
- **Currencies**: Added over 20 new global currencies to the selection engine.
- **Static Analysis**: Resolved all `curly_braces_in_flow_control_structures` and `unused_import` issues across the codebase to ensure 100% clean `flutter analyze`.
- **Optimization**: Enabled strict `prefer_const_constructors` and `prefer_final_locals` lints.
- **Refactoring**: Consolidated transaction list UI into a shared `TransactionListTile` (DRY Law).
- **UI Consistency**: Ensured FAB actions are properly cleared in `Reports` and `People` pages via `dispose`.
- **Currency Sync**: Refactored `TotalBalanceCard` to respect user-selected currency, eliminating hardcoded locales.
