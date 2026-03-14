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

> ⬜ = Not yet implemented &nbsp; ✅ = Implemented

---

## 7. Sync Workflow

1. Make changes in the **primary** codebase (Compose unless stated otherwise).
2. Update this `SPEC.md` with any new/changed features.
3. Translate the logic to the other codebase using this spec as reference.
4. Update the Feature Parity Checklist above.
5. Commit both repos.
