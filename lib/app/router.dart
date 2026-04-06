import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../features/home/pages/home_page.dart';
import '../features/accounts/pages/accounts_page.dart';
import '../features/transactions/pages/add_transaction_page.dart';
import '../features/transactions/pages/all_transactions_page.dart';
import '../features/reports/pages/reports_page.dart';
import '../features/auth/pages/unlock_page.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/settings/pages/settings_page.dart';
import '../features/home/pages/budgets_page.dart';
import '../features/home/pages/bill_splitter_page.dart';
import '../features/loans/pages/loans_page.dart';
import '../features/loans/pages/add_edit_loan_page.dart';
import '../features/accounts/pages/add_edit_account_page.dart';
import '../features/home/pages/recurring_page.dart';
import '../features/home/pages/add_edit_recurring_page.dart';
import '../features/settings/pages/categories_page.dart';
import '../features/settings/pages/add_edit_category_page.dart';
import '../features/people/pages/people_page.dart';
import '../features/people/pages/person_details_page.dart';
import '../features/settings/pages/currency_selection_page.dart';
import '../features/settings/pages/edit_profile_page.dart';
import '../features/reports/pages/category_details_page.dart';
import '../features/home/pages/goals_page.dart';
import '../features/home/pages/add_edit_goal_page.dart';
import '../features/home/pages/search_page.dart';
import '../features/settings/pages/personalization_page.dart';
import '../features/settings/pages/privacy_policy_page.dart';
import '../features/settings/pages/terms_of_use_page.dart';
import '../features/settings/pages/feedback_page.dart';
import '../features/settings/pages/about_page.dart';
import '../features/settings/pages/logcat_page.dart';
import '../features/accounts/pages/account_details_page.dart';
import '../features/home/pages/activity_heatmap_page.dart';

import '../core/database/models/transaction_model.dart';
import '../core/database/models/account.dart';
import '../core/database/models/category.dart';
import '../core/database/models/auxiliary_models.dart';
import '../core/theme/personalization_provider.dart';
import '../core/providers/fab_action_provider.dart';

import '../features/auth/pages/onboarding_page.dart';
import '../features/auth/pages/user_info_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final isOnboardingComplete = ref.watch(
    personalizationProvider.select((p) => p.isOnboardingComplete),
  );

  return GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    redirect: (context, state) {
      final isOnboarding = state.uri.path == '/onboarding';
      if (!isOnboardingComplete && !isOnboarding) {
        return '/onboarding';
      }
      if (isOnboardingComplete && isOnboarding) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          _shellRoute('/', const HomePage()),
          _shellRoute('/accounts', const AccountsPage()),
          _shellRoute('/reports', const ReportsPage()),
          _shellRoute('/search', const SearchPage(),
              type: SharedAxisTransitionType.scaled),
          _shellRoute('/loans', const LoansPage(),
              type: SharedAxisTransitionType.scaled),
          _shellRoute('/budgets', const BudgetsPage(),
              type: SharedAxisTransitionType.scaled),
          _shellRoute('/bill_splitter', const BillSplitterPage(),
              type: SharedAxisTransitionType.scaled),
          _shellRoute('/recurring', const RecurringPage(),
              type: SharedAxisTransitionType.scaled),
          _shellRoute('/people', const PeoplePage(),
              type: SharedAxisTransitionType.scaled),
          _shellRoute('/goals', const GoalsPage(),
              type: SharedAxisTransitionType.scaled),
          _shellRoute('/activity_heatmap', const ActivityHeatmapPage(),
              type: SharedAxisTransitionType.scaled),
          GoRoute(
            path: '/category_details',
            pageBuilder: (context, state) => _buildSharedAxisTransition(
              context,
              state,
              CategoryDetailsPage(category: state.extra as Category),
              SharedAxisTransitionType.scaled,
            ),
          ),
        ],
      ),
      _rootRoute('/settings', (_) => const SettingsPage()),
      _rootRoute('/theme_selection', (_) => const PersonalizationPage()),
      _rootRoute('/personalization', (_) => const PersonalizationPage()),
      _rootRoute('/categories', (_) => const CategoriesPage()),
      _rootRoute('/currency_selection', (_) => const CurrencySelectionPage()),
      _rootRoute('/privacy_policy', (_) => const PrivacyPolicyPage()),
      _rootRoute('/terms_of_use', (_) => const TermsOfUsePage()),
      _rootRoute('/feedback', (_) => const FeedbackPage()),
      _rootRoute('/about', (_) => const AboutPage()),
      _rootRoute('/logcat', (_) => const LogcatPage()),
      _rootRoute('/user_info', (_) => const UserInfoPage()),
      _rootRoute('/edit_profile', (_) => const EditProfilePage()),
      _rootRoute('/person_details',
          (state) => PersonDetailsPage(person: state.extra as Person)),
      _rootRoute('/all_transactions', (_) => const AllTransactionsPage()),
      _rootRoute('/account_details',
          (state) => AccountDetailsPage(account: state.extra as Account)),
      _rootRoute(
          '/add_transaction',
          (state) => AddTransactionPage(
              transaction: state.extra as TransactionModel?)),
      _rootRoute('/add_account',
          (state) => AddEditAccountPage(account: state.extra as Account?)),
      _rootRoute('/add_loan', (_) => const AddEditLoanPage()),
      _rootRoute(
          '/add_recurring',
          (state) =>
              AddEditRecurringPage(recurring: state.extra as Recurring?)),
      _rootRoute('/add_category',
          (state) => AddEditCategoryPage(category: state.extra as Category?)),
      _rootRoute(
          '/add_goal', (state) => AddEditGoalPage(goal: state.extra as Goal?)),
    ],
  );
});

