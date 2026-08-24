import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/widgets/transaction_segmented_group.dart';
import '../../../core/theme/color_extension.dart';
import '../../../core/widgets/icon_picker.dart';
import '../../../core/widgets/expressive_bottom_sheet.dart';
import '../../../core/services/file_service.dart';
import '../../../core/widgets/app_back_button.dart';
import '../widgets/person_avatar.dart';

class PersonDetailsPage extends ConsumerStatefulWidget {
  final Person person;
  const PersonDetailsPage({super.key, required this.person});

  @override
  ConsumerState<PersonDetailsPage> createState() => _PersonDetailsPageState();
}

class _PersonDetailsPageState extends ConsumerState<PersonDetailsPage> {
  late Person _person;

  @override
  void initState() {
    super.initState();
    _person = widget.person;
  }

  Future<void> _editPerson() async {
    final nameController = TextEditingController(text: _person.name);
    String selectedIcon = _person.avatar ?? 'person';
    String? imagePath = _person.avatar?.startsWith('/') == true ? _person.avatar : null;
    String selectedColor = _person.color;
    
    if (imagePath != null) selectedIcon = 'person';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final effectiveColor = selectedColor.parseHexColor();
          
          return ExpressiveBottomSheet(
            title: 'Edit Profile',
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final image = await picker.pickImage(source: ImageSource.gallery);
                            if (image != null) {
                              final cropped = await ImageCropper().cropImage(
                                sourcePath: image.path,
                                aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                                uiSettings: [
                                  AndroidUiSettings(
                                    toolbarTitle: 'Crop Image',
                                    toolbarColor: Theme.of(context).colorScheme.primary,
                                    toolbarWidgetColor: Colors.white,
                                    initAspectRatio: CropAspectRatioPreset.square,
                                    lockAspectRatio: true,
                                  ),
                                  IOSUiSettings(
                                    title: 'Crop Image',
                                  ),
                                ],
                              );
                              if (cropped != null) {
                                setModalState(() {
                                  imagePath = cropped.path;
                                });
                              }
                            }
                          },
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: effectiveColor.withValues(alpha: 0.1),
                            backgroundImage: imagePath != null ? FileImage(File(imagePath!)) : null,
                            child: imagePath == null 
                              ? Icon(AppIcons.getIcon(selectedIcon), size: 48, color: effectiveColor) 
                              : null,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Symbols.photo_camera, size: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => IconPickerWidget(
                                selectedIcon: selectedIcon,
                                selectedColor: effectiveColor,
                                onIconSelected: (icon) {
                                  setModalState(() {
                                    selectedIcon = icon;
                                    imagePath = null;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                          leading: Icon(AppIcons.getIcon(selectedIcon), color: effectiveColor),
                          title: const Text('Icon'),
                          subtitle: const Text('Symbols & Emojis'),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ListTile(
                          onTap: () async {
                            final Color newColor = await showColorPickerDialog(
                              context,
                              effectiveColor,
                              title: Text('Select Theme Color', style: Theme.of(context).textTheme.titleLarge),
                              width: 40, height: 40, spacing: 0, runSpacing: 0, borderRadius: 0,
                              wheelDiameter: 165, enableOpacity: false, showColorCode: true, colorCodeHasColor: true,
                              pickersEnabled: const <ColorPickerType, bool>{
                                ColorPickerType.both: false,
                                ColorPickerType.primary: true,
                                ColorPickerType.accent: true,
                                ColorPickerType.bw: false,
                                ColorPickerType.custom: true,
                                ColorPickerType.wheel: true,
                              },
                            );
                            setModalState(() => selectedColor = '0x${newColor.value.toRadixString(16).toUpperCase()}');
                          },
                          leading: CircleAvatar(backgroundColor: effectiveColor, radius: 12),
                          title: const Text('Color'),
                          subtitle: const Text('Theme'),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: const Icon(Symbols.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () async {
                        String? finalAvatar = imagePath ?? selectedIcon;
                        
                        // [ACTION]: If it's a file path and has changed, persist it.
                        if (imagePath != null && imagePath != _person.avatar) {
                          finalAvatar = await FileService.saveImagePermanently(imagePath!);
                        }
                        
                        _person.name = nameController.text;
                        _person.avatar = finalAvatar;
                        _person.color = selectedColor;
                        _person.updatedAt = DateTime.now();
                        await ref.read(personServiceProvider).savePerson(_person);
                        setState(() {});
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Save Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _person.color.parseHexColor();
    final currency = ref.watch(currencyProvider);
    final format = NumberFormat.simpleCurrency(name: currency);

    final loansAsync = ref.watch(loansStreamProvider);
    final transactionsAsync = ref.watch(personTransactionsProvider(_person.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            leading: const AppBackButton(),
            title: Text(
              _person.name,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: (theme.textTheme.headlineLarge?.fontSize ?? 32) + 3,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Symbols.edit),
                onPressed: _editPerson,
              ),
              const SizedBox(width: 8),
            ],
          ),
          
          // Stats Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 0,
                color: color.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      PersonAvatar(
                        person: _person,
                        radius: 40,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _person.name,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(context, 'Loans', _calculateDebt(loansAsync.value ?? []), format),
                          _buildStat(context, 'Transactions', _countTxs(transactionsAsync.value ?? []), null),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'RECENT ACTIVITY',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.grey, fontSize: 12),
              ),
            ),
          ),

          transactionsAsync.when(
            data: (txs) {
              
              // Load links if needed (though usually we should rely on personId in txs)
              // For history, we want ALL transactions and ALL loans related to this person.
              final allLoans = (loansAsync.value ?? [])
                  .where((l) => l.person.value?.id == _person.id)
                  .toList();

              if (txs.isEmpty && allLoans.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No activity with this person')),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (allLoans.isNotEmpty) ...[
                        const Text(
                          'LOANS & DEBTS',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).colorScheme.surfaceContainer
                                : Theme.of(context).colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: List.generate(allLoans.length, (index) {
                              final loan = allLoans[index];
                              final isLast = index == allLoans.length - 1;
                              return _buildLoanTile(context, loan, format, showDivider: !isLast);
                            }),
                          ),
                        ),
                      ],
                      if (txs.isNotEmpty) ...[
                        const Text(
                          'TRANSACTIONS',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TransactionGroupedList(
                          transactions: txs,
                          onTap: (tx) => context.push('/add_transaction', extra: tx),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildLoanTile(BuildContext context, Loan loan, NumberFormat format, {bool showDivider = false}) {
    final color = loan.type == LoanType.lent ? Colors.green : Colors.red;
    final isPaid = loan.isPaid;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: isPaid ? 0.6 : 1.0,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(
                isPaid 
                  ? Symbols.check_circle 
                  : (loan.type == LoanType.lent ? Symbols.arrow_upward : Symbols.arrow_downward), 
                color: color
              ),
            ),
            title: Text(
              isPaid 
                ? 'Settled Loan' 
                : (loan.type == LoanType.lent ? 'You lent money' : 'You borrowed money'), 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: isPaid ? TextDecoration.lineThrough : null,
              )
            ),
            subtitle: Text(
              isPaid 
                ? 'Paid on ${DateFormat('MMM d').format(loan.updatedAt)}'
                : (loan.dueDate != null ? 'Due ${DateFormat('MMM d').format(loan.dueDate!)}' : 'No due date')
            ),
            trailing: Text(
              format.format(loan.amount), 
              style: TextStyle(
                fontWeight: FontWeight.w900, 
                color: color.withValues(alpha: isPaid ? 0.5 : 1.0), 
                fontSize: 16
              )
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 72,
            endIndent: 16,
            color: colorScheme.outlineVariant.withValues(alpha: 0.25),
          ),
      ],
    );
  }

  double _calculateDebt(List<Loan> loans) {
    final personLoans = loans.where((l) => l.person.value?.id == _person.id && l.isActive && !l.isPaid);
    double total = 0;
    for (var l in personLoans) {
      if (l.type == LoanType.lent) {
        total += l.amount;
      } else {
        total -= l.amount;
      }
    }
    return total;
  }

  String _countTxs(List<TransactionModel> txs) {
    return txs.length.toString();
  }

  Widget _buildStat(BuildContext context, String label, dynamic value, NumberFormat? format) {
    final isNegative = value is double && value < 0;
    final displayValue = format != null ? format.format((value as double).abs()) : value.toString();
    
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '${isNegative ? '-' : ''}$displayValue',
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.w900,
            color: format == null ? null : (value == 0 ? null : (value > 0 ? Colors.green : Colors.red)),
          ),
        ),
      ],
    );
  }
}

