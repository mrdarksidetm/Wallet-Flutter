import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/providers/fab_action_provider.dart';

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
      ref.read(fabActionProvider.notifier).setAction(() => _showAddPersonDialog(context, ref));
    });
  }

  @override
  void dispose() {
    // Note: We don't want to clear if navigating to another page that might set it,
    // but usually, it's good practice. However, GoRouter Shell FAB rebuilds based on location.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peopleAsync = ref.watch(personsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
      ),
      body: peopleAsync.when(
        data: (people) {
          if (people.isEmpty) {
            return const Center(child: Text('No people found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: people.length,
            itemBuilder: (context, index) {
              final person = people[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(person.name[0].toUpperCase()),
                  ),
                  title: Text(person.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: person.contact != null ? Text(person.contact!) : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    onPressed: () => _showDeleteDialog(context, ref, person),
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

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Person person) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Person?'),
        content: Text('Remove ${person.name} from your contacts? Loans associated with this person will remain but the person link will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(personServiceProvider).deletePerson(person.id);
              await HapticService.errorStatic();
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
      builder: (context) => AlertDialog(
        title: const Text('Add Person'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final person = Person()
                  ..name = nameController.text
                  ..color = '0xFF2196F3'
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
