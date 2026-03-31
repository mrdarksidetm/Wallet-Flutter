# 📜 Wallet-Flutter CHANGELOG

All notable changes to the **Project Wallet** will be documented in this file. 🚀

---

## [1.3.0] - 2026-03-31 💎

### ✨ Added
- **🔄 Account Reordering**: Integrated `int order` into the `Account` model with a new **Reorder Accounts** bottom sheet using `ReorderableListView`.
- **🏦 Polished Account Editing**: Replaced traditional page navigation with high-performance, interactive **Bottom Sheets** featuring:
  - Editorial-style Tabs (Card, Cash, Savings). 🗂️
  - Dynamic Color & Icon selection. 🎨
- **⏺️ Smooth Page Indicators**: Integrated `smooth_page_indicator` for the account balance hero carousel. 🎠
- **⏳ Loading States**: Added specialized loading indicators for transaction initialization to prevent link-loading races.

### 🛠️ Changed
- **🏛️ Architecture Refinement**: Migrated account management logic from separate pages to modular bottom sheet components for better UX consistency.
- **🏗️ Database Schema**: Updated `Account` collection to support manual display ordering.
- **🧩 Link Resilience**: Explicitly awaiting `IsarLink` loads in edit screens to ensure zero data loss. 🔒

### ✅ Fixed
- **🚿 Static Analysis Sweep**: Achieved a 100% clean `flutter analyze` across the entire project (Zero errors, warnings, or infos). 🧹
- **📝 Edit Persistence**: Fixed critical bug where editing a transaction would lose its linked Account or Category.
- **🔄 Category Reset Bug**: Fixed logic that reset custom icons/colors when re-selecting the same category.
- **🏷️ Provider Rename**: Resolved `peopleStreamProvider` undefined error by correctly mapping to `personsStreamProvider`.
- **📏 UI Linting**: Added missing curly braces to flow control structures in the People feature.
- **🗑️ Cleanup**: Removed unused variables and imports across Home, People, and Settings modules.

---

## [1.2.8] - 2026-03-30 🎨

### Added
- **🌅 Modern Onboarding**: Redesigned the onboarding flow with an animated gradient background.
- **✨ Dynamic SVG Shadow**: Premium blurred shadow effect for the app logo.
- **🛡️ Premium Dashboard Header**: Added "PREMIUM" badge and haptic-enabled settings.
- **👨‍💻 Developer Section**: New "About" section featuring the developer's profile and GitHub links.

### Changed
- **💵 Strict Currency**: Mandated currency selection during onboarding; removed hardcoded fallbacks.
- **⛸️ Global Fluidity**: Enforced `BouncingScrollPhysics()` across all views.
- **🏢 Design Upgrade**: Upgraded `TotalBalanceCard` with M3 expressive geometry.

### Fixed
- **🧹 Static Analysis**: 100% clean analysis passes.
- **⌨️ Input UX**: Modernized all `TextFormFields` with high border radii.

---

## [1.2.7] - 2026-03-29 📦

### Added
- **📑 Account Details**: Specific history view for individual wallets.
- **👤 User Info**: Profile view accessible from header.
- **✂️ Image Cropping**: Integrated `image_cropper` for 1:1 user photos.
- **🌈 Dynamic Schemes**: Full support for all 9 Material 3 color variants.
- **🛠️ Lifecycle Actions**: Swipe-to-delete for Goals and Loans.

### Fixed
- **🔥 Persistence Crash**: Debounced `SharedPreferences` saves in Personalization.
- **🧩 Budget Reactivity**: Fixed 0% budget sync bug in `TransactionService`.
- **🚦 Routing**: Resolved `GoException` for legacy paths.

---
*Follow our progress on GitHub!* 🐙
