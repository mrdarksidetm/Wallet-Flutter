import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/database/models/account.dart';
import '../../../core/services/haptic_service.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'Search anything...',
            prefixIcon: const Icon(Symbols.search),
            suffixIcon: _query.isNotEmpty ? IconButton(
              icon: const Icon(Symbols.close),
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ) : null,
            border: InputBorder.none,
          ),
        ),
      ),
      body: _query.isEmpty
          ? _SearchEmptyState(colorScheme: colorScheme)
          : _SearchResults(query: _query),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;
  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final peopleAsync = ref.watch(personsStreamProvider);
    final goalsAsync = ref.watch(goalsStreamProvider);
    final loansAsync = ref.watch(loansStreamProvider);
    final accountsAsync = ref.watch(accountsStreamProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SearchSection<Account>(
          title: 'Accounts',
          dataAsync: accountsAsync,
          filter: (a) => a.name.toLowerCase().contains(query.toLowerCase()),
          builder: (a) => _ResultTile(
            title: a.name,
            subtitle: 'Account',
            icon: Symbols.account_balance,
            onTap: () => context.go('/accounts'),
          ),
        ),
        _SearchSection<Person>(
          title: 'People',
          dataAsync: peopleAsync,
          filter: (p) => p.name.toLowerCase().contains(query.toLowerCase()),
          builder: (p) => _ResultTile(
            title: p.name,
            subtitle: 'Contact',
            icon: Symbols.person,
            onTap: () => context.push('/people'),
          ),
        ),
        _SearchSection<Goal>(
          title: 'Goals',
          dataAsync: goalsAsync,
          filter: (g) => g.name.toLowerCase().contains(query.toLowerCase()),
          builder: (g) => _ResultTile(
            title: g.name,
            subtitle: 'Target: ${currencyFormat.format(g.targetAmount)}',
            icon: Symbols.flag,
            onTap: () => context.push('/goals'),
          ),
        ),
        _SearchSection<Loan>(
          title: 'Loans',
          dataAsync: loansAsync,
          filter: (l) => (l.note?.toLowerCase() ?? '').contains(query.toLowerCase()),
          builder: (l) => _ResultTile(
            title: l.note ?? 'Loan',
            subtitle: 'Loan: ${currencyFormat.format(l.amount)}',
            icon: Symbols.front_loader,
            onTap: () => context.push('/loans'),
          ),
        ),
        _SearchSection<TransactionModel>(
          title: 'Transactions',
          dataAsync: transactionsAsync,
          filter: (t) => (t.note?.toLowerCase() ?? '').contains(query.toLowerCase()),
          builder: (t) => _ResultTile(
            title: t.note ?? 'Transaction',
            subtitle: '${DateFormat.yMMMd().format(t.date)} • ${currencyFormat.format(t.amount)}',
            icon: Symbols.receipt_long,
            onTap: () {},
          ),
        ),
      ],
    );
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
              padding: const EdgeInsets.symmetric(vertical: 8),
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
    return ListTile(
      onTap: () {
        HapticService.selection();
        onTap();
      },
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Symbols.chevron_right, size: 20),
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
          Icon(Symbols.manage_search, size: 64, color: colorScheme.outline.withOpacity(0.5)),
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
              'Search transactions, people, goals, loans, and more in one place.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }
}
