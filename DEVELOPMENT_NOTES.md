# Development Notes & Error Log (Wallet-Flutter)

This file tracks recurring errors, architectural "gotchas," and lessons learned during the porting of logic from the original Paisa app. **Reference this file before implementing new features or debugging crashes.**

---

## 1. Database & Persistence (Isar)

### **Critical: Avoid `late` in Data Models**
- **Error**: `LateInitializationError: Field '...' has not been initialized`.
- **Context**: Occurs when Isar tries to save or read a record where a `late` field hasn't been explicitly assigned. This is highly common during initial seeding or when importing data (CSV/Restore).
- **Mandate**: **NEVER** use the `late` keyword for `@collection` fields in Isar models. Always provide a safe default value.
  - **Bad**: `late String description;`
  - **Good**: `String description = '';`
  - **Bad**: `late DateTime createdAt;`
  - **Good**: `DateTime createdAt = DateTime.now();`

### **Schema Synchronization**
- **Issue**: Strange runtime behavior, missing fields, or crashes after modifying models.
- **Mandate**: After any change to files in `lib/core/database/models/`, you MUST run:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

---

## 2. UI & Design (Material 3)

### **Dynamic Content over Hardcoded Strings**
- **Issue**: Hardcoded UI text (e.g., "Good late night") that doesn't reflect real-world state or time.
- **Mandate**: Use dedicated services (like `GreetingService`) and Riverpod providers for all environmental or time-based UI strings.

### **Linting & Performance (Const Constructors)**
- **Issue**: Performance warnings (`prefer_const_constructors`) or `unnecessary_const` errors.
- **Common Gotchas**:
  - **Charts**: `AxisTitles` often cannot be `const` if they contain dynamic `SideTitles` builders that reference `Theme` or `stats`.
  - **Slivers**: `SliverToBoxAdapter` should have `const` applied to its **child** (e.g., `SliverToBoxAdapter(child: const SizedBox(...))`) rather than the adapter itself to maximize compiler optimization.

---

## 3. Porting Logic from Paisa

### **Performance Audit**
- **Mandate**: Before declaring a port "Complete," run the **Performance Audit** tool (Settings -> Data Management).
- **Target**: Ensure 10,000 transactions can be inserted and queried without UI jank or database timeouts. This verifies that your Isar `@Index()` annotations are functioning correctly.

### **Haptic Feedback**
- **Mandate**: Every primary user action (Save, Delete, Select) must trigger `HapticService`. Reference the `paisa-app` UX, but ensure we use our centralized service for consistency.
