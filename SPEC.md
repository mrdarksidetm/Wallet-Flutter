# 📜 Wallet App Design Specification (SPEC.md)

This is the **Single Source of Truth** for the Project Wallet ecosystem. 🏦

---

## 💎 1. App Identity

*   **Project Name**: Project Wallet (Paisa Clone) 🏦
*   **Version**: 2.0.1 ("The Expressive Motion") 💎
*   **Target SDK**: Android 14+ (API 34) 🤖
*   **Design Language**: Material 3 Expressive (Editorial Style) 🎨
*   **Core Mandate**: Offline-first, Privacy-centric, High-Performance (60-120 FPS). ⚡

---

## 📊 2. Data Model (Isar Collections)

### **🏦 2.1 Account**
- **Id**: autoIncrement 🔢
- **Name**: String (Index) 📝
- **Balance**: double (Initial + Current) 💵
- **Type**: enum (Cash, Bank, CreditCard, Investment, etc.) 💳
- **Icon**: String (Material Symbol name) 🎭
- **Color**: String (Hex code) 🎨
- **Order**: int (Display sequence) 🔢
- **Lifecycle**: createdAt, updatedAt, isArchived, isDeleted ⏳

### **💸 2.2 Transaction**
- **Id**: autoIncrement 🔢
- **Amount**: double 💵
- **Type**: enum (Income, Expense, Transfer) 🔄
- **Note**: String? (Optional) 📝
- **Date**: DateTime 📅
- **Links**: Account, Category, Person, TransferAccount 🔗

### **💹 2.3 Budget**
- **Id**: autoIncrement 🔢
- **Amount**: double (Limit) 💵
- **Category**: Link (The group it applies to) 📂
- **Cycle**: enum (Daily, Weekly, Monthly) 🔄

### **🎯 2.4 Goal**
- **TargetAmount**: double 🥅
- **CurrentAmount**: double 💰
- **Deadline**: DateTime? 📅
- **IsCompleted**: bool ✅

### **🏷️ 2.5 Category**
- **Name**: String (e.g., Food, Salary) 📂
- **Icon**: String 🎭
- **Color**: String 🎨
- **Type**: enum (Income, Expense) 🔄

---

## 🎨 3. Design System (Material 3)

### **📐 Layout Geometry**
- **Border Radius**: 32px (Bottom Sheets), 24px (Large Cards), 16px (Dialogs). 📏
- **Padding**: 24px (Standard Outer Margin), 16px (Internal Spacing). 📏

### **🎭 Typography & Icons**
- **Font**: `Google Sans Flex` (Variable weight). ✒️
- **Icons**: `Material Symbols` (Weight: 400, Fill: 0-1). 🎭
- **Scrolling**: `BouncingScrollPhysics()` across all views. ⛸️

---

## ✅ 4. Feature Parity Checklist

### **Core**
- [x] Multi-account support (Isar links). ✅
- [x] Transaction CRUD with Account balance updates. ✅
- [x] Category-based grouping and filtering. ✅
- [x] **New**: Account display reordering. ✅

### **Home & Dashboard**
- [x] Total Balance Hero Card (Carousel). ✅
- [x] Income/Expense breakdown (Monthly stats). ✅
- [x] Interactive Overview Grid. ✅
- [x] **New**: Smooth page indicators. ✅

### **Advanced Features**
- [x] Bill Splitter with local Person links. ✅
- [x] Financial Goals tracking. ✅
- [x] Monthly Budgets with real-time reactive streams. ✅
- [x] Recurring transactions & subscriptions. ✅
- [x] In-app GitHub Updater. ✅

---

## 🛠️ 5. Debug History & Known Issues

### **Current Build Status (v2.0.1)**
- **Status**: 🟢 **Healthy**
- **Analysis**: `flutter analyze` report: **No issues found**. 🧹
- **Generation**: Isar and Riverpod generated files are up-to-date. ⚙️

### **Recent Fixes**
- **2026-03-31**: Resolved data loss during transaction edit. 📝
- **2026-03-31**: Implemented `personsStreamProvider` fix. 🏷️
- **2026-03-31**: Added manual account reordering support. 🔄

---
*SPEC maintained by the Wallet Core Team.* 💼

