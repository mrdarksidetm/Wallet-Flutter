# SPEC.md — Wallet App Design Specification
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# This file is IDENTICAL in both the Compose and Flutter repos.
# It is the single source of truth for feature parity between both versions.
# When you update a feature, update THIS SPEC first, then implement in both codebases.
#
# Last synced: 2026-03-21 (Post-Expansion Build)

## 1. App Identity

| Field          | Value                                   |
|----------------|------------------------------------------|
| Name           | Wallet                                  |
| Package (Android) | `com.mrdarksidetm.wallet`            |
| Design System  | Material 3 (BOM 2024.10+) + Stitch DNA  |
| Iconography    | Adaptive Icons (Android)                |
| Architecture   | MVVM + Unidirectional Data Flow         |
| Network        | **Offline-first. Zero network calls.**  |

---

## 2. Data Model

### 2.3 Budget
| Field      | Type     | Kotlin (Room)     | Notes                           |
|------------|----------|-------------------|---------------------------------|
| id         | String   | `String` (UUID)   | Primary key                     |
| amount     | Decimal  | `Double`          | Limit amount                    |
| category   | String   | `String`          | Budgeted category               |
| period     | String   | `String`          | Weekly, Monthly, Yearly         |

### 2.4 Goal (New)
| Field        | Type     | Kotlin (Room)     | Notes                           |
|--------------|----------|-------------------|---------------------------------|
| id           | String   | `String` (UUID)   | Primary key                     |
| name         | String   | `String`          | Goal name (e.g. "New Car")      |
| targetAmount | Decimal  | `Double`          | How much to save                |
| savedAmount  | Decimal  | `Double`          | Current progress                |
| deadline     | Datetime | `Long`            | Target date                     |

### 2.5 Recurring Transaction (New)
| Field          | Type     | Kotlin (Room)     | Notes                           |
|----------------|----------|-------------------|---------------------------------|
| id             | String   | `String` (UUID)   | Primary key                     |
| amount         | Decimal  | `Double`          | Amount                          |
| frequency      | String   | `String`          | Daily, Weekly, Monthly          |
| nextOccurrence | Datetime | `Long`            | When to process next            |

### 2.6 Label (New)
| Field | Type   | Kotlin (Room)     | Notes                    |
|-------|--------|-------------------|--------------------------|
| id    | String | `String` (UUID)   | Primary key              |
| name  | String | `String`          | Label name               |
| color | String | `String` (Hex)    | UI display color         |

---

## 6. Feature Parity Checklist

| Feature                       | Compose | Flutter | Notes                         |
|-------------------------------|---------|---------|-------------------------------|
| Room/Isar database            | ✅      | ✅      | Version 7 (Room)              |
| Budgets                       | ✅      | ✅      | Full CRUD implemented         |
| Goals (Savings)               | ✅      | ✅      | Progress tracking & UI        |
| Recurring Transactions        | ✅      | ✅      | Entity & UI built             |
| Labels / Tags                 | ✅      | ✅      | Basic system added            |
| Categories Management         | ✅      | ✅      | Full CRUD UI implemented      |
| Donut Chart (Canvas)          | ✅      | ✅      | Native implementation         |
| Loans (Lent/Borrowed/People)  | ✅      | ✅      | Synced to Flutter             |
| Dark/Light Mode Consistency   | ✅      | ✅      | Stitch custom palette         |

---

## 10. Debug History & Known Issues

### 2026-03-21: Core Feature Expansion
- **Database:** Bumped Room schema to Version 7. Integrated `GoalEntity`, `RecurringTransactionEntity`, and `LabelEntity`.
- **ViewModel:** Massive refactor of `WalletViewModel` to support 9 different DAOs with clean Reactive Streams (StateFlow).
- **UI:** Built `GoalsScreen.kt`, `RecurringScreen.kt`, `LabelsScreen.kt`, and `CategoriesScreen.kt`.
- **Navigation:** Fully wired all 15 home grid items to their respective (new or placeholder) screens in `MainAppScreen.kt`.
- **Analytics:** Verified Native Canvas Donut chart performance with `animateFloatAsState`.

---