GoRoute _shellRoute(String path, Widget child,
    {SharedAxisTransitionType type = SharedAxisTransitionType.horizontal}) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) =>
        _buildSharedAxisTransition(context, state, child, type),
  );
}

GoRoute _rootRoute(String path, Widget Function(GoRouterState) builder) {
  return GoRoute(
    path: path,
    parentNavigatorKey: _rootNavigatorKey,
    builder: (context, state) => builder(state),
  );
}

Page _buildSharedAxisTransition(BuildContext context, GoRouterState state,
    Widget child, SharedAxisTransitionType type) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 600),
    reverseTransitionDuration: const Duration(milliseconds: 450),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
          reverseCurve: Curves.easeInOutCubic,
        ),
        secondaryAnimation: CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInOutCubic,
          reverseCurve: Curves.easeInOutCubic,
        ),
        transitionType: type,
        child: child,
      );
    },
  );
}

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    if (authState.isLocked) return const UnlockPage();

    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNavBar(location: location),
      floatingActionButton: _FAB(location: location),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final String location;
  const _BottomNavBar({required this.location});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _getIndex(location),
      onDestinationSelected: (index) => _navigate(context, index),
      destinations: const [
        _NavDest(icon: Symbols.home, label: 'Home'),
        _NavDest(icon: Symbols.credit_card, label: 'Accounts'),
        _NavDest(icon: Symbols.pie_chart, label: 'Reports'),
        _NavDest(icon: Symbols.search, label: 'Search'),
      ],
    );
  }

  int _getIndex(String loc) {
    if (loc == '/') return 0;
    if (loc == '/accounts') return 1;
    if (loc == '/reports') return 2;
    if (loc == '/search') return 3;
    return 0;
  }

  void _navigate(BuildContext context, int index) {
    final routes = ['/', '/accounts', '/reports', '/search'];
    context.go(routes[index]);
  }
}

class _NavDest extends StatelessWidget {
  final IconData icon;
  final String label;
  const _NavDest({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final fillIcons = ref.watch(personalizationProvider).fillIcons;
        return NavigationDestination(
          icon: Icon(icon, fill: fillIcons ? 1.0 : 0.0),
          selectedIcon: Icon(icon, fill: 1.0),
          label: label,
        );
      },
    );
  }
}

class _FAB extends ConsumerWidget {
  final String location;
  const _FAB({required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_shouldHideFAB(location)) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final fillIcons = ref.watch(personalizationProvider).fillIcons;

    return FloatingActionButton(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      onPressed: () => _handleFABPressed(context, ref, location),
      child: Icon(
        _getFABIcon(location),
        fill: fillIcons ? 1.0 : 0.0,
      ),
    );
  }

  bool _shouldHideFAB(String loc) {
    final hiddenRoutes = [
      '/search',
      '/settings',
      '/personalization',
      '/categories',
      '/theme_selection',
      '/currency_selection',
      '/privacy_policy',
      '/terms_of_use',
      '/feedback',
      '/about',
      '/category_details',
      '/add_transaction',
      '/add_account',
      '/add_goal',
      '/add_loan',
      '/add_recurring',
      '/add_category',
      '/budgets',
      '/bill_splitter',
    ];
    // Don't hide for /reports anymore
    return hiddenRoutes
        .any((route) => loc == route || loc.startsWith('$route/'));
  }

  IconData _getFABIcon(String loc) {
    switch (loc) {
      case '/':
        return Symbols.add;
      case '/accounts':
        return Symbols.add_card;
      case '/reports':
        return Symbols.filter_alt;
      case '/categories':
        return Symbols.category;
      case '/people':
        return Symbols.person_add;
      case '/goals':
        return Symbols.flag;
      case '/loans':
        return Symbols.front_loader;
      case '/recurring':
        return Symbols.event_repeat;
      default:
        return Symbols.add;
    }
  }

  void _handleFABPressed(BuildContext context, WidgetRef ref, String loc) {
    switch (loc) {
      case '/':
        context.push('/add_transaction');
        break;
      case '/accounts':
        context.push('/add_account');
        break;
      case '/reports':
        // Show filter bottom sheet or dialog
        final action = ref.read(fabActionProvider);
        if (action != null) action();
        break;
      case '/categories':
        context.push('/add_category');
        break;
      case '/people':
        final action = ref.read(fabActionProvider);
        if (action != null) action();
        break;
      case '/goals':
        context.push('/add_goal');
        break;
      case '/loans':
        context.push('/add_loan');
        break;
      case '/recurring':
        context.push('/add_recurring');
        break;
    }
  }
}
