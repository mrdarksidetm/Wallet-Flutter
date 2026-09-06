import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/widgets/icon_picker.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/theme/color_extension.dart';

class RecurringPage extends ConsumerWidget {
  const RecurringPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recurringAsync = ref.watch(recurringsStreamProvider);
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            leading: const AppBackButton(),
            title: Text(
              'Recurring',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          recurringAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No recurring transactions found')),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final categoryColor = item.category.value?.color != null
                        ? item.category.value!.color.parseHexColor()
                        : theme.colorScheme.primary;
                    final isActive = item.isActive;
                    final isDark = theme.brightness == Brightness.dark;

              return Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.horizontal,
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    item.isActive = !isActive;
                    item.updatedAt = DateTime.now();
                    await ref
                        .read(recurringServiceProvider)
                        .saveRecurring(item);
                    return false;
                  } else {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Recurring?'),
                        content: const Text(
                            'Are you sure you want to delete this recurring transaction?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                                foregroundColor: colorScheme.error),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                onDismissed: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    await ref
                        .read(recurringServiceProvider)
                        .deleteRecurring(item.id);
                  }
                },
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.orange.withValues(alpha: 0.2) : colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 24),
                  child: Icon(isActive ? Symbols.cancel : Symbols.check_circle,
                      color: isActive ? Colors.orange : colorScheme.onPrimaryContainer),
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
                    color: isActive
                        ? (isDark ? colorScheme.surfaceContainer : colorScheme.surfaceContainerLow)
                        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.4),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    onTap: () => context.push('/add_recurring', extra: item),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(
                            alpha: isActive ? (isDark ? 0.2 : 0.12) : 0.05),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                          AppIcons.getIcon(
                              item.category.value?.icon ?? 'repeat'),
                          color: isActive
                              ? categoryColor
                              : categoryColor.withValues(alpha: 0.5),
                          size: 22),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration:
                            isActive ? null : TextDecoration.lineThrough,
                        color: isActive ? null : Colors.grey,
                      ),
                    ),
                    subtitle: Text(
                      'Next: ${DateFormat('MMM d').format(item.nextDate)} • ${item.frequency.name.toUpperCase()} • ${item.notifyOneDayBefore ? '1d before' : 'Same day'}',
                      style: TextStyle(color: isActive ? null : Colors.grey),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(item.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isActive ? null : Colors.grey,
                          ),
                        ),
                        Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isActive ? const Color(0xFF10B981) : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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
}
