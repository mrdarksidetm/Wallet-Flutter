import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/models/category.dart';
import '../../../core/database/providers.dart';
import '../../../core/widgets/icon_picker.dart';
import '../../../core/theme/color_extension.dart';
import '../widgets/settings_segmented_card.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Symbols.arrow_back_rounded),
        ),
        title: Text(
          'Categories',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Symbols.category_rounded,
                    size: 56,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No categories found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap the button below to create your first category',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          final expenseCategories =
              categories.where((c) => c.type == CategoryType.expense).toList();
          final incomeCategories =
              categories.where((c) => c.type == CategoryType.income).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              if (expenseCategories.isNotEmpty) ...[
                _buildSectionHeader(context, 'EXPENSE CATEGORIES (${expenseCategories.length})'),
                const SizedBox(height: 8),
                SettingsSegmentedGroup(
                  children: expenseCategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    final isLast = index == expenseCategories.length - 1;
                    final color = category.color.parseHexColor();

                    final budgetText = category.budgetLimit != null
                        ? 'Budget: ${currencyFormat.format(category.budgetLimit)}'
                        : 'No monthly limit set';

                    return SettingsActionTile(
                      customLeading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Icon(
                            AppIcons.getIcon(category.icon),
                            color: color,
                            size: 24,
                          ),
                        ),
                      ),
                      title: category.name,
                      subtitle: budgetText,
                      showDivider: !isLast,
                      onTap: () => context.push('/add_category', extra: category),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
              if (incomeCategories.isNotEmpty) ...[
                _buildSectionHeader(context, 'INCOME CATEGORIES (${incomeCategories.length})'),
                const SizedBox(height: 8),
                SettingsSegmentedGroup(
                  children: incomeCategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    final isLast = index == incomeCategories.length - 1;
                    final color = category.color.parseHexColor();

                    return SettingsActionTile(
                      customLeading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Icon(
                            AppIcons.getIcon(category.icon),
                            color: color,
                            size: 24,
                          ),
                        ),
                      ),
                      title: category.name,
                      subtitle: 'Income Stream',
                      showDivider: !isLast,
                      onTap: () => context.push('/add_category', extra: category),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add_category'),
        label: const Text(
          'New Category',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Symbols.add_rounded),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w900,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
      ),
    );
  }
}
