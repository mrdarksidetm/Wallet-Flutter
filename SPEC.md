# SPEC.md — Wallet App Design Specification
# ═══════════════════════════════════════════
# This file is IDENTICAL in both the Compose and Flutter repos.
# It is the single source of truth for feature parity between both versions.
# When you update a feature, update THIS SPEC first, then implement in both codebases.
#
# Last synced: 2026-03-13

## 1. App Identity

| Field          | Value                                   |
|----------------|------------------------------------------|
| Name           | Wallet                                  |
| Package (Android) | `com.mrdarksidetm.wallet`            |
| Package (iOS)  | `com.mrdarksidetm.wallet`              |
| Min Android    | API 29 (Android 10)                     |
| Target Android | API 34 (Android 14)                     |
| Design System  | Google Material 3 Expressive            |
| Iconography    | Adaptive Icons (Android)                |
| Architecture   | MVVM + Unidirectional Data Flow         |
| Network        | **Offline-first. Zero network calls.**  |

### 1.1 Iconography
- **Foreground**: Wallet Logo (`Wallet - Transparent.svg`)
- **Background**: `#fff8f6` (Light), `#1a110e` (Dark)
- **Monochrome Support**: Logo with `#795548`

---

## 2. Data Model

> **V2 Data Architecture (In Progress):** Both Android and Flutter platforms are actively migrating towards a UUID-based schema (String) to replace `Long`/`Int` IDs. This highly scalable normalized schema isolates `Transaction`, `Category`, and `Account` entities, using UUIDs for relationships instead of hard foreign keys to support easier syncing and memory efficiency.

### 2.1 Account

| Field          | Type     | Kotlin (Room)     | Dart (Isar)            | Notes                         |
|----------------|----------|-------------------|------------------------|-------------------------------|
| id             | Integer  | `Long` (auto-gen) | `Id` (auto-increment)  | Primary key                   |
| name           | String   | `String`          | `String`               | e.g. "Cash", "Bank"          |
| type           | String   | `String`          | `String`               | "Bank", "Cash", "Wallet"     |
| initialBalance | Decimal  | `Double`          | `double`               | Starting balance              |
| createdAt      | Datetime | `Long` (millis)   | `DateTime`             | Auto-set on creation          |

### 2.2 Transaction

| Field     | Type     | Kotlin (Room)     | Dart (Isar)            | Notes                           |
|-----------|----------|-------------------|------------------------|---------------------------------|
| id        | Integer  | `Long` (auto-gen) | `Id` (auto-increment)  | Primary key                     |
| accountId | Integer  | `Long` (FK)       | `long` (link)          | Foreign key → Account           |
| amount    | Decimal  | `Double`          | `double`               | Always positive                 |
| type      | String   | `String`          | `String`               | `"Income"` / `"Expense"`       |
| note      | String   | `String`          | `String`               | User description                |
| category  | String   | `String`          | `String` (via Category)| e.g. "Food", "Salary"          |
| date      | Datetime | `Long` (millis)   | `DateTime`             | Transaction date                |

### 2.3 Category

| Field | Type    | Kotlin (Room)     | Dart (Isar)           | Notes                    |
|-------|---------|-------------------|-----------------------|--------------------------|
| id    | Integer | `Long` (auto-gen) | `Id` (auto-increment) | Primary key              |
| name  | String  | `String`          | `String`              | e.g. "Food", "Transport" |
| icon  | String  | `String`          | `int` (Material icon) | Icon identifier          |

---

## 3. Screen Inventory

### 3.1 Dashboard (Home)

- **Route:** `/home`
- **Total Balance Card:**
  - Large balance display with currency formatting
  - Eye icon toggle to hide/show balance
  - "This month" breakdown: Income (green) / Expense (red) with percentage indicators
- **Overview Grid:** 2-column `LazyVerticalGrid` / `GridView`
  - Cards: Budgets, Assets, Bill Splitter, Loans
  - Each card shows summary value + icon
