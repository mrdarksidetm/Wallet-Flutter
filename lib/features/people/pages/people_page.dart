import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/providers/fab_action_provider.dart';
import '../../../core/widgets/app_back_button.dart';
import '../widgets/person_avatar.dart';

class PeoplePage extends ConsumerStatefulWidget {
  const PeoplePage({super.key});

  @override
  ConsumerState<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends ConsumerState<PeoplePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(fabActionProvider.notifier)
          .setAction(() => _showAddPersonDialog(context, ref));
    });
  }

  @override
  void dispose() {
    try {
      ref.read(fabActionProvider.notifier).setAction(null);
    } catch (_) {
      // ref might be already disposed in some unmount scenarios
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final peopleAsync = ref.watch(personsStreamProvider);
    final loansAsync = ref.watch(loansStreamProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final currency = ref.watch(currencyProvider);
    final format = NumberFormat.simpleCurrency(name: currency);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            leading: const AppBackButton(),
            title: Text(
              'People',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          peopleAsync.when(
            data: (people) {
              if (people.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Symbols.group_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No people added yet'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _showAddPersonDialog(context, ref),
                          child: const Text('Add your first contact'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final loans = loansAsync.value ?? [];
              final txs = transactionsAsync.value ?? [];
              final isDark = theme.brightness == Brightness.dark;

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.builder(
                  itemCount: people.length,
                  itemBuilder: (context, index) {
                    final person = people[index];
                    
                    // Calculate stats for this person
                    final personLoans = loans.where((l) => l.person.value?.id == person.id && l.isActive && !l.isPaid);
                    double totalDebt = 0;
                    for (var l in personLoans) {
                      if (l.type == LoanType.lent) {
                        totalDebt += l.amount;
                      } else {
                        totalDebt -= l.amount;
                      }
                    }

                    final personTxs = txs.where((t) => t.person.value?.id == person.id);
                    final txCount = personTxs.length;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? colorScheme.surfaceContainer : colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.4),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.push('/person_details', extra: person),
                          onLongPress: () => _showDeleteConfirmation(context, ref, person),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                PersonAvatar(
                                  person: person,
                                  radius: 24,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        person.name,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$txCount transaction${txCount == 1 ? '' : 's'}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      totalDebt == 0 ? 'Settled' : (totalDebt > 0 ? 'Owes you' : 'You owe'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: totalDebt == 0 ? colorScheme.onSurfaceVariant : (totalDebt > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                                      ),
                                    ),
                                    if (totalDebt != 0)
                                      Text(
                                        format.format(totalDebt.abs()),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          color: totalDebt > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
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

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Person person) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Person?'),
        content: Text('Are you sure you want to delete ${person.name}? This will NOT delete their transaction history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(personServiceProvider).deletePerson(person.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddPersonDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Person'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name', hintText: 'Enter name...'),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final person = Person()
                  ..name = nameController.text
                  ..color = '0x${Colors.blue.value.toRadixString(16).toUpperCase()}'
                  ..createdAt = DateTime.now()
                  ..updatedAt = DateTime.now();
                await ref.read(personServiceProvider).savePerson(person);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ).then((_) => nameController.dispose());
  }
}
