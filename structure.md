# 🏗️ Project Structure & Architecture

A bird's eye view of the **Project Wallet** (Flutter) technical blueprint. 🗺️🏦

---

## 📂 Directory Map

```text
lib/
├── 📱 app/                # Root configuration (Router, Theme, AppShell)
├── 🏛️ core/               # Shared logic & infrastructure
│   ├── 💾 database/       # Isar Models, Repositories, Services & Providers
│   ├── 🛠️ providers/      # Global state providers (FAB, Navigation)
│   ├── 📡 services/       # Platform services (Haptics, Updates, Backup)
│   ├── 🎨 theme/          # Material 3 Personalization logic
│   └── 🧩 widgets/        # Reusable Atomic & Molecular UI components
├── 🚀 features/           # Domain-specific modules (MVVM pattern)
│   ├── 🏦 accounts/       # Wallet & Account management
│   ├── 📊 reports/        # Analytics & Canvas-based charts
│   ├── 💸 transactions/   # CRUD for income/expense/transfers
│   ├── 🎯 goals/          # Savings targets
│   ├── ⚖️ loans/          # Debt & lending tracking
│   ├── 🔄 recurring/      # Subscriptions & bills
│   ├── 👥 people/         # Contact management for transactions
│   ├── 🏡 home/           # Dashboard & overview grid
│   └── ⚙️ settings/       # App preferences & profile
└── 🏁 main.dart           # Application entry point
```

---

## 🏛️ Architectural Principles

### **1. MVVM + Service Layer** 🏗️
- **Model**: Isar collections representing the data schema.
- **View**: Flutter Pages/Widgets reflecting the state.
- **ViewModel**: Managed via **Riverpod Providers**.
- **Service**: Centralized business logic (e.g., `TransactionService` handles balance math).

### **2. Reactive Data Flow** ⚡
- Data flows from **Isar Streams** ➡️ **Riverpod StreamProviders** ➡️ **UI**.
- UI automatically rebuilds only when specific watched data changes.

### **3. Material 3 Expressive Design** 🎨
- **Geometry**: High border radii (24-32px).
- **Motion**: `flutter_animate` for smooth transitions.
- **Color**: Monet-based dynamic schemes.

---

## 🛠️ Key Technologies

- **💾 Persistence**: [Isar](https://isar.dev) (Local-first NoSQL).
- **⚡ State**: [Riverpod 2.0](https://riverpod.dev).
- **🚦 Routing**: [GoRouter](https://pub.dev/packages/go_router).
- **📏 UI**: [Material 3](https://m3.material.io).
- **🎨 Icons**: [Material Symbols](https://fonts.google.com/icons).

---
*Architecture maintained for Scalability & Performance.* 🚀💼
