import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AppIcons {
  static const Map<String, IconData> icons = {
    'shopping_bag': Symbols.shopping_bag,
    'payments': Symbols.payments,
    'account_balance': Symbols.account_balance,
    'credit_card': Symbols.credit_card,
    'wallet': Symbols.wallet,
    'savings': Symbols.savings,
    'receipt_long': Symbols.receipt_long,
    'restaurant': Symbols.restaurant,
    'coffee': Symbols.coffee,
    'local_grocery_store': Symbols.local_grocery_store,
    'directions_car': Symbols.directions_car,
    'home': Symbols.home,
    'bolt': Symbols.bolt,
    'water_drop': Symbols.water_drop,
    'wifi': Symbols.wifi,
    'phone_iphone': Symbols.phone_iphone,
    'medical_services': Symbols.medical_services,
    'fitness_center': Symbols.fitness_center,
    'school': Symbols.school,
    'sports_esports': Symbols.sports_esports,
    'movie': Symbols.movie,
    'flight': Symbols.flight,
    'hotel': Symbols.hotel,
    'pets': Symbols.pets,
    'shopping_cart': Symbols.shopping_cart,
    'sell': Symbols.sell,
    'work': Symbols.work,
    'card_giftcard': Symbols.card_giftcard,
    'redeem': Symbols.redeem,
    'charity': Symbols.volunteer_activism,
    'category': Symbols.category,
    'label': Symbols.label,
    'description': Symbols.description,
    'event': Symbols.event,
    'person': Symbols.person,
    'group': Symbols.group,
    'add_card': Symbols.add_card,
    'account_balance_wallet': Symbols.account_balance_wallet,
    'pie_chart': Symbols.pie_chart,
    'trending_up': Symbols.trending_up,
    'trending_down': Symbols.trending_down,
  };

  static IconData getIcon(String? name) {
    return icons[name] ?? Symbols.category;
  }
}

class IconPickerWidget extends StatelessWidget {
  final String selectedIcon;
  final Color selectedColor;
  final ValueChanged<String> onIconSelected;

  const IconPickerWidget({
    super.key,
    required this.selectedIcon,
    required this.selectedColor,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Icon',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: AppIcons.icons.length,
              itemBuilder: (context, index) {
                final entry = AppIcons.icons.entries.elementAt(index);
                final isSelected = entry.key == selectedIcon;

                return InkWell(
                  onTap: () => onIconSelected(entry.key),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? selectedColor.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected ? Border.all(color: selectedColor, width: 2) : null,
                    ),
                    child: Icon(
                      entry.value,
                      color: isSelected ? selectedColor : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
