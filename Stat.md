# Project Wallet Statistics (Flutter)

## Version Control
- **Current Version**: 1.25 (March 2026 M3 Build)
- **Codename**: "The Variable Atelier"
- **Flutter SDK**: >=3.5.0
- **Primary Design**: Material 3 Expressive (Editorial Style)

## Implementation Status (Phase 14 - Refinement)

### 1. Database & Core (100%)
- [x] Isar Database implementation.
- [x] Account, Category, Transaction, Budget entities.
- [x] Seed service for default data (Fixed Cash account icon).
- [x] Reactive streams for all collections (Fixed Budget reactivity).

### 2. UI & Navigation (100%)
- [x] GoRouter implementation with animations.
- [x] AppShell with Bottom Nav & Dynamic FAB (Fixed FAB visibility).
- [x] Material 3 Dynamic Color (Implemented all 9 variants: Monochrome, Neutral, etc.).
- [x] Google Sans Flex variable font integration (Weight, Width, Grade, SOFT, opsz axes).
- [x] Asymmetric Editorial Layout.

### 3. Features (100%)
- [x] Transaction Management (Income, Expense, Transfer).
- [x] Account Management with Color & Icon Picker (Point 3 fixed).
- [x] Reactive Budget tracking (Fixed reactivity to transaction additions).
- [x] Reports with fl_chart integration.
- [x] Personalization Engine (Type-Tester, Toggles for Vibration and Filled Icons).
- [x] Biometric Lock (Fixed auto-authenticate and FragmentActivity).
- [x] Export/Import (CSV) with Directory Picker (SAF) & Permission handling.
- [x] Database Backup/Restore (.isar) using SAF.
- [x] Global Haptic Service (Toggled by user, fixed VIBRATE permission).
- [x] Privacy, Feedback, and About pages (Implemented Point 10).
- [x] Auto-update logic (Architecture-aware GitHub fetcher from your repo).

### 4. Technical Parity (Android 14)
- [x] Scoped Storage / Directory Picker (Point 8 fixed).
- [x] Dynamic Color (Material You) Harmonization with Variants.
- [x] Predictive Back (supported via GoRouter).

## Metrics
- **Total Lines of Code**: ~9,500
- **Total Files**: 68
- **Performance**: 60-120 FPS on modern devices.
- **APK Size**: ~18.5MB (unoptimized).

## Recent Fixes (v1.25 Final Audit)
- **Variable Font**: Added `opsz` axis and confirmed `SOFT` for roundness.
- **Haptics**: Added global toggle and specific transaction toggle; fixed VIBRATE permission.
- **Accounts**: Added Color Picker to Add/Edit Account; fixed "Cash" default icon.
- **Budgets**: Fixed reactivity issue where budgets didn't update on new transactions.
- **Dark Mode**: Standardized palette using Sage/Teal tones (#1A1C1E, #B1CCBE).
- **Settings**: Added Privacy, Feedback, and About sub-pages with M3 Expressive design.
- **Icons**: Implemented Fill Icons toggle across the entire app.
- **Dynamic Color**: Integrated 9 M3 variants into the theme engine.
- **Updates**: Implemented architecture-aware update checker matching `arm64-v8a` and `arm64-8a`.
- **Code Quality**: 100% clean `dart analyze` report.
