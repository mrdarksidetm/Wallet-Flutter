import 'package:flutter/material.dart';
import 'package:wallet/core/theme/color_extension.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/providers.dart';
import '../../../../core/database/models/transaction_model.dart';

import '../../../../shared/widgets/paisa_list_tile.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme_provider.dart';

class RecentTransactions extends ConsumerWidget {
  final VoidCallback onSeeAll;

  const RecentTransactions({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final themeState = ref.watch(themeControllerProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(fontFamily: 'ProductSans', fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF4A4442)),
              ),
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8B5145),
                ),
                child: const Text('See All', style: TextStyle(fontFamily: 'ProductSans', fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        transactionsAsync.when(
          data: (transactions) {
            final recent = transactions.take(5).toList();
            if (recent.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No recent transactions', style: TextStyle(fontFamily: 'ProductSans', color: Color(0xFF7A706D))),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final tx = recent[index];
                final category = tx.category.value;
                final isExpense = tx.type == TransactionType.expense;
                final amountColor = isExpense ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71);
                final iconColor = (category?.color ?? '0xFF9E9E9E').parseHexColor();
                
                return PaisaListTile(
                  title: category?.name ?? 'Unknown',
                  subtitle: '${DateFormat.yMMMd().format(tx.date)} • ${tx.account.value?.name ?? ''}',
                  amount: '${isExpense ? '-' : ''}${themeState.currencySymbol}${tx.amount.toStringAsFixed(2)}',
                  amountColor: amountColor,
                  trailingSubtitle: DateFormat.jm().format(tx.date),
                  icon: Icons.category, // Replace with actual category icon later
                  iconColor: iconColor,
                  iconBackgroundColor: iconColor.withOpacity(0.1),
                  onTap: () {
                    // Navigate to transaction details
                  },
                ).animate(delay: (index * 100).ms).fade(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
              },
            );
          },
          loading: () => const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator(color: Color(0xFF8B5145)))),
          error: (err, _) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE74C3C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE74C3C).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFE74C3C)),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $err', style: const TextStyle(fontFamily: 'ProductSans', color: Color(0xFFE74C3C)))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
