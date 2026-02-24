import 'package:flutter/material.dart';

class CustomizeDashboardBottomSheet extends StatefulWidget {
  const CustomizeDashboardBottomSheet({super.key});

  @override
  State<CustomizeDashboardBottomSheet> createState() => _CustomizeDashboardBottomSheetState();
}

class _CustomizeDashboardBottomSheetState extends State<CustomizeDashboardBottomSheet> {
  // Temporary state for the switches until we hook them up to Riverpod/Isar
  final Map<String, bool> _states = {
    'Budgets': true,
    'Assets': true,
    'Bill Splitter': true,
    'Loans': true,
    'Goals': true,
    'Labels': true,
    'Analytics': true,
    'Recurring': true,
    'Categories': true,
    'Weekly': true,
    'Places': true,
    'Person': true,
  };

  final Map<String, IconData> _icons = {
    'Budgets': Icons.savings_outlined,
    'Assets': Icons.account_balance_wallet_outlined,
    'Bill Splitter': Icons.call_split,
    'Loans': Icons.money,
    'Goals': Icons.track_changes,
    'Labels': Icons.label_outline,
    'Analytics': Icons.show_chart,
    'Recurring': Icons.repeat,
    'Categories': Icons.category_outlined,
    'Weekly': Icons.calendar_view_week,
    'Places': Icons.place_outlined,
    'Person': Icons.person_outline,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          // Handle pill
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Customize home screen',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _states.length,
              itemBuilder: (context, index) {
                final key = _states.keys.elementAt(index);
                return _buildSwitchTile(
                  title: key,
                  icon: _icons[key]!,
                  value: _states[key]!,
                  onChanged: (val) {
                    setState(() {
                      _states[key] = val;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          secondary: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
          value: value,
          onChanged: onChanged,
          activeColor: Colors.black, // Matching the internal dot color from the screenshot
          activeTrackColor: const Color(0xFFE5A48F), // Matching the peach track color
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.withOpacity(0.3),
        ),
        Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
      ],
    );
  }
}
