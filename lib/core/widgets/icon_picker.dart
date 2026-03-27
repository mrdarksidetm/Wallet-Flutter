import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../theme/personalization_provider.dart';

class AppIcons {
  static const Map<String, Map<String, IconData>> categories = {
    'Finance': {
      'payments': Symbols.payments,
      'account_balance': Symbols.account_balance,
      'credit_card': Symbols.credit_card,
      'wallet': Symbols.wallet,
      'savings': Symbols.savings,
      'receipt_long': Symbols.receipt_long,
      'add_card': Symbols.add_card,
      'account_balance_wallet': Symbols.account_balance_wallet,
      'pie_chart': Symbols.pie_chart,
      'trending_up': Symbols.trending_up,
      'trending_down': Symbols.trending_down,
      'request_quote': Symbols.request_quote,
      'price_check': Symbols.price_check,
      'account_tree': Symbols.account_tree,
    },
    'Shopping': {
      'shopping_bag': Symbols.shopping_bag,
      'shopping_cart': Symbols.shopping_cart,
      'sell': Symbols.sell,
      'card_giftcard': Symbols.card_giftcard,
      'redeem': Symbols.redeem,
      'storefront': Symbols.storefront,
      'local_mall': Symbols.local_mall,
      'shopping_basket': Symbols.shopping_basket,
    },
    'Food': {
      'restaurant': Symbols.restaurant,
      'coffee': Symbols.coffee,
      'local_grocery_store': Symbols.local_grocery_store,
      'lunch_dining': Symbols.lunch_dining,
      'dinner_dining': Symbols.dinner_dining,
      'bakery_dining': Symbols.bakery_dining,
      'icecream': Symbols.icecream,
      'wine_bar': Symbols.wine_bar,
    },
    'Transportation': {
      'directions_car': Symbols.directions_car,
      'flight': Symbols.flight,
      'commute': Symbols.commute,
      'directions_bike': Symbols.directions_bike,
      'directions_bus': Symbols.directions_bus,
      'directions_railway': Symbols.directions_railway,
      'local_taxi': Symbols.local_taxi,
    },
    'Home': {
      'home': Symbols.home,
      'bolt': Symbols.bolt,
      'water_drop': Symbols.water_drop,
      'wifi': Symbols.wifi,
      'phone_iphone': Symbols.phone_iphone,
      'tv': Symbols.tv,
      'laundry': Symbols.local_laundry_service,
      'mop': Symbols.mop,
    },
    'Health': {
      'medical_services': Symbols.medical_services,
      'fitness_center': Symbols.fitness_center,
      'health_and_safety': Symbols.health_and_safety,
      'psychology': Symbols.psychology,
      'medication': Symbols.medication,
      'vaccines': Symbols.vaccines,
    },
    'Entertainment': {
      'sports_esports': Symbols.sports_esports,
      'movie': Symbols.movie,
      'music_note': Symbols.music_note,
      'theater_comedy': Symbols.theater_comedy,
      'stadium': Symbols.stadium,
      'videogame_asset': Symbols.videogame_asset,
    },
    'Other': {
      'school': Symbols.school,
      'pets': Symbols.pets,
      'work': Symbols.work,
      'charity': Symbols.volunteer_activism,
      'category': Symbols.category,
      'label': Symbols.label,
      'event': Symbols.event,
      'person': Symbols.person,
      'group': Symbols.group,
      'public': Symbols.public,
      'eco': Symbols.eco,
      'auto_awesome': Symbols.auto_awesome,
    },
  };

  static Map<String, IconData> get allIcons {
    final Map<String, IconData> all = {};
    for (final category in categories.values) {
      all.addAll(category);
    }
    return all;
  }

  static IconData getIcon(String? name) {
    return allIcons[name] ?? Symbols.category;
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
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Select Icon',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: AppIcons.categories.length,
              itemBuilder: (context, index) {
                final categoryName = AppIcons.categories.keys.elementAt(index);
                final categoryIcons = AppIcons.categories[categoryName]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                      child: Text(
                        categoryName.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: categoryIcons.length,
                      itemBuilder: (context, i) {
                        final entry = categoryIcons.entries.elementAt(i);
                        final isSelected = entry.key == selectedIcon;

                        return Consumer(
                          builder: (context, ref, _) {
                            final fillIcons = ref.watch(personalizationProvider).fillIcons;
                            return InkWell(
                              onTap: () => onIconSelected(entry.key),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? selectedColor.withValues(alpha: 0.1) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isSelected ? Border.all(color: selectedColor, width: 2) : null,
                                ),
                                child: Icon(
                                  entry.value,
                                  color: isSelected ? selectedColor : null,
                                  fill: fillIcons ? 1.0 : 0.0,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