- **Top App Bar:**
  - Left: Profile avatar placeholder
  - Center: Greeting text ("Good evening, [User]")
  - Right: Premium badge icon

### 3.2 Accounts / Ledger

- **Route:** `/accounts`
- **Transaction list:** `LazyColumn` / `ListView`
  - Each item: Category icon, Note, Date, Amount
  - Amount color: green = Income, red = Expense
  - **Swipe-to-dismiss** for deletion (M3 `SwipeToDismissBox` / `Dismissible`)
  - List item animation on add/delete (glide, not instant)
- **Account filter tabs** at top

### 3.3 Add Transaction

- **Route:** `/add-transaction`
- **Income/Expense toggle:** M3 `SingleChoiceSegmentedButtonRow` / `SegmentedButton`
- **Amount field:** Numeric `OutlinedTextField` / `TextFormField`
- **Note field:** Text `OutlinedTextField` / `TextFormField`
- **Category selector:** Dropdown or BottomSheet
- **Account selector:** Dropdown
- **Save button:** Transforms into `CircularProgressIndicator` while saving
- **Validation:** Amount > 0, Note not empty

### 3.4 Reports / Analytics

- **Route:** `/reports`
- **Donut Chart:** Native `Canvas` / `CustomPainter` — NO third-party chart libraries
  - Shows Expense vs. Income ratio
  - Animated on load (sweep animation)
  - Center: total or percentage
- **Spending Breakdown:** Category-based list with amounts and percentages
- **Summary Card:** ElevatedCard with period totals

### 3.5 Settings (Future)

- **Route:** `/settings`
- Currency selection
- Theme toggle (light/dark)
- Export data (CSV)
- About screen

---

## 4. Design Tokens

### 4.1 Typography

| Scale          | Font              | Fallback   |
|----------------|-------------------|------------|
| Display/Title  | Google Sans Flex   | Noto Sans  |
| Body/Label     | Google Sans        | Noto Sans  |

All fonts are **bundled locally** in the APK/app bundle. No network font loading.

### 4.2 Colors

| Semantic       | Light Mode     | Dark Mode          |
|----------------|----------------|--------------------|
| Background     | M3 surface     | `#121212` / dark   |
| Income         | Vibrant green  | Vibrant green      |
| Expense        | Soft alert red | Soft alert red     |
| Card surface   | Elevated tone  | Elevated dark tone |

Dynamic M3 color is preferred. Hardcode premium defaults as fallback.

### 4.3 Spacing & Shape

| Element        | Corner Radius  |
|----------------|----------------|
| Standard Card  | 16.dp–24.dp    |
| Bottom Sheet   | 16.dp–24.dp    |
| Buttons        | M3 default     |

---

## 5. Behavioral Rules

1. **Offline-first:** Zero network calls. All data in local database.
2. **No splash screen:** Use M3 `CircularProgressIndicator` for operations taking 200ms–5s.
3. **Feedback:** `SnackbarHost` for success/deletion messages (non-blocking).
4. **Animations:** No instant vanishing. Use spring physics (`spring(dampingRatio, stiffness)` / implicit animations).
5. **List animations:** Items glide in/out on add/delete.
6. **Architecture:** Strict MVVM with unidirectional data flow.
7. **DI:** Manual (no Hilt/Dagger in Compose; Provider/Riverpod in Flutter).
8. **Memory ceiling:** Designed for 4GB RAM devices. Keep APK lean. No heavy libraries.

---

## 6. Feature Parity Checklist

