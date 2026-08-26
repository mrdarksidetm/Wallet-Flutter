import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/activity_insights_section.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/widgets/transaction_segmented_group.dart';
import '../../../core/services/currency_engine.dart';
import '../../../core/theme/personalization_provider.dart';
import '../widgets/animated_balance_hero.dart';
import '../widgets/overview_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildDynamicShadowLogo() {
    const double logoSize = 32.0;
    const String logoPath = 'assets/images/logo.svg';

    return Stack(
      children: [
        Transform.translate(
          offset: const Offset(0, 3),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Opacity(
              opacity: 0.3,
              child: SvgPicture.asset(
                logoPath,
                width: logoSize,
                height: logoSize,
              ),
            ),
          ),
        ),
        SvgPicture.asset(
          logoPath,
          width: logoSize,
          height: logoSize,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final personalization = ref.watch(personalizationProvider);
    final userName = personalization.userName ?? 'User';
    
    final backgroundColor = isDark ? colorScheme.surface : const Color(0xFFF7F7F9);

    return Container(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SCROLLABLE CONTENT
          Expanded(
            child: AnimationLimiter(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // FIXED HEADER
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    backgroundColor: backgroundColor,
                    surfaceTintColor: backgroundColor,
                    elevation: 0,
                    leadingWidth: 72,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Center(child: _buildDynamicShadowLogo()),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Symbols.settings),
                        onPressed: () => context.push('/settings'),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => context.push('/edit_profile'),
                        child: () {
                          final photoPath = personalization.userPhoto;
                          final bool hasValidPhoto = photoPath != null && File(photoPath).existsSync();
                          
                          return CircleAvatar(
                            radius: 18,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            backgroundImage: hasValidPhoto 
                                ? FileImage(File(photoPath)) 
                                : null,
                            child: !hasValidPhoto
                                ? Icon(
                                    Symbols.person,
                                    size: 18,
                                    color: colorScheme.onSurfaceVariant,
                                  )
                                : null,
                          );
                        }(),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  
                  // SCROLLABLE GREETING
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Text(
                        '${_getGreeting()}, $userName',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: _HomeBalanceSection()),
                  const _SectionHeader(title: 'Overview'),
                  const _HomeFinanceGrid(),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  const _SectionHeader(title: 'Activity Insights'),
                  const SliverToBoxAdapter(child: ActivityInsightsSection()),
                  const SliverToBoxAdapter(
                      child: _HomeRecentTransactionsSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 60)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

class _HomeBalanceSection extends ConsumerWidget {
  const _HomeBalanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBalanceAsync = ref.watch(totalBalanceProvider);
    final monthlyStatsAsync = ref.watch(monthlyStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: totalBalanceAsync.when(
        data: (total) => monthlyStatsAsync.when(
          data: (stats) => AnimatedBalanceHero(
            totalBalance: total,
            monthlyIncome: stats['income'] ?? 0.0,
            monthlyExpense: stats['expense'] ?? 0.0,
          ),
          loading: () => const _LoadingBalance(),
          error: (_, __) => const _LoadingBalance(),
        ),
        loading: () => const _LoadingBalance(),
        error: (_, __) => const _LoadingBalance(),
      ),
    );
  }
}

class _LoadingBalance extends StatelessWidget {
  const _LoadingBalance();
  @override
  Widget build(BuildContext context) => const AnimatedBalanceHero(
      totalBalance: 0, monthlyIncome: 0, monthlyExpense: 0);
}

class _HomeFinanceGrid extends ConsumerWidget {
  const _HomeFinanceGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalAssetBalanceAsync = ref.watch(totalAssetBalanceProvider);
    // Watch accountsStreamProvider to ensure the grid updates when accounts change
    ref.watch(accountsStreamProvider);
    final selectedCurrency = ref.watch(currencyProvider);

    final colorScheme = Theme.of(context).colorScheme;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        delegate: SliverChildListDelegate([
          OverviewCard(
            icon: Symbols.account_balance,
            title: 'Accounts',
            accentColor: colorScheme.primary,
            subtitle: totalAssetBalanceAsync.when(
              data: (v) => '${CurrencyEngine.formatCurrency(v, selectedCurrency)} total',
              loading: () => '...',
              error: (_, __) => 'Error',
            ),
            onTap: () => context.go('/accounts'),
          ),
          OverviewCard(
            icon: Symbols.pie_chart,
            title: 'Budgets',
            accentColor: colorScheme.secondary,
            subtitle: 'Track spending',
            onTap: () => context.push('/budgets'),
          ),
          OverviewCard(
            icon: Symbols.flag,
            title: 'Goals',
            accentColor: colorScheme.tertiary,
            subtitle: 'Savings targets',
            onTap: () => context.push('/goals'),
          ),
          OverviewCard(
            icon: Symbols.front_loader,
            title: 'Loans',
            accentColor: const Color(0xFFF59E0B),
            subtitle: 'Debts & lending',
            onTap: () => context.push('/loans'),
          ),
          OverviewCard(
            icon: Symbols.event_repeat,
            title: 'Recurring',
            accentColor: const Color(0xFF8B5CF6),
            subtitle: 'Subscription & bills',
            onTap: () => context.push('/recurring'),
          ),
          OverviewCard(
            icon: Symbols.category,
            title: 'Categories',
            accentColor: const Color(0xFFEC4899),
            subtitle: 'Manage groups',
            onTap: () => context.push('/categories'),
          ),
          OverviewCard(
            icon: Symbols.call_split,
            title: 'Bill Splitter',
            accentColor: const Color(0xFF06B6D4),
            subtitle: 'Shared expenses',
            onTap: () => context.push('/bill_splitter'),
          ),
          OverviewCard(
            icon: Symbols.group,
            title: 'People',
            accentColor: const Color(0xFF10B981),
            subtitle: 'Friends & contacts',
            onTap: () => context.push('/people'),
          ),
        ]),
      ),
    );
  }
}

