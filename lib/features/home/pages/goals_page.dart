import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/widgets/icon_picker.dart';
import '../../../core/theme/color_extension.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final goalsAsync = ref.watch(goalsStreamProvider);
    final selectedCurrency = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.simpleCurrency(name: selectedCurrency);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Goals'),
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return const Center(
                child: Text('No goals set. Create one to start saving!'));
          }
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              if (goal.isDeleted) return const SizedBox.shrink();

              final percent = goal.targetAmount > 0
                  ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
                  : 0.0;
              final color = goal.color.parseHexColor();
              final isCompleted = goal.isCompleted;
              final colorScheme = theme.colorScheme;
              final isDark = theme.brightness == Brightness.dark;

              return Dismissible(
                key: ValueKey(goal.id),
                direction: DismissDirection.horizontal,
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    
                    goal.isCompleted = !isCompleted;
                    goal.updatedAt = DateTime.now();
                    await ref.read(goalRepositoryProvider).save(goal);
                    return false; // Don't actually dismiss the widget
                  } else {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Goal?'),
                        content: Text(
                            'Are you sure you want to delete "${goal.name}"?'),
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
                    return confirm;
                  }
                },
                onDismissed: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    
                    await ref.read(goalRepositoryProvider).delete(goal.id);
                  }
                },
                background: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.orange.withValues(alpha: 0.2) : colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 24),
                  child: Icon(isCompleted ? Symbols.undo : Symbols.check_circle,
                      color: isCompleted ? Colors.orange : colorScheme.onPrimaryContainer),
                ),
                secondaryBackground: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: Icon(Symbols.delete, color: colorScheme.onErrorContainer),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                        : (isDark ? colorScheme.surfaceContainer : colorScheme.surfaceContainerLow),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.4),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withValues(
                                    alpha: isCompleted ? 0.05 : (isDark ? 0.2 : 0.12)),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(AppIcons.getIcon(goal.icon),
                                  color: isCompleted
                                      ? color.withValues(alpha: 0.5)
                                      : color,
                                  size: 22),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: isCompleted ? Colors.grey : null,
                                    ),
                                  ),
                                  Text(
                                    'Target: ${currencyFormat.format(goal.targetAmount)}',
                                    style: TextStyle(
                                        color: theme
                                            .colorScheme.onSurfaceVariant
                                            .withValues(
                                                alpha:
                                                    isCompleted ? 0.5 : 1.0)),
                                  ),
                                ],
                              ),
                            ),
                            if (isCompleted)
                              const Icon(Symbols.check_circle,
                                  color: Colors.green)
                            else
                              IconButton(
                                icon: const Icon(Icons.edit_rounded),
                                onPressed: () =>
                                    context.push('/add_goal', extra: goal),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currencyFormat.format(goal.currentAmount),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted
                                      ? color.withValues(alpha: 0.5)
                                      : color),
                            ),
                            Text('${(percent * 100).toStringAsFixed(0)}%'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: percent,
                          backgroundColor: color.withValues(alpha: 0.1),
                          color: isCompleted ? Colors.green : color,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Deadline: ${DateFormat('MMM d, yyyy').format(goal.deadline)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isCompleted ? Colors.grey : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