| Feature                       | Compose | Flutter | Notes                         |
|-------------------------------|---------|---------|-------------------------------|
| Room/Isar database            | ✅      | ✅      |                               |
| Accounts CRUD                 | ✅      | ✅      |                               |
| Transactions CRUD             | ✅      | ✅      |                               |
| Categories                    | ✅      | ✅      |                               |
| Dashboard (Total Balance)     | ✅      | ✅      |                               |
| Overview Grid                 | ✅      | ✅      |                               |
| Transaction List              | ✅      | ✅      |                               |
| Swipe-to-delete               | ✅      | ✅      |                               |
| Add Transaction Form          | ✅      | ✅      |                               |
| Donut Chart (Canvas)          | ✅      | ✅      |                               |
| Spending Breakdown            | ✅      | ✅      |                               |
| Spend Heatmap                 | ✅      | ✅      | Compose Canvas implemented    |
| Insights (AI / Charts)        | ✅      | ✅      | Vico & fl_chart integrated    |
| Budgets                       | ✅      | ✅      | SQLite SUM calculations       |
| Bill Splitter                 | ✅      | ✅      | TransactionSplit DB added     |
| Goals                         | ✅      | ✅      | DAO and Models created        |
| Loans                         | ✅      | ✅      | DAO and Models created        |
| Recurring Transactions        | ✅      | ✅      | WorkManager scaffolding added |
| Search                        | ✅      | ✅      | M3 SearchBar implemented      |
| Settings                      | ✅      | ✅      | DataStore integrated          |
| CSV Export                    | ✅      | ✅      | MediaStore utility added      |
| People/Contacts               | ✅      | ✅      | Models linked                 |

| On-Device NLP / Chat            | ✅      | ✅      | Compose ChatScreen built      |
| Crashlytics (Offline)         | ✅      | ✅      | LocalCrashReporter added      |
| Haptic Engine                 | ✅      | ✅      | Vibrate API wrapped safely    |
| DB Vacuuming (Defrag)         | ✅      | ✅      | SQLite Truncate & Vacuum      |
| Home Screen Shortcuts         | ✅      | ✅      | ShortcutsUtil added           |
| Accessibility & L10n          | ⬜      | ⬜      |                               |
| Automated Testing             | ⬜      | ⬜      |                               |
| Gamification & Streaks        | ✅      | ✅      | StreakEngine integrated       |
| P2P Offline Sync Prep         | ⬜      | ⬜      |                               |
| CI/CD Deployment              | ⬜      | ⬜      |                               |
| Advanced DB Migrations        | ⬜      | ⬜      |                               |
| Offline OCR Receipts          | ⬜      | ⬜      |                               |
| Local Notifications           | ✅      | ✅      |                               |
| QR Code Data Transfer         | ⬜      | ⬜      |                               |
| Offline Multi-Currency        | ✅      | ✅      | CurrencyEngine added          |
| Debt Payoff Calculators       | ✅      | ✅      | DebtPayoffEngine added        |
| Custom Home Screen Widgets    | ⬜      | ⬜      |                               |
| Privacy Masking               | ✅      | ✅      | Masking toggles added         |
| Secure Data Shredding         | ✅      | ✅      | DataShredder util added       |
| Wear OS & Apple Watch         | ⬜      | ⬜      |                               |
| Anti-Tampering & Secure DB    | ⬜      | ⬜      |                               |
| Offline PDF Reporting         | ⬜      | ⬜      |                               |
| Local Voice Expense Entry     | ⬜      | ⬜      |                               |
| Privacy Geofencing            | ⬜      | ⬜      |                               |
| Quick Settings Tiles          | ⬜      | ⬜      |                               |
| Dynamic Theming               | ⬜      | ⬜      |                               |
| Custom App Icon Switcher      | ⬜      | ⬜      |                               |
| On-Device ML Retraining       | ⬜      | ⬜      |                               |
| Offline Onboarding            | ⬜      | ⬜      |                               |
| Profiling & Memory Leaks      | ⬜      | ⬜      |                               |
| Foldable Adaptive Layouts     | ⬜      | ⬜      |                               |
| Subscription Calendar         | ✅      | ✅      | Matrix grid implemented       |
| Account Reconciliation        | ✅      | ✅      | Flow diff engine built        |
| Round-Up Savings Goals        | ✅      | ✅      | RoundUpEngine added           |
| Backup Reminders & TTL        | ✅      | ✅      | TTL evaluation logic added    |
| Dynamic Feature Modules       | ⬜      | ⬜      |                               |
| UI Choreography (Phase 52)    | ✅      | ✅      | Bouncy clicks & odometers     |

