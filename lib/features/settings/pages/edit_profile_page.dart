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
          'Edit Profile',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 64,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: _selectedImagePath != null
                      ? FileImage(File(_selectedImagePath!))
                      : null,
                  child: _selectedImagePath == null
                      ? Icon(
                          Symbols.person_rounded,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: FloatingActionButton.small(
                    onPressed: _pickAndCropImage,
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Symbols.photo_camera_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PERSONAL INFO',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Display Name',
                    hintText: 'Enter your name',
                    prefixIcon: const Icon(Symbols.badge_rounded),
                    filled: true,
                    fillColor:
                        colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          PrimaryAtelierButton(
            onPressed: _save,
            icon: const Icon(Symbols.check_rounded, color: Colors.white),
            label: const Text(
              'Save Changes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
