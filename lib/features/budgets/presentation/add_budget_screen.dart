import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/models/auxiliary_models.dart';
import '../../../../core/database/models/category.dart';
import 'widgets/budget_components.dart';
import 'widgets/budget_bottom_sheets.dart';
import 'controllers/budget_controller.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  // Mock State
  String _currentMode = 'Automatic';
  String _currentType = 'Category Budget';
  String _currentPeriod = 'Monthly';
  int _selectedCategories = 0;
  String _additionalSettings = 'Fixed budget';
  
  Color _selectedPrimaryColor = const Color(0xFFFF5722); // Default to orange ish red
  Color _selectedAccentColor = const Color(0xFFF44336);

  final List<Color> _primaryColors = [
    const Color(0xFFFF5722), const Color(0xFFE91E63), const Color(0xFF9C27B0),
    const Color(0xFF673AB7), const Color(0xFF3F51B5), const Color(0xFF2196F3),
    const Color(0xFF03A9F4), const Color(0xFF00BCD4), const Color(0xFF009688),
    const Color(0xFF4CAF50), const Color(0xFF8BC34A), const Color(0xFFCDDC39),
    const Color(0xFFFFEB3B), const Color(0xFFFFC107), const Color(0xFFFF9800),
    const Color(0xFFFF5722), const Color(0xFF795548), const Color(0xFF607D8B),
    const Color(0xFF9E9E9E), const Color(0xFF000000), 
  ];
  
  final List<Color> _accentColors = [
    const Color(0xFFFFEBEE), const Color(0xFFFFCDD2), const Color(0xFFEF9A9A),
    const Color(0xFFE57373), const Color(0xFFEF5350), const Color(0xFFF44336),
    const Color(0xFFE53935), const Color(0xFFD32F2F), const Color(0xFFC62828),
    const Color(0xFFB71C1C),
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  
  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1B1F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add budget',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: const Color(0xFF1B1B1F),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          children: [
            // Icon & Name Input
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF90594C), width: 1.5),
                  ),
                  child: const Icon(Icons.remove, color: Color(0xFF90594C), size: 28), // The minus looking icon
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Ex: Groceries',
                      hintStyle: const TextStyle(color: Color(0xFF8C7D7B)),
                      filled: true,
                      fillColor: const Color(0xFFFBECE9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Amount Input
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                hintText: 'Enter amount',
                hintStyle: const TextStyle(color: Color(0xFF8C7D7B)),
                filled: true,
                fillColor: const Color(0xFFFBECE9),
                 border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            
            const SizedBox(height: 24),
            
            // Settings List
            BudgetSettingTile(
              icon: Icons.edit_outlined,
              title: 'Budget Mode',
              subtitle: 'Choose how categories are selected\nCurrent: $_currentMode',
              onTap: () => _showBudgetModeBottomSheet(context),
            ),
            BudgetSettingTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Budget Type',
              subtitle: 'Choose how to track your budget\nCurrent: $_currentType',
              onTap: () => _showBudgetTypeBottomSheet(context),
            ),
             BudgetSettingTile(
              icon: Icons.calendar_today_outlined,
              title: 'Budget Period',
              subtitle: 'Select your budget timeframe\nCurrent: $_currentPeriod',
              onTap: () => _showBudgetPeriodBottomSheet(context),
            ),
             BudgetSettingTile(
              icon: Icons.motion_photos_auto_outlined, // Closer to the auto track icon
              title: 'Auto-Track Categories',
              subtitle: 'Choose categories to automatically track together\nSelected: $_selectedCategories categories',
              onTap: () => _showAutoTrackCategoriesBottomSheet(context),
            ),
            BudgetSettingTile(
              icon: Icons.settings_outlined,
              title: 'Additional Settings',
              subtitle: 'Rolling budget and other options\nCurrent: $_additionalSettings',
              onTap: () => _showAdditionalSettingsBottomSheet(context),
            ),

            const SizedBox(height: 16),

            // Notes Section
             TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Notes',
                hintStyle: const TextStyle(color: Color(0xFF8A7773)),
                filled: true,
                fillColor: const Color(0xFFFAF5F2),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE5D1CF), width: 1.5),
                ),
                 focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF90594C), width: 2),
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),

            const SizedBox(height: 24),
            
            // Colors Section Header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Colors',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3B2723),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Segmented Tab for Colors (Custom to match UI exactly)
             Container(
               padding: const EdgeInsets.all(4),
               decoration: BoxDecoration(
                 color: const Color(0xFFEEDDDA),
                 borderRadius: BorderRadius.circular(16),
               ),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   const BudgetColorTab(label: 'Primary', isSelected: true),
                   Container(width: 1, height: 24, color: const Color(0xFFD3BDB9)),
                   const BudgetColorTab(label: 'Accent', isSelected: false),
                   Container(width: 1, height: 24, color: const Color(0xFFD3BDB9)),
                   const BudgetColorTab(label: 'Wheel', isSelected: false),
                 ],
               ),
             ),

            const SizedBox(height: 20),

            // Primary Colors Grid Replicated
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.start,
              children: _primaryColors.map((color) => BudgetColorBox(
                color: color, 
                isSelected: color == _selectedPrimaryColor, 
                onTap: () => setState(() => _selectedPrimaryColor = color),
              )).toList(),
            ),

            const SizedBox(height: 16),

             // Accent Colors Grid Replicated
             Wrap(
               spacing: 12,
               runSpacing: 12,
               alignment: WrapAlignment.start,
               children: _accentColors.map((color) => BudgetColorBox(
                 color: color, 
                 isSelected: color == _selectedAccentColor, 
                 onTap: () => setState(() => _selectedAccentColor = color),
               )).toList(),
             ),

             const SizedBox(height: 24),

             // Hex Code Displayer
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
               decoration: BoxDecoration(
                 color: const Color(0xFFF3E7E4),
                 borderRadius: BorderRadius.circular(16),
                 border: Border.all(color: const Color(0xFFEEDDDA)),
               ),
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   const Text('0xFFF44336', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1B1B1F))),
                   const SizedBox(width: 16),
                   const Icon(Icons.copy_all_outlined, size: 18, color: Color(0xFF5A4D48)),
                 ],
               )
             ),

            const SizedBox(height: 120), // Bottom padding for FAB
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton.icon(
             onPressed: _onAddBudget,
             icon: const Icon(Icons.save_outlined, color: Colors.white),
             label: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
             style: ElevatedButton.styleFrom(
               backgroundColor: const Color(0xFF90594C),
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(24),
               ),
               elevation: 0,
             ),
          ),
        ),
      ),
    );
  }

  void _onAddBudget() {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim();
    if (name.isEmpty || amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null) return;

    // Create a temporary Category since we don't have a category picker yet
    final cat = Category()
      ..name = name
      ..icon = 'shopping_bag' 
      ..color = _selectedPrimaryColor.value.toRadixString(16).padLeft(8, '0')
      ..type = CategoryType.expense
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    // Map UI Selection to BudgetPeriod enum safely
    BudgetPeriod period;
    switch (_currentPeriod) {
      case 'Weekly':
        period = BudgetPeriod.weekly;
        break;
      case 'Yearly':
        period = BudgetPeriod.yearly;
        break;
      case 'Monthly':
      default:
        period = BudgetPeriod.monthly;
    }

    final budget = Budget()
      ..amount = amount
      ..period = period
      ..startDate = DateTime.now()
      ..endDate = DateTime.now().add(const Duration(days: 30)) // Mocking 1 month 
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..isActive = true;
    
    budget.category.value = cat;

    // Save and pop
    ref.read(budgetControllerProvider.notifier).addBudget(budget);
    Navigator.of(context).pop();
  }

  void _showBudgetModeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFAF5F2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => BudgetModeBottomSheet(
        currentMode: _currentMode,
        onModeSelected: (mode) => setState(() => _currentMode = mode),
      ),
    );
  }

  void _showBudgetTypeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFAF5F2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => BudgetTypeBottomSheet(
        currentType: _currentType,
        onTypeSelected: (type) => setState(() => _currentType = type),
      ),
    );
  }

  void _showBudgetPeriodBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFAF5F2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => BudgetPeriodBottomSheet(
        currentPeriod: _currentPeriod,
        onPeriodSelected: (period) => setState(() => _currentPeriod = period),
      ),
    );
  }

  void _showAutoTrackCategoriesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFAF5F2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
       builder: (context) => const AutoTrackCategoriesBottomSheet(),
    );
  }

  void _showAdditionalSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFAF5F2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
       builder: (context) => AdditionalSettingsBottomSheet(
         isRollingBudget: false, // Default logic check
         onRollingBudgetChanged: (v) {}, // Mock
       ),
    );
  }
}
