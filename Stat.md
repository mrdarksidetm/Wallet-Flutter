# 📊 Project Wallet Statistics (Flutter)

Live tracking of the **Project Wallet** development lifecycle. 📈🏦

---

## 💎 Version Control
- **Current Version**: `1.4.0` 💎
- **Codename**: "The Expressive Motion" ⛸️
- **Build Date**: April 3, 2026 📅
- **Flutter SDK**: `>=3.5.0` 💙
- **Primary Design**: Material 3 Expressive (Editorial Style) ✨

---

## 🚀 Implementation Status (v1.5.0 Update)

### **💾 1. Database & Core (100%)**
- [x] Isar Database implementation. 📁
- [x] **UPDATED**: Loan model and UI now correctly handle dynamic currency symbols. 💱

### **📱 2. UI & Navigation (100%)**
- [x] **NEW**: Conditional header icons (Hidden on Reports). 🙈
- [x] **NEW**: Home screen Activity Heatmap and Expense/Income Trends line chart. 📊
- [x] **IMPROVED**: Loan Page layout with multi-line date pickers. 📅
- [x] **IMPROVED**: Reports page overhauled with M3 components, date-range filtering, and horizontal month selection. 📈

### **✨ 3. Features (100%)**
- [x] **NEW**: Small Window / Split-screen support for Android (resizeableActivity). 📱
- [x] **FIXED**: Hardcoded currency symbols replaced with dynamic `personalizationProvider` values. 💰
- [x] **FIXED**: Total Balance card info symbol now toggles visibility on click. ℹ️
- [x] **FIXED**: Reports page dead screen replaced with a functional, reactive dashboard. ✨

---

## 📈 Metrics

- **Total Lines of Code**: ~13,800 📝
- **Total Files**: 82 📂
- **Performance**: 120 FPS target (Maintained) ⚡
- **APK Size**: ~20.5MB 📦

---

## 🛠️ Recent Fixes (v1.4.0 Update)

- **📝 Loan Management**: Resolved the "disappearing due date" bug by ensuring `dueDate` is correctly mapped in the `AddEditLoanPage`.
- **🖇️ Person Connectivity**: Transactions now reliably link to people via `personId` syncing, fixing the empty activity history bug.
- **🍕 Bill Splitting**: Transformed the Bill Splitter from a calculator into a functional tool by adding Isar-backed loan creation.
- **🎨 Visual Fluidity**: Introduced `Hero` transitions for transaction entries to create a more "tactile" and "editorial" feel when editing data.
- **🔍 Smart Discovery**: Upgraded the icon picker with a keyword engine (e.g., searching "Car" finds transport icons) to improve UX speed.

---
*Built with ❤️ for the Flutter Community.* 💼✨
