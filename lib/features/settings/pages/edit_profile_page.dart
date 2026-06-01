import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/widgets/primary_atelier_button.dart';
import '../../../core/services/file_service.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _nameController;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    final state = ref.read(personalizationProvider);
    _nameController = TextEditingController(text: state.userName);
    _selectedImagePath = state.userPhoto;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndCropImage() async {
    final picker = ImagePicker();
    final colorScheme = Theme.of(context).colorScheme;

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Photo',
          // [ACTION]: Setting the toolbar color for the cropper.
          // [M3 UPDATE]: Using surfaceContainerHighest instead of deprecated surfaceVariant.
          toolbarColor: colorScheme.surfaceContainerHighest,
          // [ACTION]: Setting the widget/text color for the cropper toolbar.
          // [M3 UPDATE]: Using onSurfaceVariant for correct contrast and accessibility.
          toolbarWidgetColor: colorScheme.onSurfaceVariant,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Profile Photo',
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _selectedImagePath = croppedFile.path;
      });
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    String? finalPhotoPath = _selectedImagePath;
    final currentState = ref.read(personalizationProvider);
    
    // [ACTION]: Only persist the image if it's a new selection (different from current).
    if (_selectedImagePath != null && _selectedImagePath != currentState.userPhoto) {
      finalPhotoPath = await FileService.saveImagePermanently(_selectedImagePath!);
    }
    
    ref.read(personalizationProvider.notifier).updateProfile(
      name: _nameController.text,
      photo: finalPhotoPath,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: _selectedImagePath != null 
                      ? FileImage(File(_selectedImagePath!)) 
                      : null,
                  child: _selectedImagePath == null 
                      ? Icon(Symbols.person, size: 60, color: colorScheme.onSurfaceVariant) 
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: FloatingActionButton.small(
                    onPressed: _pickAndCropImage,
                    // [ACTION]: Setting background color for the photo picker action.
                    // [M3 UPDATE]: Using primaryContainer to provide a clear interactive signal.
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    elevation: 0,
                    child: const Icon(Symbols.photo_camera),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          // [ACTION]: Using a container with surfaceContainerHighest for grouping.
          // [M3 UPDATE]: Replacing hardcoded grey containers with M3 tone-based surface.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                prefixIcon: Icon(Symbols.person),
                hintText: 'Enter your name',
                filled: true,
                fillColor: Colors.transparent, // Let container handle it
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          const SizedBox(height: 48),
          PrimaryAtelierButton(
            onPressed: _save,
            icon: Icon(Symbols.save, color: colorScheme.onPrimary),
            label: Text(
              'Save Changes',
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
