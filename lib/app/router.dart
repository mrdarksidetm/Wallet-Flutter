import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../presentation/home/pages/home_page.dart';
import '../presentation/accounts/pages/accounts_page.dart';
import '../presentation/transactions/pages/add_transaction_page.dart';
import '../presentation/reports/pages/reports_page.dart';
import '../presentation/loans/pages/loans_page.dart';
import '../presentation/auth/pages/unlock_page.dart';
import '../presentation/auth/providers/auth_provider.dart';
import '../presentation/settings/pages/settings_page.dart';
import '../presentation/home/pages/budgets_page.dart';
import '../presentation/home/pages/bill_splitter_page.dart';
import '../presentation/accounts/pages/add_edit_account_page.dart';
import '../presentation/loans/pages/add_edit_loan_page.dart';
import '../presentation/home/pages/recurring_page.dart';
import '../presentation/home/pages/add_edit_recurring_page.dart';
import '../presentation/settings/pages/categories_page.dart';
import '../presentation/settings/pages/add_edit_category_page.dart';
import '../presentation/people/pages/people_page.dart';
import '../presentation/settings/pages/currency_selection_page.dart';
import '../presentation/reports/pages/category_details_page.dart';
import '../presentation/home/pages/goals_page.dart';
import '../presentation/home/pages/add_edit_goal_page.dart';
import '../presentation/home/pages/search_page.dart';
import '../presentation/settings/pages/personalization_page.dart';
import '../presentation/settings/pages/theme_selection_page.dart';
import '../core/database/models/account.dart';
import '../core/database/models/category.dart';
import '../core/database/models/auxiliary_models.dart';
import '../core/providers/fab_action_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          _shellRoute('/', const HomePage()),
          _shellRoute('/accounts', const AccountsPage()),
          _shellRoute('/reports', const ReportsPage()),
          _shellRoute('/search', const SearchPage(), type: SharedAxisTransitionType.scaled),
          _shellRoute('/loans', const LoansPage(), type: SharedAxisTransitionType.scaled),
          _shellRoute('/budgets', const BudgetsPage(), type: SharedAxisTransitionType.scaled),
          _shellRoute('/bill_splitter', const BillSplitterPage(), type: SharedAxisTransitionType.scaled),
          _shellRoute('/recurring', const RecurringPage(), type: SharedAxisTransitionType.scaled),
          _shellRoute('/settings', const SettingsPage(), type: SharedAxisTransitionType.scaled),
          _shellRoute('/theme_selection', const ThemeSelectionPage(), type: SharedAxisTransitionType.scaled),
          _shellRoute('/personalization', const PersonalizationPage(), type: SharedAxisTransitionType.scaled),
          _shellRoute('/categories', const CategoriesPage(), type: SharedAxisTransitionType.scaled),
          _shellRoute('/people', const PeoplePage(), type: SharedAxisTransitionType.scaled),
          _shellRoute('/goals', const GoalsPage(), type: SharedAxisTransitionType.scaled),
          _shellRoute('/currency_selection', const CurrencySelectionPage(), type: SharedAxisTransitionType.scaled),
          GoRoute(
            path: '/category_details',
            pageBuilder: (context, state) => _buildSharedAxisTransition(
              context, state, CategoryDetailsPage(category: state.extra as Category), SharedAxisTransitionType.scaled,
            ),
          ),
        ],
      ),
      _rootRoute('/add_transaction', const AddTransactionPage()),
      _rootRoute('/add_account', (state) => AddEditAccountPage(account: state.extra as Account?)),
      _rootRoute('/add_loan', (_) => const AddEditLoanPage()),
      _rootRoute('/add_recurring', (state) => AddEditRecurringPage(recurring: state.extra as Recurring?)),
      _rootRoute('/add_category', (state) => AddEditCategoryPage(category: state.extra as Category?)),
      _rootRoute('/add_goal', (state) => AddEditGoalPage(goal: state.extra as Goal?)),
    ],
  );
});

GoRoute _shellRoute(String path, Widget child, {SharedAxisTransitionType type = SharedAxisTransitionType.horizontal}) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) => _buildSharedAxisTransition(context, state, child, type),
  );
}

GoRoute _rootRoute(String path, dynamic builder) {
  return GoRoute(
    path: path,
    parentNavigatorKey: _rootNavigatorKey,
    builder: (context, state) => builder is Widget ? builder : builder(state),
  );
}

Page _buildSharedAxisTransition(BuildContext context, GoRouterState state, Widget child, SharedAxisTransitionType type) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(animation: animation, secondaryAnimation: secondaryAnimation, transitionType: type, child: child);
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
    return NavigationDestination(
      icon: Icon(icon, fill: 0),
      selectedIcon: Icon(icon, fill: 1),
      label: label,
    );
  }
}

class _FAB extends ConsumerWidget {
  final String location;
  const _FAB({required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_shouldHideFAB(location)) return const SizedBox.shrink();

    return FloatingActionButton(
      onPressed: () => _handleFABPressed(context, ref, location),
      child: Icon(_getFABIcon(ref, location)),
    );
  }

  bool _shouldHideFAB(String loc) {
    final hiddenRoutes = ['/settings', '/personalization', '/theme_selection'];
    return hiddenRoutes.any((route) => loc.startsWith(route));
  }

  IconData _getFABIcon(WidgetRef ref, String loc) {
    switch (loc) {
      case '/': return Symbols.add;
      case '/accounts': return Symbols.add_card;
      case '/categories': return Symbols.category;
      case '/people': return Symbols.person_add;
      case '/goals': return Symbols.flag;
      case '/loans': return Symbols.front_loader;
      case '/recurring': return Symbols.event_repeat;
      default: return Symbols.add;
    }
  }

  void _handleFABPressed(BuildContext context, WidgetRef ref, String loc) {
    switch (loc) {
      case '/': context.push('/add_transaction'); break;
      case '/accounts': context.push('/add_account'); break;
      case '/categories': context.push('/add_category'); break;
      case '/people': 
        final action = ref.read(fabActionProvider);
        if (action != null) action();
        break;
      case '/goals': context.push('/add_goal'); break;
      case '/loans': context.push('/add_loan'); break;
      case '/recurring': context.push('/add_recurring'); break;
    }
  }
}
