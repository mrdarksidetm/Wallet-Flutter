import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/widgets/primary_atelier_button.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: ref.read(personalizationProvider).userName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) return;
    
    ref.read(personalizationProvider.notifier).updateProfile(name: _nameController.text);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final photo = ref.watch(personalizationProvider).userPhoto;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: photo != null ? FileImage(File(photo)) : null,
                  child: photo == null ? const Icon(Symbols.person, size: 60) : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: FloatingActionButton.small(
                    onPressed: () {
                      // TODO: Implement image picker
                    },
                    child: const Icon(Symbols.photo_camera),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              prefixIcon: Icon(Symbols.person),
              hintText: 'Enter your name',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 48),
          PrimaryAtelierButton(
            onPressed: _save,
            icon: const Icon(Symbols.save, color: Colors.white),
            label: const Text(
              'Save Changes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
