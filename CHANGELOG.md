# Changelog

All notable changes to this project will be documented in this file.

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
