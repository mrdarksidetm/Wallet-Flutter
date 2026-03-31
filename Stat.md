# Project Wallet Statistics (Flutter)

## Version Control
- **Current Version**: 1.3.0 (March 2026 M3 Build)
- **Codename**: "The Reactive Atelier"
- **Flutter SDK**: >=3.5.0
- **Primary Design**: Material 3 Expressive (Editorial Style)

## Implementation Status (Phase 18 - Version 1.3.0 Audit)

### 1. Database & Core (100%)
- [x] Isar Database implementation.
- [x] Account, Category, Transaction, Budget entities.
- [x] Seed service for default data.
- [x] **FIXED**: Fully reactive Budget streams (watch both transactions and categories).
- [x] **NEW**: Added `int order` field to `Account` model for custom reordering.
- [x] **NEW**: Added `.name` getters to all core Enums to prevent `NoSuchMethodError`.

### 2. UI & Navigation (100%)
- [x] GoRouter implementation with animations.
- [x] **FIXED**: Resolved duplicate FABs by centralizing layout in `AppShell`.
- [x] **UPDATED**: Dynamic `HomeHeader` in `AppShell`.
- [x] **NEW**: Merged "Theme & Style" and "Dynamic Color" into a unified "Preferences" section.
- [x] **UPDATED**: Renamed "Personalization" to "Preferences" and redesigned the layout for better information density.
- [x] **NEW**: "Reorder Accounts" Bottom Sheet with `ReorderableListView`.
- [x] **NEW**: "Edit Account" Bottom Sheet with Editorial-style Tabs and Color/Icon selection.

### 3. Features (100%)
- [x] **NEW**: In-App GitHub Updater.
- [x] **NEW**: Onboarding Flow.
- [x] **NEW**: Edit Profile Screen.
- [x] **NEW**: Statistics Service methods for Heatmap and Trend Chart.
- [x] **UPDATED**: Haptic feedback policy: **ONLY** used for new transaction additions.
- [x] **NEW**: "Vibrate on Transaction" toggle in Preferences.
- [x] **FIXED**: Stripped 100% of non-essential haptic/vibration calls from the codebase.
- [x] **FIXED**: Data loss on transaction edit by implementing robust loading of `IsarLink`s and loading states.
- [x] **FIXED**: Category reset bug when re-selecting the same category during edit.

## Metrics
- **Total Lines of Code**: ~12,500
- **Total Files**: 78
- **Performance**: 60-120 FPS on modern devices.
- **APK Size**: ~20.1MB.

## Recent Fixes (v1.3.0 Update)
- **Data Persistence**: Fixed a critical bug where editing a transaction would lose its account or category links due to asynchronous loading races.
- **Account Reordering**: Implemented the `order` field in the `Account` model and added a `ReorderableListView` interface to allow users to customize their account display order.
- **Interactive Modals**: Replaced page-based navigation for account editing with highly interactive, polished Bottom Sheets (Editorial Style) as per the "Super Prompt" architecture.
- **UI Refinement**: Added `smooth_page_indicator` for account cards and refined the "Accounts & Wallets" screen with `CustomScrollView` and synchronized stats.
- **Lint Cleanup**: Achieved a 100% clean `flutter analyze` report (zero errors, warnings, or infos) across the entire project.
- **Dependency Update**: Integrated `smooth_page_indicator` into `pubspec.yaml`.
- **Bug Fix**: Resolved `peopleStreamProvider` rename and missing `ExpressiveBottomSheet` title parameters.
