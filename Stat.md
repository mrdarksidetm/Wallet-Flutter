# Project Wallet Statistics (Flutter)

## Version Control
- **Current Version**: 1.2.9 (March 2026 M3 Build)
- **Codename**: "The Variable Atelier"
- **Flutter SDK**: >=3.5.0
- **Primary Design**: Material 3 Expressive (Editorial Style)

## Implementation Status (Phase 17 - Version 1.2.9 Audit)

### 1. Database & Core (100%)
- [x] Isar Database implementation.
- [x] Account, Category, Transaction, Budget entities.
- [x] Seed service for default data.
- [x] **FIXED**: Fully reactive Budget streams (watch both transactions and categories).
- [x] **NEW**: Added `.name` getters to all core Enums to prevent `NoSuchMethodError`.

### 2. UI & Navigation (100%)
- [x] GoRouter implementation with animations.
- [x] **FIXED**: Resolved duplicate FABs by centralizing layout in `AppShell`.
- [x] **UPDATED**: Dynamic `HomeHeader` in `AppShell`.
- [x] **NEW**: Merged "Theme & Style" and "Dynamic Color" into a unified "Preferences" section.
- [x] **UPDATED**: Renamed "Personalization" to "Preferences" and redesigned the layout for better information density.

### 3. Features (100%)
- [x] **NEW**: In-App GitHub Updater.
- [x] **NEW**: Onboarding Flow.
- [x] **NEW**: Edit Profile Screen.
- [x] **NEW**: Statistics Service methods for Heatmap and Trend Chart.
- [x] **UPDATED**: Haptic feedback policy: **ONLY** used for new transaction additions.
- [x] **NEW**: "Vibrate on Transaction" toggle in Preferences.
- [x] **FIXED**: Stripped 100% of non-essential haptic/vibration calls from the codebase.

## Metrics
- **Total Lines of Code**: ~10,800
- **Total Files**: 74
- **Performance**: 60-120 FPS on modern devices.
- **APK Size**: ~19.5MB.

## Recent Fixes (v1.2.9 Update)
- **Haptic Cleanup**: Removed 60+ instances of `HapticService` calls from across the app. The app no longer vibrates on buttons, sliders, or list tiles.
- **Selective Vibration**: Configured `HapticService.transaction` as the sole entry point for vibration, gated by the user's preference and triggered only on new transaction saves.
- **Unified Preferences**: Consolidated all appearance and behavior settings (Typography, Theme, Dynamic Color, Haptics, Icon Fill) into a single editorial-style "Preferences" page.
- **Settings UX**: Simplified the main Settings screen by grouping related options under "General" and "Security".
- **Bug Fix**: Resolved a syntax error in `CategoryDetailsPage` caused by an empty `onTap` parameter.
- **Persistence**: Ensured the "Vibrate on Transaction" setting is correctly persisted in `SharedPreferences` via the `PersonalizationNotifier`.
