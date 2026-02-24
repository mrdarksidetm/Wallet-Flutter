import 'package:flutter/material.dart';
import 'package:wallet/core/theme/color_extension.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/database/models/account.dart';
import '../../../core/database/models/category.dart';
import '../../../shared/widgets/paisa_list_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  List<TransactionModel> _results = [];
  bool _isLoading = false;

  DateTime? _startDate;
  DateTime? _endDate;
  TransactionType? _type;
  Account? _account;
  Category? _category;

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(transactionRepositoryProvider);
      final results = await repo.search(
        query: _searchController.text.isEmpty ? null : _searchController.text,
        startDate: _startDate,
        endDate: _endDate,
        type: _type,
        accountIds: _account != null ? [_account!.id] : null,
        categoryIds: _category != null ? [_category!.id] : null,
      );
      setState(() => _results = results);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider);


    return Scaffold(
      appBar: AppBar(title: const Text('Search Transactions')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search notes...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _performSearch,
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Date Filter
                      ActionChip(
                        label: Text(_startDate == null ? 'Date Range' : '${DateFormat('MM/dd').format(_startDate!)} - ${DateFormat('MM/dd').format(_endDate!)}'),
                        onPressed: () async {
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (range != null) {
                            setState(() {
                              _startDate = range.start;
                              _endDate = range.end.add(const Duration(days: 1) - const Duration(seconds: 1));
                            });
                            _performSearch();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      // Type Filter
                      DropdownButton<TransactionType>(
                        hint: const Text('Type'),
                        value: _type,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Types')),
                          ...TransactionType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))),
                        ],
                        onChanged: (val) {
                          setState(() => _type = val);
                          _performSearch();
                        },
                      ),
                      const SizedBox(width: 8),
                      // Account Filter
                      accountsAsync.when(
                        data: (accounts) => DropdownButton<Account>(
                          hint: const Text('Account'),
                          value: accounts.any((a) => a.id == _account?.id) ? accounts.firstWhere((a) => a.id == _account?.id) : null,
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Accounts')),
                            ...accounts.map((a) => DropdownMenuItem(value: a, child: Text(a.name))),
                          ],
                          onChanged: (val) {
                            setState(() => _account = val);
                            _performSearch();
                          },
                        ),
                        loading: () => const SizedBox(),
                        error: (_,__) => const SizedBox(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
             child: _isLoading 
                 ? const Center(child: CircularProgressIndicator())
                 : ListView.builder(
                     itemCount: _results.length,
                     itemBuilder: (context, index) {
                       final tx = _results[index];
                       return PaisaListTile(
                         title: tx.category.value?.name ?? 'Unknown',
                         subtitle: '${DateFormat.yMMMd().format(tx.date)}${tx.note != null && tx.note!.isNotEmpty ? ' • ${tx.note}' : ""}',
                         amount: '${tx.type == TransactionType.expense ? '-' : '+'}\$${tx.amount.toStringAsFixed(2)}',
                         amountColor: tx.type == TransactionType.expense ? Colors.red : Colors.green,
                         icon: Icons.category,
                         iconColor: Colors.white,
                         iconBackgroundColor: (tx.category.value?.color ?? '0xFF9E9E9E').parseHexColor(),
                       );
                     },
                   ),
          ),
        ],
      ),
    );
  }
}
