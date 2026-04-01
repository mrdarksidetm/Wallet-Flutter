import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/account.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/widgets/icon_picker.dart';
import '../../../core/theme/color_extension.dart';

class AccountDetailsPage extends ConsumerWidget {
  final Account account;
  const AccountDetailsPage({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = account.color.parseHexColor();

    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

    // Optimized: Watch transactions for this account specifically using ID filter in DB
    final transactionsAsync =
        ref.watch(accountTransactionsProvider(account.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(account.name),
        actions: [
          IconButton(
            onPressed: () => context.push('/add_account', extra: account),
            icon: const Icon(Symbols.edit),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
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
                      AppIcons.getIcon(account.icon),
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
                    currencyFormat.format(account.balance),
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
                      final isIncome = tx.type == TransactionType.income;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          child: const Icon(Symbols.receipt_long, size: 20),
                        ),
                        title: Text(tx.note ?? 'Transaction',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat.yMMMd().format(tx.date)),
                        trailing: Text(
                          '${isIncome ? '+' : '-'}${currencyFormat.format(tx.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isIncome ? Colors.green : colorScheme.error,
                          ),
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
