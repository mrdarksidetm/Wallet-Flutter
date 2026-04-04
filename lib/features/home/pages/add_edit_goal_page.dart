import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/database/models/account.dart';
import '../../../core/database/providers.dart';
import '../../../core/widgets/icon_picker.dart';
import '../../../core/widgets/primary_atelier_button.dart';
import '../../../core/theme/color_extension.dart';

class AddEditGoalPage extends ConsumerStatefulWidget {
  final Goal? goal;
  const AddEditGoalPage({super.key, this.goal});

  @override
  ConsumerState<AddEditGoalPage> createState() => _AddEditGoalPageState();
}

class _AddEditGoalPageState extends ConsumerState<AddEditGoalPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetController;
  late TextEditingController _currentController;
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  String _selectedColor = '0xFF4CAF50';
  String _selectedIcon = 'savings';
  Account? _selectedAccount;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name ?? '');
    _targetController =
        TextEditingController(text: widget.goal?.targetAmount.toString() ?? '');
    _currentController = TextEditingController(
        text: widget.goal?.currentAmount.toString() ?? '0');
    _deadline =
        widget.goal?.deadline ?? DateTime.now().add(const Duration(days: 30));
    _selectedColor = widget.goal?.color ?? '0xFF4CAF50';
    _selectedIcon = widget.goal?.icon ?? 'savings';
    _selectedAccount = widget.goal?.account.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  Future<void> _pickColor(ThemeData theme, Color effectiveColor) async {
    final Color newColor = await showColorPickerDialog(
      context,
      effectiveColor,
      title: Text('Select Color', style: theme.textTheme.titleLarge),
      width: 40,
      height: 40,
      spacing: 0,
      runSpacing: 0,
      borderRadius: 0,
      wheelDiameter: 165,
      enableOpacity: false,
      showColorCode: true,
      colorCodeHasColor: true,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
    );
    setState(() => _selectedColor =
        '0x${newColor.value.toRadixString(16).toUpperCase()}');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final goal = Goal()
      ..name = _nameController.text
      ..targetAmount = double.tryParse(_targetController.text) ?? 0.0
      ..currentAmount = double.tryParse(_currentController.text) ?? 0.0
      ..deadline = _deadline
      ..color = _selectedColor
      ..icon = _selectedIcon
      ..createdAt = widget.goal?.createdAt ?? DateTime.now()
      ..updatedAt = DateTime.now();

    if (_selectedAccount != null) {
      goal.account.value = _selectedAccount;
    }

    if (widget.goal != null) {
      goal.id = widget.goal!.id;
    }

    await ref.read(goalServiceProvider).saveGoal(goal);

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = _selectedColor.parseHexColor();
    final accountsAsync = ref.watch(accountsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal == null ? 'Add Goal' : 'Edit Goal'),
        actions: [
          if (widget.goal != null)
            IconButton(
              onPressed: _showDeleteDialog,
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => IconPickerWidget(
                      selectedIcon: _selectedIcon,
                      selectedColor: effectiveColor,
                      onIconSelected: (icon) {
                        setState(() => _selectedIcon = icon);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.getIcon(_selectedIcon),
                    size: 40,
                    color: effectiveColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => IconPickerWidget(
                          selectedIcon: _selectedIcon,
                          selectedColor: effectiveColor,
                          onIconSelected: (icon) {
                            setState(() => _selectedIcon = icon);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                    leading: Icon(AppIcons.getIcon(_selectedIcon),
                        color: effectiveColor),
                    title: const Text('Icon'),
                    subtitle: Text(_selectedIcon),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    tileColor: colorScheme.surfaceContainerLow,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ListTile(
                    onTap: () => _pickColor(theme, effectiveColor),
                    leading:
                        CircleAvatar(backgroundColor: effectiveColor, radius: 12),
                    title: const Text('Color'),
                    subtitle: const Text('Goal Theme'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    tileColor: colorScheme.surfaceContainerLow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Account Link (Savings only)
            accountsAsync.when(
              data: (accounts) {
                final savingsAccounts = accounts.where((a) => a.type == AccountType.savings).toList();
                if (savingsAccounts.isEmpty) return const SizedBox.shrink();
                
                return Column(
                  children: [
                    DropdownButtonFormField<Account>(
                      value: savingsAccounts.any((a) => a.id == _selectedAccount?.id) 
                        ? savingsAccounts.firstWhere((a) => a.id == _selectedAccount?.id)
                        : null,
                      decoration: InputDecoration(
                        labelText: 'Link to Savings Account',
                        prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
                        helperText: 'Goal progress will sync with this account',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      items: savingsAccounts.map((a) => DropdownMenuItem(
                        value: a,
                        child: Text(a.name),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedAccount = v),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Goal Name (e.g. New Car, Vacation)',
                prefixIcon: Icon(Icons.flag_rounded),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetController,
              decoration: const InputDecoration(
                labelText: 'Target Amount',
                prefixIcon: Icon(Icons.ads_click_rounded),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _currentController,
              decoration: const InputDecoration(
                labelText: 'Already Saved',
                prefixIcon: Icon(Icons.savings_rounded),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ListTile(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _deadline,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _deadline = date);
              },
              leading: const Icon(Icons.event_rounded),
              title: const Text('Deadline'),
              subtitle: Text(DateFormat('MMM d, yyyy').format(_deadline)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            const SizedBox(height: 48),
            PrimaryAtelierButton(
              onPressed: _save,
              icon: const Icon(Symbols.save, color: Colors.white),
              label: const Text(
                'Save Goal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal?'),
        content: const Text(
            'This savings goal will be permanently removed. Proceed?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(goalServiceProvider).deleteGoal(widget.goal!.id);
              
              if (mounted) {
                Navigator.pop(context); // Pop dialog
                context.pop(); // Pop page
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
