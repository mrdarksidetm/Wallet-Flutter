import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
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
import '../presentation/home/pages/goals_page.dart';
import '../presentation/home/pages/add_edit_goal_page.dart';
import '../presentation/home/pages/search_page.dart';
import '../core/database/models/account.dart';
import '../core/database/models/category.dart';
import '../core/database/models/auxiliary_models.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => _buildSharedAxisTransition(
              context, state, const HomePage(), SharedAxisTransitionType.horizontal,
            ),
          ),
          GoRoute(
            path: '/accounts',
            pageBuilder: (context, state) => _buildSharedAxisTransition(
              context, state, const AccountsPage(), SharedAxisTransitionType.horizontal,
            ),
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) => _buildSharedAxisTransition(
              context, state, const ReportsPage(), SharedAxisTransitionType.horizontal,
            ),
          ),
          GoRoute(
            path: '/loans',
            pageBuilder: (context, state) => _buildSharedAxisTransition(
              context, state, const LoansPage(), SharedAxisTransitionType.scaled,
            ),
          ),
          GoRoute(
            path: '/budgets',
            pageBuilder: (context, state) => _buildSharedAxisTransition(
              context, state, const BudgetsPage(), SharedAxisTransitionType.scaled,
            ),
          ),
          GoRoute(
            path: '/bill_splitter',
            pageBuilder: (context, state) => _buildSharedAxisTransition(
              context, state, const BillSplitterPage(), SharedAxisTransitionType.scaled,
            ),
          ),
          GoRoute(
            path: '/recurring',
            pageBuilder: (context, state) => _buildSharedAxisTransition(
              context, state, const RecurringPage(), SharedAxisTransitionType.scaled,
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => _buildSharedAxisTransition(
              context, state, const SettingsPage(), SharedAxisTransitionType.scaled,
            ),
          ),
          GoRoute(
            path: '/categories',
            pageBuilder: (context, state) => _buildSharedAxisTransition(
              context, state, const CategoriesPage(), SharedAxisTransitionType.scaled,
            ),
          ),
          GoRoute(
            path: '/people',
            pageBuilder: (context, state) => _buildSharedAxisTransition(
              context, state, const PeoplePage(), SharedAxisTransitionType.scaled,
            ),
          ),
          GoRoute(
            path: '/goals',
            pageBuilder: (context, state) => _buildSharedAxisTransition(
              context, state, const GoalsPage(), SharedAxisTransitionType.scaled,
            ),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => _buildSharedAxisTransition(
              context, state, const SearchPage(), SharedAxisTransitionType.scaled,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/add_transaction',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddTransactionPage(),
      ),
      GoRoute(
        path: '/add_account',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AddEditAccountPage(account: state.extra as Account?),
      ),
      GoRoute(
        path: '/add_loan',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddEditLoanPage(),
      ),
      GoRoute(
        path: '/add_recurring',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AddEditRecurringPage(recurring: state.extra as Recurring?),
      ),
      GoRoute(
        path: '/add_category',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AddEditCategoryPage(category: state.extra as Category?),
      ),
      GoRoute(
        path: '/add_goal',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AddEditGoalPage(goal: state.extra as Goal?),
      ),
    ],
  );
});

Page _buildSharedAxisTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
  SharedAxisTransitionType type,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
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
    
    if (authState.isLocked) {
      return const UnlockPage();
    }

    final location = GoRouterState.of(context).uri.path;
    
    int getIndex() {
      if (location == '/') return 0;
      if (location == '/accounts') return 1;
      if (location == '/reports') return 2;
      return 0;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: getIndex(),
        onDestinationSelected: (index) {
          if (index == 0) context.go('/');
          if (index == 1) context.go('/accounts');
          if (index == 2) context.go('/reports');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: Icon(Icons.pie_chart_rounded),
            label: 'Reports',
          ),
        ],
      ),
      floatingActionButton: getIndex() == 0 ? FloatingActionButton(
        onPressed: () => context.push('/add_transaction'),
        child: const Icon(Icons.add_rounded),
      ) : null,
    );
  }
}