class _HomeRecentTransactionsSection extends ConsumerStatefulWidget {
  const _HomeRecentTransactionsSection();

  @override
  ConsumerState<_HomeRecentTransactionsSection> createState() =>
      _HomeRecentTransactionsSectionState();
}

class _HomeRecentTransactionsSectionState
    extends ConsumerState<_HomeRecentTransactionsSection> {
  TransactionType? _typeFilter;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(allTransactionsStreamProvider);
    final sortType = ref.watch(transactionSortProvider);
    final accountsAsync = ref.watch(accountsStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.65)
            : colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle accent for squircle section feel
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Heading row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    letterSpacing: -0.5,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/all_transactions'),
                  icon: const Icon(Symbols.chevron_right_rounded, size: 18),
                  label: const Text(
                    'View all',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ),
          // Pill-shaped filters row below heading
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildPill(
                    context: context,
                    icon: Symbols.calendar_month_rounded,
                    label: 'Date',
                    isSelected: sortType == TransactionSort.date,
                    onTap: () {
                      ref.read(transactionSortProvider.notifier).state =
                          TransactionSort.date;
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildPill(
                    context: context,
                    icon: Symbols.account_balance_wallet_rounded,
                    label: 'Account',
                    isSelected: sortType == TransactionSort.account,
                    onTap: () {
                      ref.read(transactionSortProvider.notifier).state =
                          TransactionSort.account;
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildPill(
                    context: context,
                    icon: _typeFilter == null
                        ? Symbols.filter_list_rounded
                        : _typeFilter == TransactionType.income
                            ? Symbols.arrow_downward_rounded
                            : _typeFilter == TransactionType.expense
                                ? Symbols.arrow_upward_rounded
                                : Symbols.sync_alt_rounded,
                    label: _typeFilter == null
                        ? 'All'
                        : _typeFilter!.name.toUpperCase(),
                    isSelected: _typeFilter != null,
                    onTap: () {
                      setState(() {
                        if (_typeFilter == null) {
                          _typeFilter = TransactionType.expense;
                        } else if (_typeFilter == TransactionType.expense) {
                          _typeFilter = TransactionType.income;
                        } else if (_typeFilter == TransactionType.income) {
                          _typeFilter = TransactionType.transfer;
                        } else {
                          _typeFilter = null;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // Transactions list
          transactionsAsync.when(
            data: (transactions) {
              var filtered = transactions;
              if (_typeFilter != null) {
                filtered =
                    filtered.where((t) => t.type == _typeFilter).toList();
              }
              if (filtered.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Text('No activity found'),
                  ),
                );
              }

              final sortedTxs = [...filtered];
              if (sortType == TransactionSort.date) {
                // date desc
              } else if (sortType == TransactionSort.account) {
                accountsAsync.whenData((accounts) {
                  sortedTxs.sort((a, b) {
                    final accA = accounts
                        .where((acc) => acc.id == a.accountId)
                        .firstOrNull;
                    final accB = accounts
                        .where((acc) => acc.id == b.accountId)
                        .firstOrNull;

                    final nameA = accA?.name ?? '';
                    final nameB = accB?.name ?? '';

                    final accountCompare = nameA.compareTo(nameB);
                    if (accountCompare != 0) return accountCompare;
                    return b.date.compareTo(a.date);
                  });
                });
              }

              final recentTxs = sortedTxs.take(10).toList();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TransactionGroupedList(
                  transactions: recentTxs,
                  onTap: (tx) => context.push('/add_transaction', extra: tx),
                ),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text('Error: $err'),
              ),
            ),
          ),
          // View All Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: FilledButton.tonal(
              onPressed: () => context.push('/all_transactions'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor:
                    colorScheme.primaryContainer.withValues(alpha: 0.4),
                foregroundColor: colorScheme.primary,
              ),
              child: const Text(
                'View All Transactions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.4)
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

