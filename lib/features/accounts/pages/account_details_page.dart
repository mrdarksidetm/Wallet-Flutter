import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/account.dart';
import '../../../core/widgets/icon_picker.dart';
import '../../../core/widgets/transaction_list_tile.dart';
import '../../../core/theme/color_extension.dart';
import '../../../core/services/currency_engine.dart';
import '../../../core/widgets/app_back_button.dart';

class AccountDetailsPage extends ConsumerWidget {
  final Account account;
  const AccountDetailsPage({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accountsAsync = ref.watch(accountsStreamProvider);
    final currentAccount = accountsAsync.value?.where((a) => a.id == account.id).firstOrNull ?? account;
    final color = currentAccount.color.parseHexColor();

    final selectedCurrency = ref.watch(currencyProvider);

    // Optimized: Watch transactions for this account specifically using ID filter in DB
    final transactionsAsync =
        ref.watch(accountTransactionsProvider(account.id));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            leading: const AppBackButton(),
            title: Text(
              currentAccount.name,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => context.push('/add_account', extra: currentAccount),
                icon: const Icon(Symbols.edit),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.getIcon(currentAccount.icon),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyEngine.formatCurrency(currentAccount.balance, selectedCurrency),
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'HISTORY',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return const SliverFillRemaining(
                  child:
                      Center(child: Text('No transactions for this account')),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tx = transactions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TransactionListTile(
                          tx: tx,
                          onTap: () => context.push('/add_transaction', extra: tx),
                        ),
                      );
                    },
                    childCount: transactions.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator())),
            error: (err, _) =>
                SliverFillRemaining(child: Center(child: Text('Error: $err'))),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
