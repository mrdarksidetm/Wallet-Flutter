import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/providers/fab_action_provider.dart';
import '../../../core/theme/color_extension.dart';

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
    final peopleAsync = ref.watch(personsStreamProvider);
    final loansAsync = ref.watch(loansStreamProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final currency = ref.watch(currencyProvider);
    final format = NumberFormat.simpleCurrency(name: currency);

    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
      ),
      body: peopleAsync.when(
        data: (people) {
          if (people.isEmpty) {
            return Center(
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
            );
          }

          final loans = loansAsync.value ?? [];
          final txs = transactionsAsync.value ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
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

              final color = person.color.parseHexColor();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: InkWell(
                  onTap: () => context.push('/person_details', extra: person),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: color.withValues(alpha: 0.1),
                          child: Text(
                            person.name[0].toUpperCase(),
                            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                person.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Symbols.receipt_long, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text('$txCount transactions', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                ],
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
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: totalDebt == 0 ? Colors.grey : (totalDebt > 0 ? Colors.green : Colors.red),
                              ),
                            ),
                            if (totalDebt != 0)
                              Text(
                                format.format(totalDebt.abs()),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: totalDebt > 0 ? Colors.green : Colors.red,
                                ),
                              ),
                          ],
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

  void _showAddPersonDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Person'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name', hintText: 'Enter name...'),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
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
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
