import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/services/currency_engine.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/expressive_shape.dart';
import '../../people/widgets/person_avatar.dart';
import '../widgets/wavy_debt_progress_line.dart';
import '../widgets/add_debt_installment_sheet.dart';

class LoansPage extends ConsumerStatefulWidget {
  const LoansPage({super.key});

  @override
  ConsumerState<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends ConsumerState<LoansPage> {
  bool _isBorrowedExpanded = true;
  bool _isLentExpanded = true;
  bool _isSheetOpen = false;
  final Set<int> _expandedLoanIds = {};

  void _toggleLoanExpand(int loanId) {
    setState(() {
      if (_expandedLoanIds.contains(loanId)) {
        _expandedLoanIds.remove(loanId);
      } else {
        _expandedLoanIds.add(loanId);
      }
    });
  }

  Future<void> _openInstallmentSheet(Loan item, double remainingAmount) async {
    setState(() => _isSheetOpen = true);
    await AddDebtInstallmentSheet.show(
      context,
      loan: item,
      remainingAmount: remainingAmount,
    );
    if (mounted) {
      setState(() => _isSheetOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);
    final fillIcons = ref.watch(personalizationProvider).fillIcons;

    final loansAsync = ref.watch(loansStreamProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: _isSheetOpen
          ? null
          : FloatingActionButton(
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              onPressed: () => context.push('/add_loan'),
              child: Icon(
                Symbols.add_rounded,
                fill: fillIcons ? 1.0 : 0.0,
              ),
            ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            leading: const AppBackButton(),
            title: Text(
              'Loans & Debts',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          loansAsync.when(
            data: (loans) {
              // Trigger automated due debt alerts
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(notificationServiceProvider).checkAndNotifyDueDebts(
                      loans,
                      selectedCurrency,
                    );
              });

              final borrowed =
                  loans.where((l) => l.type == LoanType.borrowed).toList();
              final lent = loans.where((l) => l.type == LoanType.lent).toList();

              if (loans.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Symbols.handshake_rounded, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No active loans or debts found'),
                      ],
                    ),
                  ),
                );
              }

              final allTransactions = transactionsAsync.valueOrNull ?? [];

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                sliver: SliverList.list(
                  children: [
                    if (borrowed.isNotEmpty)
                      _buildLoanSection(
                        context,
                        ref,
                        'Borrowed',
                        'You owe others (Payable in installments)',
                        borrowed,
                        const Color(0xFFEF4444),
                        currencyFormat,
                        selectedCurrency,
                        _isBorrowedExpanded,
                        () => setState(
                            () => _isBorrowedExpanded = !_isBorrowedExpanded),
                        allTransactions,
                      ),
                    if (borrowed.isNotEmpty && lent.isNotEmpty)
                      const SizedBox(height: 24),
                    if (lent.isNotEmpty)
                      _buildLoanSection(
                        context,
                        ref,
                        'Lent',
                        'Others owe you (Collectible in installments)',
                        lent,
                        const Color(0xFF10B981),
                        currencyFormat,
                        selectedCurrency,
                        _isLentExpanded,
                        () => setState(
                            () => _isLentExpanded = !_isLentExpanded),
                        allTransactions,
                      ),
                  ],
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Error: $err')),
            ),
          ),
        ],
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
    String currency,
    bool isSectionExpanded,
    VoidCallback onToggleSection,
    List<TransactionModel> allTransactions,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            IconButton.filledTonal(
              onPressed: onToggleSection,
              icon: AnimatedRotation(
                turns: isSectionExpanded ? 0.0 : 0.5,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: const Icon(Symbols.keyboard_arrow_up, size: 20),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),

        const SizedBox(height: 12),

        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOutCubic,
          child: isSectionExpanded
              ? Column(
                  children: items.map((item) {
                    final isCardExpanded = _expandedLoanIds.contains(item.id);

                    // Find installment transactions tagged with this loan
                    final installments = allTransactions.where((t) {
                      return t.tags != null &&
                          t.tags!.contains('loan_${item.id}') &&
                          !t.isDeleted;
                    }).toList()
                      ..sort((a, b) => b.date.compareTo(a.date));

                    final paidAmount = installments.fold<double>(
                      0.0,
                      (sum, t) => sum + t.amount,
                    );
                    final remainingAmount =
                        (item.amount - paidAmount).clamp(0.0, double.infinity);
                    final progress = item.amount > 0
                        ? (paidAmount / item.amount).clamp(0.0, 1.0)
                        : 0.0;
                    final isCompleted = item.isPaid || (remainingAmount <= 0);

                    return _buildExpandableDebtCard(
                      context,
                      ref,
                      item,
                      installments,
                      paidAmount,
                      remainingAmount,
                      progress,
                      isCompleted,
                      isCardExpanded,
                      color,
                      currency,
                    );
                  }).toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildExpandableDebtCard(
    BuildContext context,
    WidgetRef ref,
    Loan item,
    List<TransactionModel> installments,
    double paidAmount,
    double remainingAmount,
    double progress,
    bool isCompleted,
    bool isExpanded,
    Color themeColor,
    String currency,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final personName = item.person.value?.name ?? 'Unknown Contact';
    final isLent = item.type == LoanType.lent;

    final Color paidColor = const Color(0xFF10B981);
    final Color remainingColor =
        isLent ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: isCompleted
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
            : (isDark
                ? colorScheme.surfaceContainer
                : colorScheme.surfaceContainerLow),
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isCompleted
                  ? paidColor.withValues(alpha: 0.35)
                  : colorScheme.outlineVariant
                      .withValues(alpha: isDark ? 0.3 : 0.4),
              width: isCompleted ? 1.5 : 1.0,
            ),
          ),
          child: InkWell(
            onTap: () => _toggleLoanExpand(item.id),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Summary Row (Person avatar, name, total amount, expand chevron)
                  Row(
                    children: [
                      if (item.person.value != null)
                        PersonAvatar(person: item.person.value!, radius: 22)
                      else
                        ExpressiveShapeContainer(
                          size: 44,
                          color: themeColor.withValues(
                              alpha: isCompleted ? 0.08 : 0.15),
                          child: Icon(
                            isLent
                                ? Symbols.arrow_upward_rounded
                                : Symbols.arrow_downward_rounded,
                            color: isCompleted
                                ? themeColor.withValues(alpha: 0.6)
                                : themeColor,
                            size: 22,
                          ),
                        ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    personName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: isCompleted
                                          ? colorScheme.onSurfaceVariant
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (isCompleted) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: paidColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle_rounded,
                                            size: 12, color: paidColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          'COMPLETED',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: paidColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            _buildDueStatusBadge(
                                item, isCompleted, theme, colorScheme),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyEngine.formatCurrency(
                                item.amount, currency),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: isCompleted
                                  ? colorScheme.onSurfaceVariant
                                  : themeColor,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            isCompleted
                                ? 'Fully Paid'
                                : '${(progress * 100).toInt()}% paid',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? paidColor
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Symbols.keyboard_arrow_down_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  // When debt is fully cleared, remove the wavy line and place the completed logo there!
                  const SizedBox(height: 16),
                  if (isCompleted)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: paidColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: paidColor.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ExpressiveShapeContainer(
                            size: 32,
                            shapeType: ExpressiveShapeType.starburst,
                            color: paidColor.withValues(alpha: 0.2),
                            child: Icon(
                              Symbols.verified_rounded,
                              size: 20,
                              color: paidColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Debt Fully Cleared & Settled',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: paidColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (progress > 0.001)
                    WavyDebtProgressLine(
                      progress: progress,
                      paidColor: paidColor,
                      remainingColor: remainingColor,
                      height: 32,
                    ),

                  // Paid vs Owes Now Indicator Row
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Paid Back
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: paidColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Paid Back: ',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            CurrencyEngine.formatCurrency(paidAmount, currency),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: paidColor,
                            ),
                          ),
                        ],
                      ),

                      // Owes Now
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: remainingColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isLent ? 'Owes Now: ' : 'Left to Pay: ',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            CurrencyEngine.formatCurrency(
                                remainingAmount, currency),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: remainingColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // --- Expanded Detail Section ---
                  if (isExpanded) ...[
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // 1. Prominent Primary Action Button (Record Repayment / Make Payment)
                    if (!isCompleted) ...[
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () =>
                              _openInstallmentSheet(item, remainingAmount),
                          icon: Icon(
                            isLent
                                ? Symbols.payments_rounded
                                : Symbols.add_card_rounded,
                            size: 18,
                          ),
                          label: Text(
                            isLent ? 'Record Repayment' : 'Make Payment',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: themeColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 2. Installment Breakdown Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Breakdown (${installments.length})',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // 3. Installment Payments List
                    if (installments.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 14),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Symbols.receipt_long_rounded,
                              size: 20,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isLent
                                    ? 'No repayments recorded yet.'
                                    : 'No payments recorded yet.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: installments.map((tx) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                ExpressiveShapeContainer(
                                  size: 32,
                                  color: paidColor.withValues(alpha: 0.15),
                                  child: Icon(
                                    Icons.payments_rounded,
                                    size: 16,
                                    color: paidColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.note?.isNotEmpty == true
                                            ? tx.note!
                                            : 'Installment payment',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        DateFormat.yMMMd().format(tx.date),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          fontSize: 11,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '+${CurrencyEngine.formatCurrency(tx.amount, currency)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: paidColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 20),

                    // "Mark it completed" Button with tick icon
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final newPaidStatus = !item.isPaid;
                          item.isPaid = newPaidStatus;
                          item.updatedAt = DateTime.now();
                          await ref.read(loanRepositoryProvider).save(item);
                          final personalization =
                              ref.read(personalizationProvider);
                          await ref.read(hapticServiceProvider).transaction(
                              personalization.vibrateOnTransaction);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  newPaidStatus
                                      ? 'Debt marked as completed!'
                                      : 'Debt reopened',
                                ),
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          item.isPaid
                              ? Symbols.undo_rounded
                              : Symbols.check_circle_rounded,
                          color: item.isPaid ? Colors.orange : paidColor,
                        ),
                        label: Text(
                          item.isPaid
                              ? 'Reopen Debt'
                              : 'Mark it completed',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: item.isPaid
                                ? Colors.orange
                                : colorScheme.onSurface,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: item.isPaid
                                ? Colors.orange.withValues(alpha: 0.5)
                                : paidColor.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Edit / Delete Auxiliary Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () =>
                              context.push('/add_loan', extra: item),
                          icon: const Icon(Symbols.edit_rounded, size: 16),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Loan?'),
                                content: const Text(
                                    'Are you sure you want to delete this loan?'),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: TextButton.styleFrom(
                                        foregroundColor: colorScheme.error),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await ref
                                  .read(loanRepositoryProvider)
                                  .delete(item.id);
                            }
                          },
                          icon: Icon(Symbols.delete_rounded,
                              size: 16, color: colorScheme.error),
                          label: Text(
                            'Delete',
                            style: TextStyle(color: colorScheme.error),
                          ),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDueStatusBadge(
      Loan item, bool isCompleted, ThemeData theme, ColorScheme colorScheme) {
    if (item.dueDate == null) {
      return Text(
        'No due date',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due =
        DateTime(item.dueDate!.year, item.dueDate!.month, item.dueDate!.day);
    final diffDays = today.difference(due).inDays;

    if (isCompleted) {
      return Text(
        'Cleared (Due was ${DateFormat.yMMMd().format(item.dueDate!)})',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (diffDays > 0) {
      // Overdue
      return Container(
        margin: const EdgeInsets.only(top: 3),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.35),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.warning_rounded,
                size: 12, color: Color(0xFFEF4444)),
            const SizedBox(width: 4),
            Text(
              'Overdue by $diffDays day${diffDays == 1 ? '' : 's'} (${DateFormat.yMMMd().format(item.dueDate!)})',
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w800,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      );
    } else if (diffDays == 0) {
      // Due today
      return Container(
        margin: const EdgeInsets.only(top: 3),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
            width: 0.8,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.schedule_rounded, size: 12, color: Color(0xFFD97706)),
            SizedBox(width: 4),
            Text(
              'Due Today!',
              style: TextStyle(
                color: Color(0xFFD97706),
                fontWeight: FontWeight.w800,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      );
    } else {
      // Due in future
      final daysLeft = -diffDays;
      return Text(
        'Due in $daysLeft day${daysLeft == 1 ? '' : 's'} (${DateFormat.yMMMd().format(item.dueDate!)})',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }
}
