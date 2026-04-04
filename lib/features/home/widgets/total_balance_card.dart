import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/widgets/animated_counter.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/database/providers.dart';
import '../../../core/services/currency_engine.dart';
import '../../../core/database/models/transaction_model.dart';

class TotalBalanceCard extends ConsumerWidget {
  final double balance;
  const TotalBalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isVisible = ref.watch(personalizationProvider).isBalanceVisible;
    final selectedCurrency = ref.watch(currencyProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.surfaceContainerHighest,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Balance',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _showBalanceInfo(context, transactionsAsync, selectedCurrency),
                            icon: Icon(
                              Symbols.info,
                              size: 20,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            tooltip: 'Balance Info',
                          ),
                          IconButton(
                            onPressed: () {
                              ref.read(personalizationProvider.notifier).toggleBalanceVisibility();
                            },
                            icon: Icon(
                              isVisible ? Symbols.visibility : Symbols.visibility_off,
                              size: 20,
                              weight: 600,
                              grade: 0.25,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            tooltip: 'Toggle Balance Visibility',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isVisible)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          CurrencyEngine.getSymbol(selectedCurrency),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w300,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedCounter(
                          amount: balance,
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colorScheme.onSurface,
                            letterSpacing: -2,
                          ),
                        ),
                      ],
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: List.generate(
                          5,
                          (index) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Symbols.trending_up,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Safe to spend',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBalanceInfo(BuildContext context, AsyncValue<List<TransactionModel>> transactionsAsync, String currencyCode) {
    transactionsAsync.whenData((txs) {
      final income = txs.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount);
      final expense = txs.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);
      final symbol = CurrencyEngine.getSymbol(currencyCode);

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        builder: (context) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Balance Breakdown', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildInfoRow(context, 'Total Income', income, Colors.green, symbol),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Total Expense', expense, Colors.red, symbol),
              const Divider(height: 32),
              _buildInfoRow(context, 'Net Balance', income - expense, Theme.of(context).colorScheme.primary, symbol, isBold: true),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow(BuildContext context, String label, double amount, Color color, String symbol, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(
          '$symbol${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: isBold ? 18 : 16,
          ),
        ),
      ],
    );
  }
}
