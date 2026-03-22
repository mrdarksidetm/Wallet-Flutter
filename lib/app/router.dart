import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/home/pages/home_page.dart';
import '../presentation/accounts/pages/accounts_page.dart';
import '../presentation/transactions/pages/add_transaction_page.dart';
import '../presentation/reports/pages/reports_page.dart';
import '../presentation/loans/pages/loans_page.dart';
import '../presentation/auth/pages/unlock_page.dart';
import '../presentation/auth/providers/auth_provider.dart';
import '../presentation/settings/pages/settings_page.dart';

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
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/accounts',
            builder: (context, state) => const AccountsPage(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsPage(),
          ),
          GoRoute(
            path: '/loans',
            builder: (context, state) => const LoansPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/add_transaction',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddTransactionPage(),
      ),
    ],
  );
});

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
