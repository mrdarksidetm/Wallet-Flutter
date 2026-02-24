import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:wallet/core/theme/color_extension.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../shared/widgets/paisa_list_tile.dart';
import '../../../shared/widgets/app_button.dart';

class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personsAsync = ref.watch(personsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('People & Payees')),
      body: personsAsync.when(
        data: (persons) {
          if (persons.isEmpty) return const Center(child: Text('No people listed.'));
          
          return ListView.builder(
            itemCount: persons.length,
            itemBuilder: (context, index) {
              final person = persons[index];
              final color = (person.color).parseHexColor();
              
              return PaisaListTile(
                title: person.name,
                subtitle: person.contact ?? 'No contact info',
                icon: Icons.person,
                iconColor: Colors.white,
                iconBackgroundColor: color,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => ref.read(personServiceProvider).deletePerson(person.id),
                ),
                onTap: () => _showAddEditPersonDialog(context, ref, person),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditPersonDialog(context, ref, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditPersonDialog(BuildContext context, WidgetRef ref, Person? person) {
    showDialog(
      context: context,
      builder: (_) => AddEditPersonDialog(person: person),
    );
  }
}

class AddEditPersonDialog extends ConsumerStatefulWidget {
  final Person? person;
  const AddEditPersonDialog({super.key, this.person});

  @override
  ConsumerState<AddEditPersonDialog> createState() => _AddEditPersonDialogState();
}

class _AddEditPersonDialogState extends ConsumerState<AddEditPersonDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _contact;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _name = widget.person?.name ?? '';
    _contact = widget.person?.contact ?? '';
    _color = widget.person != null ? (widget.person!.color).parseHexColor() : Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.person == null ? 'New Person' : 'Edit Person'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => _name = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _contact,
                decoration: const InputDecoration(labelText: 'Contact / Details (Optional)'),
                onSaved: (val) => _contact = val ?? '',
              ),
              const SizedBox(height: 24),
              ListTile(
                title: const Text('Badge Color'),
                trailing: ColorIndicator(
                  width: 32,
                  height: 32,
                  borderRadius: 16,
                  color: _color,
                  onSelectFocus: false,
                  onSelect: () async {
                    final Color newColor = await showColorPickerDialog(
                      context,
                      _color,
                      title: Text('Select Color', style: Theme.of(context).textTheme.titleLarge),
                      pickersEnabled: const <ColorPickerType, bool>{ColorPickerType.wheel: true},
                    );
                    setState(() => _color = newColor);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        AppButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              
              final colorString = '0x${_color.value.toRadixString(16).padLeft(8, '0')}';
              
              if (widget.person == null) {
                await ref.read(personServiceProvider).addPerson(
                  name: _name,
                  color: colorString,
                  contact: _contact.isEmpty ? null : _contact,
                );
              } else {
                final upd = Person()
                  ..id = widget.person!.id
                  ..name = _name
                  ..color = colorString
                  ..contact = _contact.isEmpty ? null : _contact
                  ..createdAt = widget.person!.createdAt;
                await ref.read(personServiceProvider).updatePerson(widget.person!, upd);
              }
              if (mounted) Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