> ⬜ = Not yet implemented &nbsp; ✅ = Implemented

---

## 10. Debug History & Known Issues

### 2026-03-14: Version Catalog & Toolchain Sync
- **Issue:** Duplicate `[versions]` and `[libraries]` sections in `libs.versions.toml` causing Gradle build failure.
- **Status:** Fixed. Verified by running `.\gradlew compileDebugKotlin`.
- **Issue:** Java toolchain mismatch (expected 17, found 21).
- **Status:** Updated `app/build.gradle.kts` to use Java 21 toolchain and compatibility options.
- **Issue:** UUID Migration compilation errors in `AppDatabase.kt` and `RoundUpEngine.kt`.
- **Status:** Updated pre-population logic to use String IDs and converted `RoundUpEngine` to use `TransactionEntity` with String types.
- **Issue:** Compose 1.7.0 features (`SharedTransitionApi`, `animateItem`) missing.
- **Status:** Upgraded `composeBom` to `2024.10.01` in `libs.versions.toml`.

### 2026-03-14: Flutter Parity Sync
- **Issue:** Missing dependencies (`uuid`, `decimal`) and broken imports.
- **Status:** Added dependencies to `pubspec.yaml`, fixed relative imports in `transaction_repository.dart`.
- **Issue:** Isar pluralization mismatch (`categorys` vs `categories`).
- **Status:** Verified generated schema uses `categorys` and corrected all repository references.
- **Issue:** Syntax error in `total_balance_card.dart` (missing closing parenthesis for `PaisaCard`).
- **Status:** Fixed. Verified with `flutter analyze`.

### 2026-03-14: Phase 24 Implementation
- **Feature:** Local Scheduled Notifications (Scaffolding).
- **Compose:** Added `NotificationHelper` and `ReminderWorker` using `WorkManager`.
- **Flutter:** Added `NotificationService` using `flutter_local_notifications` and `timezone`.

---

## 11. Feature Parity Checklist (Updated)

The following architectural plans have been mocked up and planned, awaiting full execution in future phases:

### Phase 20: Peer-to-Peer (P2P) Offline Sync Prep
Prepare the app to sync data with a partner (e.g., a spouse) without the internet.
- **Implementation:** Create a scaffolding layer using Android's Nearby Connections API or a local Bluetooth/WiFi Direct implementation for Flutter. 
- **Conflict Resolution:** Write the merge logic that compares the `updatedAt` timestamps of two UUID records to decide which transaction state wins during a local sync.

### Phase 21: CI/CD & Automated Store Deployment
Automate the build process.
- **Implementation:** Provide the complete `fastlane` Fastfiles and GitHub Actions `.yml` workflow files to automatically lint, test, and build the Android App Bundle (.aab) and Flutter release APKs.

### Phase 23: Offline OCR & Receipt Scanning
Allow users to extract totals from physical receipts without sending images to the cloud.
- **Implementation:** Integrate Google ML Kit Text Recognition (`google_mlkit_text_recognition` in Flutter, and native ML Kit Vision in Android). Build a regex parser to find the "Total" amount in the scanned text bloc.

### Phase 24: Local Scheduled Notifications
Remind users of upcoming bills without a server.
- **Implementation:** Use Android `AlarmManager` / `WorkManager` and Flutter `flutter_local_notifications` to schedule a background trigger that checks the `RecurringTransaction` table and fires a local push notification 24 hours before a bill is due.

### Phase 25: Cross-Device Data Transfer (QR Codes)
Transfer small transaction batches locally between devices securely.
- **Implementation:** Generate a dense QR code containing a compressed JSON payload of a specific split-bill transaction. Build a scanner to read and import this JSON payload into the recipient's UUID database.

### Phase 28: Custom Home Screen Widgets
Bring the dashboard to the user's home screen.
- **Implementation:** Build a Jetpack Glance widget (Android) and use `home_widget` (Flutter) to create a 2x2 widget displaying the total balance and a progress bar for the current month's budget.

