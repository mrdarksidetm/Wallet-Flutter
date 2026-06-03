import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:restart_app/restart_app.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui';
import '../../../core/theme/personalization_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/services/file_service.dart';
import '../../../core/database/providers.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  double _currentPage = 0;

  final _nameController = TextEditingController();
  final _focusNode = FocusNode();
  String? _selectedCurrency;
  String? _imagePath;

  bool _showBlueScreen = false;
  double _rippleRadius = 0;
  Offset _rippleOffset = Offset.zero;

  bool _storagePermissionGranted = false;
  bool _notificationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _pageController = PageController();
    _pageController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPage = _pageController.page ?? 0;
        });
      }
    });
  }

  Future<void> _checkPermissions() async {
    final storageStatus = Platform.isAndroid 
        ? await Permission.manageExternalStorage.status 
        : await Permission.storage.status;
    final notificationStatus = await Permission.notification.status;
    
    if (mounted) {
      setState(() {
        _storagePermissionGranted = storageStatus.isGranted;
        _notificationPermissionGranted = notificationStatus.isGranted;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Profile Photo',
              toolbarColor: Theme.of(context).colorScheme.primary,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: 'Crop Profile Photo',
              aspectRatioLockEnabled: true,
            ),
          ],
        );
        if (croppedFile != null) {
          setState(() {
            _imagePath = croppedFile.path;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking/cropping image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  bool _canGoNext(double progress) {
    if (progress >= 0.5 && progress < 1.5) {
      return _nameController.text.trim().isNotEmpty;
    }
    if (progress >= 1.5 && progress < 2.5) {
      return _selectedCurrency != null;
    }
    return true;
  }

  void _nextPage() {
    if (!_canGoNext(_currentPage)) {
      String message = '';
      if (_currentPage >= 0.5 && _currentPage < 1.5) message = 'Please enter your name';
      if (_currentPage >= 1.5 && _currentPage < 2.5) message = 'Please select a currency';
      
      if (message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
        );
      }
      return;
    }

    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    String? finalPhotoPath = _imagePath;
    if (_imagePath != null) {
      finalPhotoPath = await FileService.saveImagePermanently(_imagePath!);
    }

    ref.read(personalizationProvider.notifier).completeOnboarding(
          name: _nameController.text,
          currency: _selectedCurrency ?? 'USD',
          photo: finalPhotoPath,
        );
  }

  Future<void> _restoreBackup() async {
    try {
      final success = await ref.read(backupServiceProvider).restoreBackup();
      if (success && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Restore Successful'),
            content: const Text(
                'Your data and settings have been restored. The app will now restart to apply changes.'),
            actions: [
              FilledButton(
                onPressed: () => Restart.restartApp(),
                child: const Text('Restart App'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    }
  }

  void _startRippleAnimation(TapUpDetails details) {
    setState(() {
      _rippleOffset = details.globalPosition;
      _showBlueScreen = true;
    });
    
    // Animate ripple radius
    Future.delayed(Duration.zero, () {
      if (mounted) {
        setState(() {
          _rippleRadius = MediaQuery.of(context).size.longestSide * 1.5;
        });
      }
    });

    // Navigate after animation
    Future.delayed(const Duration(milliseconds: 800), () {
      _finishOnboarding();
    });
  }

  Widget _buildDynamicShadowLogo() {
    const double logoSize = 48.0;
    const String logoPath = 'assets/images/logo.svg';

    return Stack(
      children: [
        Transform.translate(
          offset: const Offset(0, 4),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Opacity(
              opacity: 0.4,
              child: SvgPicture.asset(
                logoPath,
                width: logoSize,
                height: logoSize,
              ),
            ),
          ),
        ),
        SvgPicture.asset(
          logoPath,
          width: logoSize,
          height: logoSize,
        ),
      ],
    );
  }

  Widget _buildThemeToggle(ColorScheme colorScheme) {
    final themeMode = ref.watch(themeControllerProvider).themeMode;
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return IconButton.filledTonal(
      onPressed: () {
        ref.read(themeControllerProvider.notifier).setThemeMode(
              isDarkMode ? ThemeMode.light : ThemeMode.dark,
            );
      },
      icon: Icon(
        isDarkMode ? Symbols.light_mode : Symbols.dark_mode,
        size: 24,
      ),
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        foregroundColor: colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // PageView for 5 pages
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildWelcomePage(theme, colorScheme),
                _buildProfilePage(theme, colorScheme, bottomInset),
                _buildCurrencyPage(theme, colorScheme),
                _buildPermissionsPage(theme, colorScheme),
                _buildFinalPage(theme, colorScheme),
              ],
            ),

            // Navigation Buttons
            _buildNavigationButtons(theme, colorScheme, size, bottomInset),

            // Ripple Overlay
            if (_showBlueScreen)
              Positioned.fill(
                child: ClipPath(
                  clipper: CircleClipper(_rippleRadius, _rippleOffset),
                  child: Container(
                    color: Colors.blue[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- PAGE BUILDERS ---

  Widget _buildWelcomePage(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surface,
      child: Stack(
        children: [
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/welcome_hero.png',
              fit: BoxFit.contain,
              height: 400,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDynamicShadowLogo(),
                      _buildThemeToggle(colorScheme),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Welcome to\nWallet',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 160), // Room for buttons
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(ThemeData theme, ColorScheme colorScheme, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage(ThemeData theme, ColorScheme colorScheme, double bottomInset) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(theme, colorScheme, Symbols.account_circle, 'Profile'),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: bottomInset > 0 ? 20 : 60),
                    Center(
                      child: Text(
                        "Let's create your profile",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.surfaceContainerHighest,
                            image: _imagePath != null
                                ? DecorationImage(
                                    image: FileImage(File(_imagePath!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.2),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _imagePath == null
                              ? Icon(
                                  Symbols.add_a_photo,
                                  size: 48,
                                  color: colorScheme.primary,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _focusNode.hasFocus
                              ? colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: TextField(
                        controller: _nameController,
                        focusNode: _focusNode,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: [
                          _WordCapitalizationFormatter(),
                        ],
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'Your name',
                          prefixIcon: const Icon(Symbols.person),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onTap: () => setState(() {}),
                      ),
                    ),
                    SizedBox(height: bottomInset > 0 ? 350 : 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyPage(ThemeData theme, ColorScheme colorScheme) {
    final currencies = [
      {'code': 'USD', 'name': 'United States Dollar', 'symbol': r'$'},
      {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
      {'code': 'INR', 'name': 'Indian Rupee', 'symbol': '₹'},
      {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
      {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥'},
      {'code': 'CAD', 'name': 'Canadian Dollar', 'symbol': r'CA$'},
      {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': r'A$'},
      {'code': 'BRL', 'name': 'Brazilian Real', 'symbol': r'R$'},
      {'code': 'RUB', 'name': 'Russian Ruble', 'symbol': '₽'},
      {'code': 'CNY', 'name': 'Chinese Yuan', 'symbol': '¥'},
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(theme, colorScheme, Symbols.payments, 'Currency'),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Let's choose your Currency",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 120),
                physics: const BouncingScrollPhysics(),
                itemCount: currencies.length,
                itemBuilder: (context, index) {
                  final c = currencies[index];
                  final isSelected = _selectedCurrency == c['code'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () => setState(() => _selectedCurrency = c['code']),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? colorScheme.primaryContainer 
                              : colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? colorScheme.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                c['name']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                              ),
                              child: Center(
                                child: Text(
                                  c['symbol']!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsPage(ThemeData theme, ColorScheme colorScheme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(theme, colorScheme, Symbols.shield_with_heart, 'Permissions'),
            const SizedBox(height: 60),
            Center(
              child: Text(
                "Permissions we need",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 48),
            _buildPermissionItem(
              theme,
              colorScheme,
              icon: Symbols.folder_open,
              title: "All Files Access",
              reason: "Required to create and restore backups of your financial data safely.",
              isGranted: _storagePermissionGranted,
              onTap: () async {
                final status = Platform.isAndroid
                    ? await Permission.manageExternalStorage.request()
                    : await Permission.storage.request();
                setState(() => _storagePermissionGranted = status.isGranted);
              },
            ),
            const SizedBox(height: 24),
            _buildPermissionItem(
              theme,
              colorScheme,
              icon: Symbols.notifications,
              title: "Notifications",
              reason: "Get reminders for your upcoming bills and recurring transactions.",
              isGranted: _notificationPermissionGranted,
              onTap: () async {
                final status = await Permission.notification.request();
                setState(() => _notificationPermissionGranted = status.isGranted);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem(
    ThemeData theme,
    ColorScheme colorScheme, {
    required IconData icon,
    required String title,
    required String reason,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 32),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reason,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: isGranted ? null : onTap,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                disabledBackgroundColor: colorScheme.surfaceContainerHighest,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isGranted
                    ? Icon(
                        Symbols.check,
                        key: const ValueKey('granted'),
                        color: colorScheme.primary,
                        size: 28,
                      )
                    : const Text(
                        "Allow Permission",
                        key: ValueKey('not_granted'),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalPage(ThemeData theme, ColorScheme colorScheme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(theme, colorScheme, Symbols.done_all, 'All Set'),
            Expanded(
              child: Column(
                children: [
                  const Spacer(),
                  SvgPicture.asset(
                    'assets/images/open-source.svg',
                    height: 140,
                    colorFilter: ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    "Open Source & Private",
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Wallet is fully open source and works offline. Your data never leaves your device.",
                      style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: 100), // Space for big button
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- BUTTONS ---

  Widget _buildNavigationButtons(
      ThemeData theme, ColorScheme colorScheme, Size size, double bottomInset) {
    final progress = _currentPage; // 0.0 to 4.0
    
    // Page 0 (Welcome) logic
    final isPage0 = progress < 0.5;
    final isLastPage = progress > 3.5;
    
    // Transition from Welcome to Next (Page 0 -> 1)
    final p01 = (progress).clamp(0.0, 1.0);
    
    // Welcome/DiveIn button properties
    final double width;
    final double left;
    final double borderRadius;
    final double bottom = (bottomInset > 0 && progress >= 0.5) ? bottomInset + 20 : 48;
    
    if (progress <= 1.0) {
      // Transition from Page 0 to Page 1
      width = lerpDouble(size.width - 48, 120.0, p01)!;
      left = lerpDouble(24.0, size.width - 120 - 24.0, p01)!;
      borderRadius = 24.0;
    } else if (progress <= 3.0) {
      // Static "Next" position for Page 1, 2, 3
      width = 120.0;
      left = size.width - 120 - 24.0;
      borderRadius = 24.0;
    } else {
      // Transition from Page 3 to Page 4
      final p34 = (progress - 3.0).clamp(0.0, 1.0);
      width = lerpDouble(120.0, size.width - 48, p34)!;
      left = lerpDouble(size.width - 120 - 24.0, 24.0, p34)!;
      borderRadius = 24.0;
    }

    // Previous button visibility and position
    final showPrevious = progress >= 0.9 && progress <= 3.5;
    final prevOpacity = (progress >= 0.9 && progress <= 1.0) 
        ? (progress - 0.9) * 10 
        : (progress > 3.0 && progress <= 3.1) 
            ? (3.1 - progress) * 10
            : 1.0;

    return Stack(
      children: [
        // Previous Button
        if (showPrevious)
          Positioned(
            left: 24,
            bottom: bottom,
            child: Opacity(
              opacity: prevOpacity.clamp(0.0, 1.0),
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(120, 64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  side: BorderSide(color: colorScheme.primary, width: 2),
                ),
                child: Row(
                  children: [
                    Icon(Symbols.arrow_back, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text("Previous", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),

        // Restore Backup (Only Page 0)
        if (isPage0)
          Positioned(
            left: 24,
            right: 24,
            bottom: 128,
            child: TextButton.icon(
              onPressed: _restoreBackup,
              icon: const Icon(Symbols.settings_backup_restore),
              label: const Text("Restore Backup", style: TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                foregroundColor: colorScheme.onSurface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),

        // Next / Welcome / Dive In Button
        AnimatedPositioned(
          duration: const Duration(milliseconds: 10), // Handled by PageView listener for smoothness
          left: left,
          bottom: bottom,
          child: GestureDetector(
            onTapUp: isLastPage ? _startRippleAnimation : null,
            onTap: isLastPage ? null : _nextPage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: width,
              height: 64,
              decoration: BoxDecoration(
                color: _canGoNext(progress) ? colorScheme.primary : Colors.grey[400],
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  if (_canGoNext(progress))
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildButtonLabel(progress),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonLabel(double progress) {
    if (progress < 0.5) {
      return const Text(
        'Welcome',
        key: ValueKey('welcome'),
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      );
    } else if (progress < 3.5) {
      return const Row(
        key: ValueKey('next'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Next',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Icon(Symbols.arrow_forward, color: Colors.white),
        ],
      );
    } else {
      return const Text(
        'Let\'s dive in',
        key: ValueKey('divein'),
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      );
    }
  }
}

// --- UTILS ---

class CircleClipper extends CustomClipper<Path> {
  final double radius;
  final Offset center;

  CircleClipper(this.radius, this.center);

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(covariant CircleClipper oldClipper) => oldClipper.radius != radius;
}

class _WordCapitalizationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final String text = newValue.text;
    final List<String> words = text.split(' ');
    final List<String> capitalizedWords = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).toList();

    final String newText = capitalizedWords.join(' ');
    
    return newValue.copyWith(
      text: newText,
      selection: newValue.selection,
    );
  }
}
