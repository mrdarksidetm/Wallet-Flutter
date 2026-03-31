# 🛠️ Wallet-Flutter DEVELOPMENT NOTES

Internal technical documentation for maintaining the **Project Wallet** ecosystem. 🏗️

---

## 💾 1. Database & Persistence (Isar)

### **🚫 Critical: Avoid `late` in Data Models**
- **Error**: `LateInitializationError: Field '...' has not been initialized`. 🧨
- **Context**: Occurs when Isar tries to save or read a record where a `late` field hasn't been explicitly assigned (common during initial seeding or CSV/Restore).
- **Mandate**: **NEVER** use the `late` keyword for `@collection` fields. Always provide safe default values.
  - **❌ Bad**: `late String description;`
  - **✅ Good**: `String description = '';`
  - **❌ Bad**: `late DateTime createdAt;`
  - **✅ Good**: `DateTime createdAt = DateTime.now();`

### **🔄 Schema Synchronization**
- **Issue**: Strange runtime behavior, missing fields, or crashes after model changes. 🔧
- **Mandate**: After modifying anything in `lib/core/database/models/`, you MUST run:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

---

## 🎨 2. UI & Design Standards (Material 3)

### **📐 Expressive Geometry**
- **Radius**: Standardize on **24px - 32px** for large cards and **16px** for small containers. 📏
- **Elevation**: Favor **Tonal Elevation** over heavy shadows. Use `SurfaceContainerLow` for background layering. 🌈
- **Scrolling**: Mandate `BouncingScrollPhysics()` for all scrollable views to maintain tactile fluidity. ⛸️

### **🔤 Typography & Symbols**
- **Primary Font**: `Google Sans Flex` (Variable). ✒️
- **Icons**: Use `material_symbols_icons` (Variable Symbols). Always check the latest [Variable Symbols](https://fonts.google.com/icons) for optimal weight/fill. 🎭
- **Emoji Support**: Primary support via `AppleColorEmoji` font to ensure cross-platform visual parity. 🍎

---

## 🏗️ 3. Architecture & State (Riverpod)

### **⚡ Efficient Rebuilds**
- **Strategy**: Always use `ref.watch(provider.select((s) => s.value))` to surgically target only necessary state slices. 🎯
- **Context**: Prevents entire page rebuilds when only a single property (like `userName`) changes.

### **📦 Service Layer**
- **Mandate**: Business logic belongs in **Services**, not ViewModels or Pages. 🏦
- **Providers**: Use `Provider` for stateless services and `NotifierProvider` for stateful logic (like Personalization).

---

## 🧩 4. Feature Implementation Protocol

1.  **🔍 Research**: Check `SPEC.md` and `paisa-reference` for logic origins.
2.  **🏗️ Data Model**: Update Isar entities and run `build_runner`.
3.  **🏢 UI Scaffold**: Implement using M3 components (Expressive style).
4.  **🧪 Verification**:
    - `flutter analyze` 🧹
    - Check for data persistence on app restart. 🔒
    - Verify haptic feedback (only on saves/primary actions). 📳

---
*Maintained by the Wallet Development Team.* 💼