### Phase 31: Wear OS & Apple Watch Scaffolding
Extend the ecosystem to the wrist.
- **Implementation:** Scaffold a basic Wear OS module (using Compose for Wear OS) and an Apple Watch target (using Swift/WatchKit interfacing with Flutter) that can receive a simple "Add Quick Expense" command and send it to the phone via the local Bluetooth/Data Layer API.

### Phase 32: Advanced Anti-Tampering & Secure Enclave Setup
Protect the local database from physical extraction on compromised devices.
- **Implementation:** Implement Root/Jailbreak detection (using `rootbeer` for Android or `flutter_jailbreak_detection` for Flutter). Encrypt the Room/Isar database using SQLCipher and the device's hardware-backed Keystore/Secure Enclave.

### Phase 33: Offline PDF Generation & Reporting
Allow users to generate beautiful, shareable financial reports locally.
- **Implementation:** Create a `ReportGenerator` utility. Use native Android `PdfDocument` and the Flutter `pdf` package to draw a multi-page PDF containing the user's monthly transactions and the Canvas/fl_chart charts we built in Phase 4.

### Phase 34: Local Voice Expense Entry (On-Device NLP)
Allow users to dictate expenses (e.g., "Spent twenty dollars on coffee").
- **Implementation:** Integrate on-device Speech-to-Text (`SpeechRecognizer` API in Android, `speech_to_text` in Flutter configured for offline models). Create a regex/NLP parser to extract the `amount` and `note` from the raw transcribed text.

### Phase 35: Privacy-Preserving Geofencing & Location Tagging
Remember where an expense happened without tracking the user.
- **Implementation:** Add `latitude` and `longitude` to the `Transaction` model. Use local location APIs to tag an expense's location upon creation. Create a `MapScreen` (using a lightweight offline mapping solution or an abstract coordinate grid) to show spending hotspots.

### Phase 36: Quick Settings Tiles & Dynamic Shortcuts
Push OS integration to the absolute limit.
- **Implementation:** Build an Android `TileService` (Quick Settings Tile) that opens a transparent "Quick Add" dialog over any app. For Flutter, expand the `quick_actions` to include dynamic shortcuts based on the user's most frequent categories.

### Phase 38: Custom App Icon Switcher
Give users premium customization options.
- **Implementation:** Build a feature allowing users to swap the app's home screen icon (e.g., Dark Mode Logo, Gold Premium Logo, Minimalist Logo). Use `<activity-alias>` in Android's `AndroidManifest.xml` and `flutter_dynamic_icon`.

### Phase 39: On-Device Model Retraining (Federated Learning Prep)
Make the auto-categorization from Phase 16 smarter over time.
- **Implementation:** Build a background worker that runs once a week to update the local heuristics/weights of the Category Suggester based on the user's manual corrections.

### Phase 41: Final Profiling & Memory Leak Hunting
Guarantee stability under the 4GB RAM constraint.
- **Implementation:** Provide the exact setup code to integrate `LeakCanary` (Android) in the `debug` build variant ONLY. For Flutter, provide the specific `DevTools` CLI commands and memory profiling assertions to add to our integration tests.

### Phase 44: Foldable & Tablet Adaptive Layouts
Scale the UI for large screens without just stretching elements.
- **Implementation:** Implement Window Size Classes (Compact, Medium, Expanded). On Expanded screens (tablets/foldables), refactor the `/home` route to a Master-Detail layout. The left pane shows the Dashboard overview, and the right pane shows the Transaction List or Chart side-by-side.

### Phase 51: Dynamic Feature Modules (DFM) & Deferred Loading
Shrink the initial install size for the Google Play Store.
- **Implementation:** For Android, move the heavy PDF Generation (Phase 33) and ML Kit OCR (Phase 23) into an On-Demand Dynamic Feature Module. For Flutter, implement deferred imports (`import 'package:...' deferred as ...`) for these heavy screens.
