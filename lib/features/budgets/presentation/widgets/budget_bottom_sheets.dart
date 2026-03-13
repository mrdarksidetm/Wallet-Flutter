import 'package:flutter/material.dart';

class BudgetModeBottomSheet extends StatelessWidget {
  final String currentMode;
  final ValueChanged<String> onModeSelected;

  const BudgetModeBottomSheet({
    super.key,
    required this.currentMode,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Choose Budget Mode'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildModeCard(
                  context: context,
                  mode: 'Automatic',
                  icon: Icons.auto_awesome,
                  description: 'Categories selected automatically',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModeCard(
                  context: context,
                  mode: 'Manual',
                  icon: Icons.tune,
                  description: 'Choose categories manually',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildCancelButton(context),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required String mode,
    required IconData icon,
    required String description,
  }) {
    final isSelected = currentMode == mode;
    return GestureDetector(
      onTap: () {
        onModeSelected(mode);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFBE4E1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF90594C) : const Color(0xFFD3BDB9),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF90594C) : const Color(0xFF5A4D48)),
            const SizedBox(height: 12),
            Text(
              mode,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF90594C) : const Color(0xFF1B1B1F),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8A7773)),
            ),
          ],
        ),
      ),
    );
  }
}

class BudgetTypeBottomSheet extends StatelessWidget {
  final String currentType;
  final ValueChanged<String> onTypeSelected;

  const BudgetTypeBottomSheet({
    super.key,
    required this.currentType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader('Choose Budget Type'),
          const SizedBox(height: 16),
          _buildTypeOption(
            context: context,
            title: 'Category Budget',
            icon: Icons.category_outlined,
            description: 'Create separate budgets for different spending categories. Each category will have its own spending limit and tracking. Perfect for managing specific expenses like food, entertainment, or transportation.',
          ),
          const SizedBox(height: 12),
          _buildTypeOption(
            context: context,
            title: 'Overall Budget',
            icon: Icons.account_balance_wallet_outlined,
            description: 'Set one total spending limit across all categories. Track your overall spending without category-specific limits. Ideal for general expense control and simple budgeting.',
          ),
          const SizedBox(height: 16),
          _buildCancelButton(context),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String description,
  }) {
    final isSelected = currentType == title;
    return GestureDetector(
      onTap: () {
        onTypeSelected(title);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFBE4E1) : const Color(0xFFF3E7E4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF90594C) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF90594C)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3B2723)),
                  ),
                ),
                if (isSelected) const Icon(Icons.check_circle_outline, color: Color(0xFF90594C)),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Color(0xFF5A4D48), height: 1.4, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class BudgetPeriodBottomSheet extends StatelessWidget {
  final String currentPeriod;
  final ValueChanged<String> onPeriodSelected;

  const BudgetPeriodBottomSheet({
    super.key,
    required this.currentPeriod,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader('Select Budget Period'),
          const SizedBox(height: 16),
          _buildPeriodOption(context, 'Daily', 'Budget resets every day'),
          const SizedBox(height: 8),
          _buildPeriodOption(context, 'Weekly', 'Budget resets every week'),
          const SizedBox(height: 8),
          _buildPeriodOption(context, 'Monthly', 'Budget resets every month'),
          const SizedBox(height: 8),
          _buildPeriodOption(context, 'Yearly', 'Budget resets every year'),
          const SizedBox(height: 8),
          _buildCustomPeriodOption(),
          const SizedBox(height: 16),
          _buildCancelButton(context),
        ],
      ),
    );
  }

  Widget _buildPeriodOption(BuildContext context, String title, String subtitle) {
    final isSelected = currentPeriod == title;
    return GestureDetector(
      onTap: () {
        onPeriodSelected(title);
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFBE4E1) : const Color(0xFFF3E7E4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF90594C) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3B2723))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Color(0xFF5A4D48), fontSize: 13)),
              ],
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF90594C)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPeriodOption() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF3E7E4), borderRadius: BorderRadius.circular(20)),
      child: const Text('Custom', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3B2723))),
    );
  }
}

class AutoTrackCategoriesBottomSheet extends StatelessWidget {
  const AutoTrackCategoriesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Auto-Track Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F))),
                    Text('0 of 12 categories selected', style: TextStyle(color: Color(0xFF8A7773))),
                  ],
                ),
                IconButton(icon: const Icon(Icons.info_outline, color: Color(0xFF1B1B1F)), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 24),
            _buildSubcategoriesToggle(),
            const SizedBox(height: 20),
            _buildFilterPills(),
            const SizedBox(height: 20),
            _buildCategorySelectOption('Food', Icons.fastfood, const Color(0xFFFFCC80)),
            const SizedBox(height: 16),
            _buildCategorySelectOption('Gift Shopping', Icons.card_giftcard, const Color(0xFFF48FB1)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoriesToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBECE9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5D1CF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Include Subcategories', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F))),
                Text('Track parent & child categories together', style: TextStyle(color: Color(0xFF8A7773), fontSize: 12)),
              ],
            ),
          ),
          Switch(value: false, onChanged: (v) {}, activeColor: const Color(0xFF90594C)),
        ],
      ),
    );
  }

  Widget _buildFilterPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFF945B50), borderRadius: BorderRadius.circular(20)),
            child: const Text('Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: const Text('Income', style: TextStyle(color: Color(0xFF5A4D48), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelectOption(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.3), shape: BoxShape.circle),
          child: Icon(icon, color: color.withOpacity(1), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Color(0xFF1B1B1F)))),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF5A4D48), width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class AdditionalSettingsBottomSheet extends StatelessWidget {
  final bool isRollingBudget;
  final ValueChanged<bool> onRollingBudgetChanged;

  const AdditionalSettingsBottomSheet({
    super.key,
    required this.isRollingBudget,
    required this.onRollingBudgetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader('Additional Settings'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rolling Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B1B1F))),
                    SizedBox(height: 4),
                    Text('Unused budget amount rolls over to the next period', style: TextStyle(color: Color(0xFF8A7773), fontSize: 13)),
                  ],
                ),
              ),
              Switch(value: isRollingBudget, onChanged: onRollingBudgetChanged, activeColor: const Color(0xFF90594C)),
            ],
          ),
          const SizedBox(height: 32),
          _buildCancelButton(context),
        ],
      ),
    );
  }
}

// Shared helpers
Widget _buildHeader(String title) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F))),
      IconButton(icon: const Icon(Icons.info_outline, color: Color(0xFF1B1B1F)), onPressed: () {}),
    ],
  );
}

Widget _buildCancelButton(BuildContext context) {
  return Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Cancel', style: TextStyle(color: Color(0xFF90594C), fontWeight: FontWeight.bold)),
    ),
  );
}
