# Project Wallet Structure (Flutter)

## Folder Tree

D:\Ideas\Antigravity\Wallet-Flutter\
├───android\ (MainActivity with FlutterFragmentActivity, VIBRATE permission)
├───assets\
│   ├───fonts\ (GoogleSansFlex, AppleColorEmoji)
│   ├───images\
│   └───icon\
├───lib\
│   ├───main.dart (DynamicColorBuilder with Variant support)
│   ├───app\
│   │   └───router.dart (GoRouter, AppShell with Lock Logic)
│   ├───core\
│   │   ├───database\
│   │   │   ├───models\ (Account, Category, Transaction, Budget, etc.)
│   │   │   ├───repositories\ (Isar CRUD)
│   │   │   └───services\ (Backup, CSV, Statistics, Recurring, Seed)
│   │   ├───services\
│   │   │   ├───haptic_service.dart (Static API with Toggle support)
│   │   │   ├───greeting_service.dart
│   │   │   └───exchange_rate_service.dart
│   │   ├───theme\
│   │   │   ├───colors.dart (Atelier & Dark Teal/Sage Tokens)
│   │   │   ├───theme.dart (M3 Dynamic + Variable Font Axes)
│   │   │   ├───typography.dart (Google Sans Flex configuration)
│   │   │   └───personalization_provider.dart (Stateful UI Controller)
│   │   └───widgets\ (Atelier Buttons, IconPicker, AnimatedCounter, TransactionListTile)
│   ├───features\
│   │   ├───home\
│   │   │   ├───pages\ (HomePage, BudgetsPage, BillSplitterPage, SearchPage)
│   │   │   └───widgets\ (TotalBalanceCard, OverviewCard, HomeHeader)
│   │   ├───accounts\
│   │   │   └───pages\ (AccountsPage, AddEditAccountPage with Color Picker)
│   │   ├───transactions\
│   │   │   └───pages\ (AddTransactionPage)
│   │   ├───reports\
│   │   │   └───pages\ (ReportsPage, CategoryDetailsPage)
│   │   ├───auth\
│   │   │   ├───pages\ (OnboardingPage, UnlockPage, UserInfoPage)
│   │   │   └───providers\ (AuthNotifier with Auto-Authenticate)
│   │   └───settings\
│   │       └───pages\ (SettingsPage, PersonalizationPage, PrivacyPolicyPage, FeedbackPage, AboutPage)
│   └───data\
└───test\

## Architecture Key Patterns
- **MVVM + Riverpod**: Using new `Notifier` and `AsyncValue` for reactive state.
- **Clean Database Layer**: Isar models separated from UI. Repositories handle Isar query logic.
- **Service Layer**: Business logic (CSV, Backup, Stats) encapsulated in dedicated services.
- **Atelier Design System**: Centralized `personalizationProvider` controls typography (Weight, Width, SOFT, opsz axes) and geometry (roundness) globally.
- **Dynamic Color (M3)**: Supports 9 variants (Monochrome, Tonal spot, etc.) and Material You harmonization.
- **Security**: Local authentication with PIN fallback and auto-trigger on app start.
