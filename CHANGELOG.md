# Changelog

All notable changes to this project will be documented in this file.

## [1.2.8] - 2026-03-30

### Added
- **Modern Onboarding**: Redesigned the onboarding flow with an animated gradient background and a clear visual hierarchy.
- **Dynamic SVG Shadow**: Implemented a blurred SVG stacking technique for the app logo to create a premium, dynamic shadow effect.
- **Premium Dashboard Header**: Optimized the home header with a "PREMIUM" badge, haptic-enabled settings, and dynamic user profile avatars.
- **Developer-Focused About Page**: Replaced the generic about page with a dedicated section for the developer (Abhijeet Yadav), featuring a personal photo and direct GitHub links.

### Changed
- **Strict Dynamic Currency**: Removed all hardcoded currency fallback strings. The app now mandates a currency selection during onboarding and uses it globally via `currencyProvider`.
- **Global Fluidity**: Enforced `BouncingScrollPhysics()` across all scrollable views for a more tactile, premium feel.
- **Improved Hierarchy**: Upgraded `TotalBalanceCard` and `OverviewCard` with Material 3 expressive geometry and animated counters.

### Fixed
- **Static Analysis**: Resolved all remaining warnings and info messages to ensure a 100% clean `flutter analyze` across 5 consecutive passes.
- **Input UX**: Switched to modern, filled `TextFormFields` with high border radii for better touch targets and visual consistency.

## [1.2.7] - 2026-03-29

### Added
- **Account Details**: New page for viewing specific account balances and transaction history.
- **User Info Screen**: Dedicated profile view accessible from the Home header.
- **Onboarding Cropper**: Integrated `image_cropper` for 1:1 profile photo square cropping.
- **Dynamic Color Variants**: Implemented all 9 M3 Dynamic Scheme Variants (Fruit Salad, Vibrant, etc.).
- **Entity Lifecycle Actions**: Added swipe-to-complete/delete for Goals, Loans, and Recurring transactions.
- **Material 3 Redesign**: Home header now features an official logo and dynamic user avatar.

### Changed
- **Optimization**: Switched to Riverpod `.select()` for surgically efficient UI rebuilds.
- **DB Performance**: Migrated account history to database-level Isar indexed queries.
- **About Section**: Updated text to support modern Android Community standards.
- **Branding**: Replaced all hardcoded identity ("Abhi") and currency (₹) with dynamic logic.

### Fixed
- **Stability**: Resolved high-frequency write crash in Personalization by debouncing SharedPreferences saves.
- **Personalization Crash**: Fixed the "roundness" axis crash by consolidating state updates.
- **Budget Reactivity**: Fixed 0% budget bug by syncing `accountId` and `categoryId` in `TransactionService`.
- **Routing**: Resolved `GoException` for `/terms_of_use` and established proper navigation hierarchies.
- **Static Analysis**: Achieved 100% "No issues found" status across the entire repository.

### Removed
- Redundant in-memory filtering for transaction history.
- Hardcoded INR symbols and legacy placeholder strings.
