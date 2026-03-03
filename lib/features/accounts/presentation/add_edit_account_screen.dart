import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/models/account.dart';
import '../../../shared/widgets/app_button.dart';

class AddEditAccountScreen extends ConsumerStatefulWidget {
  final Account? account;
  const AddEditAccountScreen({super.key, this.account});

  @override
  ConsumerState<AddEditAccountScreen> createState() => _AddEditAccountScreenState();
}

class _AddEditAccountScreenState extends ConsumerState<AddEditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _balanceString;
  late Color _color;
  AccountType _selectedType = AccountType.creditCard;
  
  // Dummy fields for UI
  bool _isDefault = false;
  bool _isExcluded = false;

  final List<Color> _presetColors = const [
    Colors.redAccent, Colors.pinkAccent, Colors.purpleAccent,
    Colors.deepPurpleAccent, Colors.indigoAccent, Colors.blueAccent,
    Colors.lightBlueAccent, Colors.cyanAccent, Colors.tealAccent,
    Colors.greenAccent, Colors.lightGreenAccent, Colors.limeAccent,
    Colors.yellowAccent, Colors.amberAccent, Colors.orangeAccent
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.account?.name ?? '';
    _balanceString = widget.account?.balance.toString() ?? '';
    _color = widget.account != null ? Color(int.parse(widget.account!.color)) : Colors.redAccent;
    if (widget.account != null) {
      if (widget.account!.type == AccountType.cash) _selectedType = AccountType.cash;
      if (widget.account!.type == AccountType.bank) _selectedType = AccountType.bank;
    }
  }

  Widget _buildSegment(String title, AccountType type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF9E4B35) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _customInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF9E4B35)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.account == null ? 'Add Account' : 'Edit Account',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Control
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    _buildSegment('Card', AccountType.creditCard),
                    _buildSegment('Cash', AccountType.cash),
                    _buildSegment('Savings', AccountType.bank),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Icon + Account Name
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _color, width: 2),
                    ),
                    child: Center(
                      child: Icon(Icons.credit_card, color: _color),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _name,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                      decoration: _customInputDecoration('Enter account name'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _name = val!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                decoration: _customInputDecoration('Enter name'),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _balanceString,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                      decoration: _customInputDecoration('Enter amount'),
                      validator: (val) => double.tryParse(val ?? '') == null ? 'Invalid' : null,
                      onSaved: (val) => _balanceString = val!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: _customInputDecoration('Account number'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              const Text('Parent Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('No parent account selected', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 24),
              
              // Switches
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set default account', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Default account will be selected while adding transaction'),
                value: _isDefault,
                activeColor: const Color(0xFF9E4B35),
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Exclude account', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Transactions are not calculated in the balance and other places'),
                value: _isExcluded,
                activeColor: const Color(0xFF9E4B35),
                onChanged: (val) => setState(() => _isExcluded = val),
              ),
              
              const SizedBox(height: 24),
              const Text('Colors', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              // Colors Tabs (Static UI representation)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9E4B35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text('Primary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        child: Text('Accent', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                           final Color newColor = await showColorPickerDialog(
                             context,
                             _color,
                             title: Text('Select Color', style: Theme.of(context).textTheme.titleLarge),
                             pickersEnabled: const <ColorPickerType, bool>{ColorPickerType.wheel: true},
                           );
                           setState(() => _color = newColor);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          child: Text('Wheel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Color Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _presetColors.length,
                itemBuilder: (context, index) {
                  final color = _presetColors[index];
                  final isSelected = _color.value == color.value;
                  return GestureDetector(
                    onTap: () => setState(() => _color = color),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: AppButton(
                  onPressed: _saveAccount,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_outlined),
                      const SizedBox(width: 8),
                      Text(widget.account == null ? 'Add' : 'Save', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final colorString = '0x${_color.value.toRadixString(16).padLeft(8, '0')}';
      
      if (widget.account == null) {
        await ref.read(accountServiceProvider).addAccount(
          name: _name,
          icon: 'account_balance_wallet',
          color: colorString,
          balance: double.parse(_balanceString),
          type: _selectedType,
        );
      } else {
        final upd = Account()
          ..id = widget.account!.id
          ..name = _name
          ..icon = 'account_balance_wallet'
          ..color = colorString
          ..type = _selectedType
          ..balance = double.parse(_balanceString)
          ..createdAt = widget.account!.createdAt;
        await ref.read(accountServiceProvider).updateAccount(widget.account!, upd);
      }
      if (mounted) Navigator.pop(context);
    }
  }
}
