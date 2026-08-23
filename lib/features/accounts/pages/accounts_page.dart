import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/color_extension.dart';
import '../../../core/services/currency_engine.dart';
import '../../../core/widgets/app_back_button.dart';

import '../../../core/database/providers.dart';
import '../../../core/database/models/account.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/database/models/category.dart';
import '../widgets/account_card.dart';
import '../widgets/category_segmented_bar.dart';
import '../../../core/widgets/transaction_list_tile.dart';
import '../../../core/widgets/icon_picker.dart';

class AccountsPage extends ConsumerStatefulWidget {
  const AccountsPage({super.key});

  @override
  ConsumerState<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends ConsumerState<AccountsPage> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accountsAsync = ref.watch(accountsStreamProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return CustomScrollView(
              slivers: [
                SliverAppBar.medium(
                  leading: const AppBackButton(),
                  title: Text(
                    'Accounts & Wallets',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No accounts found')),
                ),
              ],
            );
          }

          final pageIndex = _currentPage.clamp(0, accounts.length - 1);
          final currentAccount = accounts[pageIndex];
          
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar.medium(
                leading: const AppBackButton(),
                title: Text(
                  'Accounts & Wallets',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Symbols.reorder),
                    onPressed: () {
                      final accs = accountsAsync.value?.toList() ?? <Account>[];
                      _showReorderBottomSheet(context, accs);
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              // 1. Top Section: Swipeable Cards
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: accounts.length,
                        onPageChanged: (index) => setState(() => _currentPage = index),
                        itemBuilder: (context, index) {
                          return AccountCard(
                            account: accounts[index],
                            onEdit: () => context.push('/add_account', extra: accounts[index]),

                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: accounts.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: currentAccount.color.parseHexColor(),
                        dotColor: colorScheme.outlineVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // 2. Middle Section: Stats & Segmented Bar
              SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, _) {
                    final txsAsync = ref.watch(accountTransactionsProvider(currentAccount.id));
                    return txsAsync.when(
                      data: (txs) => _buildStatsSection(context, txs, currency),
                      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                ),
              ),

              // 3. Bottom Section: Recent Activity
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'RECENT ACTIVITY',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),

              Consumer(
                builder: (context, ref, _) {
                  final txsAsync = ref.watch(accountTransactionsProvider(currentAccount.id));
                  return txsAsync.when(
                    data: (txs) {
                      if (txs.isEmpty) {
                        return const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: Text('No activity for this account')),
                        );
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildTransactionItem(context, txs[index]),
                          childCount: txs.length,
                        ),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                    error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, List<TransactionModel> txs, String currency) {
    double tempIncome = 0;
    double tempExpense = 0;
    final Map<int, double> categoryExpenses = {};
    final Map<int, Category> categoryMap = {};

    for (var tx in txs) {
      if (tx.type == TransactionType.income) {
        tempIncome += tx.amount;
      } else if (tx.type == TransactionType.expense) {
        tempExpense += tx.amount;
        final cat = tx.category.value;
        if (cat != null) {
          categoryExpenses[cat.id] = (categoryExpenses[cat.id] ?? 0) + tx.amount;
          categoryMap[cat.id] = cat;
        }
      }
    }

    final double totalIncome = tempIncome;
    final double totalExpense = tempExpense;

    final segments = categoryExpenses.entries.map((e) {
      final cat = categoryMap[e.key]!;
      return CategorySegmentData(
        color: cat.color.parseHexColor(),
        percentage: totalExpense > 0 ? e.value / totalExpense : 0,
        name: cat.name,
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatCard(context, 'Income', totalIncome, const Color(0xFF10B981), Symbols.trending_up, currency),
              const SizedBox(width: 16),
              _buildStatCard(context, 'Expense', totalExpense, const Color(0xFFEF4444), Symbols.trending_down, currency),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Spending by Category',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          CategorySegmentedBar(segments: segments),
          const SizedBox(height: 16),
          // Mini Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: segments.take(4).map((s) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(s.name, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, double amount, Color color, IconData icon, String currency) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyEngine.formatCurrency(amount, currency),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionModel tx) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TransactionListTile(
        tx: tx,
        onTap: () => context.push('/add_transaction', extra: tx),
      ),
    );
  }

  void _showReorderBottomSheet(BuildContext context, List<Account> accounts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Reorder Accounts',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Drag and drop to change display order',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ReorderableListView.builder(
                        scrollController: scrollController,
                        itemCount: accounts.length,
                        onReorder: (oldIndex, newIndex) {
                          setModalState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final item = accounts.removeAt(oldIndex);
                            accounts.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          final acc = accounts[index];
                          final color = acc.color.parseHexColor();
                          return ListTile(
                            key: ValueKey('reorder-${acc.id}'),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(AppIcons.getIcon(acc.icon), color: color, size: 20),
                            ),
                            title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            trailing: const Icon(Icons.drag_indicator_rounded, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            await ref.read(accountServiceProvider).updateAccountsOrder(accounts);
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: const Text('Save Order'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
