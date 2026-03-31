import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/widgets/transaction_list_tile.dart';

class PersonDetailsPage extends ConsumerWidget {
  final Person person;
  const PersonDetailsPage({super.key, required this.person});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = Color(int.parse(person.color.replaceAll('0x', '0xFF'), radix: 16));
    final currency = ref.watch(currencyProvider);
    final format = NumberFormat.simpleCurrency(name: currency);

    final loansAsync = ref.watch(loansStreamProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(person.name),
            actions: [
              IconButton(
                icon: const Icon(Symbols.edit),
                onPressed: () {
                  // TODO: Implement edit person
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          
          // Stats Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 0,
                color: color.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: color.withValues(alpha: 0.2),
                        child: Text(
                          person.name[0].toUpperCase(),
                          style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        person.name,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(context, 'Loans', _calculateDebt(loansAsync.value ?? []), format),
                          _buildStat(context, 'Transactions', _countTxs(transactionsAsync.value ?? []), null),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'RECENT ACTIVITY',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.grey, fontSize: 12),
              ),
            ),
          ),

          transactionsAsync.when(
            data: (txs) {
              final personTxs = txs.where((t) => t.person.value?.id == person.id).toList();
              if (personTxs.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No transactions with this person')),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TransactionListTile(tx: personTxs[index]),
                    ),
                    childCount: personTxs.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  double _calculateDebt(List<Loan> loans) {
    final personLoans = loans.where((l) => l.person.value?.id == person.id && l.isActive && !l.isPaid);
    double total = 0;
    for (var l in personLoans) {
      if (l.type == LoanType.lent) {
        total += l.amount;
      } else {
        total -= l.amount;
      }
    }
    return total;
  }

  String _countTxs(List<TransactionModel> txs) {
    return txs.where((t) => t.person.value?.id == person.id).length.toString();
  }

  Widget _buildStat(BuildContext context, String label, dynamic value, NumberFormat? format) {
    final isNegative = value is double && value < 0;
    final displayValue = format != null ? format.format((value as double).abs()) : value.toString();
    
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '${isNegative ? '-' : ''}$displayValue',
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.w900,
            color: format == null ? null : (value == 0 ? null : (value > 0 ? Colors.green : Colors.red)),
          ),
        ),
      ],
    );
  }
}
