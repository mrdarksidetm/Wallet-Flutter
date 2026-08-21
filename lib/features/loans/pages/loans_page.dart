import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../people/widgets/person_avatar.dart';

class LoansPage extends ConsumerWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);
    final loansAsync = ref.watch(loansStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans & Debts'),
      ),
      body: loansAsync.when(
        data: (loans) {
          final borrowed =
              loans.where((l) => l.type == LoanType.borrowed).toList();
          final lent = loans.where((l) => l.type == LoanType.lent).toList();

          if (loans.isEmpty) {
            return const Center(child: Text('No loans found'));
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (borrowed.isNotEmpty)
                _buildLoanSection(
                  context,
                  ref,
                  'Borrowed',
                  'You owe others',
                  borrowed,
                  const Color(0xFFEF4444),
                  currencyFormat,
                ),
              if (borrowed.isNotEmpty && lent.isNotEmpty)
                const SizedBox(height: 32),
              if (lent.isNotEmpty)
                _buildLoanSection(
                  context,
                  ref,
                  'Lent',
                  'Others owe you',
                  lent,
                  const Color(0xFF10B981),
                  currencyFormat,
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildLoanSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    String subtitle,
    List<Loan> items,
    Color color,
    NumberFormat format,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(subtitle,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        ...items.map((item) {
          final personName = item.person.value?.name ?? 'Unknown';
          final dateStr = item.dueDate != null
              ? 'Due: ${DateFormat('MMM d').format(item.dueDate!)}'
              : 'No due date';
          final isPaid = item.isPaid;

          return Dismissible(
            key: ValueKey(item.id),
            direction: DismissDirection.horizontal,
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                
                item.isPaid = !isPaid;
                item.updatedAt = DateTime.now();
                await ref.read(loanRepositoryProvider).save(item);
                return false;
              } else {
                return await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Loan?'),
                    content: const Text(
                        'Are you sure you want to delete this loan record?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              }
            },
            onDismissed: (direction) async {
              if (direction == DismissDirection.endToStart) {
                
                await ref.read(loanRepositoryProvider).delete(item.id);
              }
            },
            background: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isPaid ? Colors.orange.withValues(alpha: 0.2) : colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 24),
              child: Icon(isPaid ? Symbols.undo : Symbols.check_circle,
                  color: isPaid ? Colors.orange : colorScheme.onPrimaryContainer),
            ),
            secondaryBackground: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: Icon(Symbols.delete, color: colorScheme.onErrorContainer),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isPaid
                    ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                    : (isDark ? colorScheme.surfaceContainer : colorScheme.surfaceContainerLow),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.4),
                  width: 1,
                ),
              ),
              child: ListTile(
                onTap: () => context.push('/add_loan', extra: item),
                leading: item.person.value != null
                    ? PersonAvatar(person: item.person.value!, radius: 24)
                    : Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: isPaid ? 0.05 : (isDark ? 0.2 : 0.12)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                            item.type == LoanType.lent
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            color: isPaid ? color.withValues(alpha: 0.5) : color,
                            size: 22),
                      ),
                title: Text(
                  personName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: isPaid ? TextDecoration.lineThrough : null,
                    color: isPaid ? Colors.grey : null,
                  ),
                ),
                subtitle: Text(dateStr,
                    style: TextStyle(color: isPaid ? Colors.grey : null)),
                trailing: Text(
                  format.format(item.amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isPaid ? color.withValues(alpha: 0.5) : color),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
