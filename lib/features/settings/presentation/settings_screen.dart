import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/core/theme/theme_provider.dart';
import '../../../core/database/providers.dart';
import '../../finance/presentation/budget_screen.dart';
import '../../finance/presentation/loan_screen.dart';
import '../../finance/presentation/goal_screen.dart';
import '../../finance/presentation/recurring_transaction_screen.dart';
import '../../finance/presentation/bill_splitter_screen.dart';
import '../../categories/presentation/category_screen.dart';
import '../../accounts/presentation/account_screen.dart';
import '../../people/presentation/people_screen.dart';
import 'currency_selection_screen.dart';
import 'package:wallet/features/ai/presentation/insights_screen.dart';
import 'about_screen.dart';
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    final themeController = ref.watch(themeControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120.0),
        children: [
          const _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            title: const Text('Material You'),
            subtitle: const Text('Use system wallpaper colors'),
            value: themeState.useMaterialYou,
            onChanged: (val) => themeController.setUseMaterialYou(val),
          ),
          if (!themeState.useMaterialYou)
            ListTile(
              title: const Text('Accent Color'),
              trailing: ColorIndicator(
                width: 44,
                height: 44,
                borderRadius: 4,
                color: themeState.customColor ?? Theme.of(context).primaryColor,
                onSelectFocus: false,
                onSelect: () async {
                  final Color newColor = await showColorPickerDialog(
                    context,
                    themeState.customColor ?? Theme.of(context).primaryColor,
                    title: Text('Select Accent Color', style: Theme.of(context).textTheme.titleLarge),
                    width: 40,
                    height: 40,
                    spacing: 0,
                    runSpacing: 0,
                    borderRadius: 0,
                    wheelDiameter: 165,
                    enableOpacity: false,
                    showColorCode: true,
                    colorCodeHasColor: true,
                    pickersEnabled: <ColorPickerType, bool>{
                      ColorPickerType.wheel: true,
                    },
                    actionButtons: const ColorPickerActionButtons(
                      dialogActionButtons: true,
                    ),
                  );
                  themeController.setCustomColor(newColor);
                },
              ),
            ),
          SwitchListTile(
            title: const Text('Liquid Glass Effect'),
            value: themeState.isLiquid,
            onChanged: (val) => themeController.toggleLiquid(val),
          ),
          ListTile(
            title: const Text('Theme Mode'),
            trailing: DropdownButton<ThemeMode>(
              value: themeState.themeMode,
              onChanged: (val) {
                if (val != null) themeController.setThemeMode(val);
              },
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
            ),
          ),
           ListTile(
            title: const Text('Font Family'),
            trailing: DropdownButton<String>(
              value: themeState.fontFamily,
              onChanged: (val) {
                if (val != null) themeController.setFontFamily(val);
              },
              items: const [
                DropdownMenuItem(value: 'ProductSans', child: Text('Product Sans')),
                DropdownMenuItem(value: 'SFProDisplay', child: Text('SF Pro')),
              ],
            ),
          ),
          
          const _SectionHeader(title: 'Manage'),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Accounts'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('People & Payees'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PeopleScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Global Currency'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrencySelectionScreen())),
          ),
          const _SectionHeader(title: 'Finance'),
          ListTile(
            leading: const Icon(Icons.pie_chart),
            title: const Text('Budgets'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Bill Splitter'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillSplitterScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.handshake),
            title: const Text('Loans'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoanScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Goals'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('Recurring Transactions'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecurringTransactionScreen())),
          ),

          const _SectionHeader(title: 'Intelligence'),
          ListTile(
            leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
            title: const Text('Financial Insights'),
            subtitle: const Text('Smart offline analysis'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InsightsScreen())),
          ),

          const _SectionHeader(title: 'Data'),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export CSV'),
            onTap: () async {
              try {
                await ref.read(csvServiceProvider).exportTransactions();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Reset Data', style: TextStyle(color: Colors.red)),
            onTap: () {
               // Show confirmation dialog logic here (omitted for brevity)
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data Reset not implemented for safety reasons yet.')));
            },
          ),

          const _SectionHeader(title: 'App Info'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Credits & Open Source'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
