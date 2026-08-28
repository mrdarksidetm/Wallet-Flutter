import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/database/models/account.dart';
import '../../../core/services/currency_engine.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/transaction_segmented_group.dart';
import '../../../core/widgets/expressive_shape.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'Search note, amount, date, time, category...',
            hintStyle: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            prefixIcon: const Icon(Symbols.search),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Symbols.close),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
            border: InputBorder.none,
          ),
        ),
      ),
      body: _query.trim().isEmpty
          ? _SearchEmptyState(colorScheme: colorScheme)
          : _SearchResults(query: _query.trim()),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;
  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final peopleAsync = ref.watch(personsStreamProvider);
    final goalsAsync = ref.watch(goalsStreamProvider);
    final loansAsync = ref.watch(loansStreamProvider);
    final accountsAsync = ref.watch(accountsStreamProvider);

    final accountsList = accountsAsync.valueOrNull ?? [];
    final peopleList = peopleAsync.valueOrNull ?? [];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // --- 1. Transactions Section with Rich Filtering ---
        transactionsAsync.when(
          data: (transactions) {
            final matchedTxs = transactions.where((t) {
              return _matchesTransaction(
                t,
                query,
                selectedCurrency,
                currencyFormat,
                accountsList,
                peopleList,
              );
            }).toList();

            if (matchedTxs.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transactions',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${matchedTxs.length} found',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                TransactionSegmentedCard(
                  transactions: matchedTxs,
                  // Search results must NEVER obscure amounts (explicit user requirement)
                  obscureAmount: false,
                  onTap: (tx) => context.push('/add_transaction', extra: tx),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        // --- 2. Accounts Section ---
        _SearchSection<Account>(
          title: 'Accounts',
          dataAsync: accountsAsync,
          filter: (a) => _matchesAccount(a, query, selectedCurrency, currencyFormat),
          builder: (a) => _ResultTile(
            title: a.name,
            subtitle:
                '${a.type.name.toUpperCase()} • ${CurrencyEngine.formatCurrency(a.balance, selectedCurrency)}',
            icon: Symbols.account_balance,
            onTap: () => context.push('/account_details', extra: a),
          ),
        ),

        // --- 3. People Section ---
        _SearchSection<Person>(
          title: 'People',
          dataAsync: peopleAsync,
          filter: (p) => _matchesPerson(p, query),
          builder: (p) => _ResultTile(
            title: p.name,
            subtitle: p.phoneNumber?.isNotEmpty == true
                ? p.phoneNumber!
                : (p.email?.isNotEmpty == true ? p.email! : 'Contact'),
            icon: Symbols.person,
            onTap: () => context.push('/people'),
          ),
        ),

        // --- 4. Goals Section ---
        _SearchSection<Goal>(
          title: 'Goals',
          dataAsync: goalsAsync,
          filter: (g) => _matchesGoal(g, query, selectedCurrency, currencyFormat),
          builder: (g) => _ResultTile(
            title: g.name,
            subtitle:
                'Target: ${CurrencyEngine.formatCurrency(g.targetAmount, selectedCurrency)} • Due ${DateFormat.yMMMd().format(g.targetDate)}',
            icon: Symbols.flag,
            onTap: () => context.push('/goals'),
          ),
        ),

        // --- 5. Loans Section ---
        _SearchSection<Loan>(
          title: 'Loans',
          dataAsync: loansAsync,
          filter: (l) => _matchesLoan(l, query, selectedCurrency, currencyFormat),
          builder: (l) => _ResultTile(
            title: l.note?.isNotEmpty == true ? l.note! : 'Loan',
            subtitle:
                '${CurrencyEngine.formatCurrency(l.amount, selectedCurrency)} • ${DateFormat.yMMMd().format(l.date)}',
            icon: Symbols.front_loader,
            onTap: () => context.push('/loans'),
          ),
        ),
      ],
    );
  }

  // --- Comprehensive Transaction Match Engine ---
  bool _matchesTransaction(
    TransactionModel t,
    String query,
    String currency,
    NumberFormat currencyFormat,
    List<Account> accounts,
    List<Person> people,
  ) {
    final q = query.toLowerCase();

    // 1. Note / Memo
    if ((t.note?.toLowerCase() ?? '').contains(q)) return true;

    // 2. Category Name
    final categoryName = t.category.value?.name.toLowerCase() ?? '';
    if (categoryName.contains(q)) return true;

    // 3. Account Name
    final account = accounts.where((a) => a.id == t.accountId).firstOrNull;
    if (account != null && account.name.toLowerCase().contains(q)) return true;

    // 4. Person Name
    final person = people.where((p) => p.id == t.personId).firstOrNull;
    if (person != null && person.name.toLowerCase().contains(q)) return true;

    // 5. Transaction Type (income, expense, transfer)
    if (t.type.name.toLowerCase().contains(q)) return true;

    // 6. Amount Matching (Exact number, formatted currency, stripped symbols)
    final amountStr = t.amount.toString();
    final amountIntStr = t.amount.toInt().toString();
    final amountFixedStr = t.amount.toStringAsFixed(2);
    final formattedAmount = currencyFormat.format(t.amount).toLowerCase();
    final customFormatted =
        CurrencyEngine.formatCurrency(t.amount, currency).toLowerCase();

    if (amountStr.contains(q) ||
        amountIntStr.contains(q) ||
        amountFixedStr.contains(q) ||
        formattedAmount.contains(q) ||
        customFormatted.contains(q)) {
      return true;
    }

    final cleanNumeric = q.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleanNumeric.isNotEmpty &&
        (amountStr.contains(cleanNumeric) ||
            amountIntStr.contains(cleanNumeric) ||
            amountFixedStr.contains(cleanNumeric))) {
      return true;
    }

    // 7. Date Matching (Multiple date variations)
    final dt = t.date;
    final isoDate = DateFormat('yyyy-MM-dd').format(dt).toLowerCase();
    final fullDate = DateFormat('MMMM d, yyyy').format(dt).toLowerCase(); // e.g. august 28, 2026
    final shortDate = DateFormat('MMM d, yyyy').format(dt).toLowerCase(); // e.g. aug 28, 2026
    final monthDay = DateFormat('MMM d').format(dt).toLowerCase(); // e.g. aug 28
    final dayMonth = DateFormat('d MMM').format(dt).toLowerCase(); // e.g. 28 aug
    final fullMonthDay = DateFormat('MMMM d').format(dt).toLowerCase(); // e.g. august 28
    final weekday = DateFormat('EEEE').format(dt).toLowerCase(); // e.g. friday
    final shortWeekday = DateFormat('E').format(dt).toLowerCase(); // e.g. fri
    final monthName = DateFormat('MMMM').format(dt).toLowerCase(); // e.g. august
    final shortMonth = DateFormat('MMM').format(dt).toLowerCase(); // e.g. aug
    final yearStr = dt.year.toString();
    final dayStr = dt.day.toString();
    final paddedDay = dt.day.toString().padLeft(2, '0');

    if (isoDate.contains(q) ||
        fullDate.contains(q) ||
        shortDate.contains(q) ||
        monthDay.contains(q) ||
        dayMonth.contains(q) ||
        fullMonthDay.contains(q) ||
        weekday.contains(q) ||
        shortWeekday == q ||
        monthName.contains(q) ||
        shortMonth == q ||
        yearStr == q ||
        dayStr == q ||
        paddedDay == q) {
      return true;
    }

    // Relative Date Matching (Today, Yesterday)
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day;

    if (isToday && 'today'.contains(q)) return true;
    if (isYesterday && 'yesterday'.contains(q)) return true;

    // 8. Time Matching (12-hour AM/PM, 24-hour HH:mm)
    final timeWithAmPm = DateFormat('h:mm a').format(dt).toLowerCase(); // e.g. 3:30 pm
    final timeCompactAmPm = DateFormat('h:mma').format(dt).toLowerCase(); // e.g. 3:30pm
    final time24 = DateFormat('HH:mm').format(dt).toLowerCase(); // e.g. 15:30
    final hourAmPm = DateFormat('h a').format(dt).toLowerCase(); // e.g. 3 pm
    final hourCompactAmPm = DateFormat('ha').format(dt).toLowerCase(); // e.g. 3pm
    final amPm = DateFormat('a').format(dt).toLowerCase(); // e.g. pm

    if (timeWithAmPm.contains(q) ||
        timeCompactAmPm.contains(q) ||
        time24.contains(q) ||
        hourAmPm.contains(q) ||
        hourCompactAmPm.contains(q) ||
        (amPm == q && (q == 'am' || q == 'pm'))) {
      return true;
    }

    return false;
  }

  // --- Account Match Engine ---
  bool _matchesAccount(
    Account a,
    String query,
    String currency,
    NumberFormat currencyFormat,
  ) {
    final q = query.toLowerCase();
    if (a.name.toLowerCase().contains(q)) return true;
    if (a.type.name.toLowerCase().contains(q)) return true;

    final balanceStr = a.balance.toString();
    final customFormatted =
        CurrencyEngine.formatCurrency(a.balance, currency).toLowerCase();
    if (balanceStr.contains(q) || customFormatted.contains(q)) return true;

    return false;
  }

  // --- Person Match Engine ---
  bool _matchesPerson(Person p, String query) {
    final q = query.toLowerCase();
    if (p.name.toLowerCase().contains(q)) return true;
    if ((p.phoneNumber?.toLowerCase() ?? '').contains(q)) return true;
    if ((p.email?.toLowerCase() ?? '').contains(q)) return true;
    return false;
  }

  // --- Goal Match Engine ---
  bool _matchesGoal(
    Goal g,
    String query,
    String currency,
    NumberFormat currencyFormat,
  ) {
    final q = query.toLowerCase();
    if (g.name.toLowerCase().contains(q)) return true;

    final targetStr = g.targetAmount.toString();
    final customFormatted =
        CurrencyEngine.formatCurrency(g.targetAmount, currency).toLowerCase();
    if (targetStr.contains(q) || customFormatted.contains(q)) return true;

    final dateStr = DateFormat.yMMMd().format(g.targetDate).toLowerCase();
    if (dateStr.contains(q)) return true;

    return false;
  }

  // --- Loan Match Engine ---
  bool _matchesLoan(
    Loan l,
    String query,
    String currency,
    NumberFormat currencyFormat,
  ) {
    final q = query.toLowerCase();
    if ((l.note?.toLowerCase() ?? '').contains(q)) return true;

    final amountStr = l.amount.toString();
    final customFormatted =
        CurrencyEngine.formatCurrency(l.amount, currency).toLowerCase();
    if (amountStr.contains(q) || customFormatted.contains(q)) return true;

    final dateStr = DateFormat.yMMMd().format(l.date).toLowerCase();
    if (dateStr.contains(q)) return true;

    return false;
  }
}

class _SearchSection<T> extends StatelessWidget {
  final String title;
  final AsyncValue<List<T>> dataAsync;
  final bool Function(T) filter;
  final Widget Function(T) builder;

  const _SearchSection({
    required this.title,
    required this.dataAsync,
    required this.filter,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return dataAsync.when(
      data: (items) {
        final filteredItems = items.where(filter).toList();
        if (filteredItems.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...filteredItems.map(builder),
            const SizedBox(height: 16),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ResultTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          leading: ExpressiveShapeContainer(
            size: 40,
            color: colorScheme.surfaceContainerHighest,
            child: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          trailing: const Icon(Symbols.chevron_right, size: 20),
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  final ColorScheme colorScheme;
  const _SearchEmptyState({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Symbols.manage_search,
              size: 64, color: colorScheme.outline.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'The Search Hub',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Search notes, exact amounts, dates (e.g. "Aug 28", "Friday"), times (e.g. "3:30 pm"), accounts, people, and categories.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
