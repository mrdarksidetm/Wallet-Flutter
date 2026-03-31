import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../theme/personalization_provider.dart';

class AppIcons {
  static const Map<String, Map<String, IconData>> categories = {
    'Finance': {
      'account_balance': Symbols.account_balance,
      'account_balance_wallet': Symbols.account_balance_wallet,
      'add_card': Symbols.add_card,
      'attach_money': Symbols.attach_money,
      'credit_card': Symbols.credit_card,
      'currency_exchange': Symbols.currency_exchange,
      'currency_rupee': Symbols.currency_rupee,
      'currency_yen': Symbols.currency_yen,
      'currency_pound': Symbols.currency_pound,
      'euro': Symbols.euro,
      'monetization_on': Symbols.monetization_on,
      'payments': Symbols.payments,
      'pie_chart': Symbols.pie_chart,
      'price_check': Symbols.price_check,
      'receipt_long': Symbols.receipt_long,
      'request_quote': Symbols.request_quote,
      'savings': Symbols.savings,
      'trending_down': Symbols.trending_down,
      'trending_up': Symbols.trending_up,
      'wallet': Symbols.wallet,
    },
    'Shopping': {
      'barcode_scanner': Symbols.barcode_scanner,
      'card_giftcard': Symbols.card_giftcard,
      'confirmation_number': Symbols.confirmation_number,
      'local_mall': Symbols.local_mall,
      'redeem': Symbols.redeem,
      'sell': Symbols.sell,
      'shopping_bag': Symbols.shopping_bag,
      'shopping_basket': Symbols.shopping_basket,
      'shopping_cart': Symbols.shopping_cart,
      'storefront': Symbols.storefront,
    },
    'Food': {
      'bakery_dining': Symbols.bakery_dining,
      'cake': Symbols.cake,
      'coffee': Symbols.coffee,
      'dinner_dining': Symbols.dinner_dining,
      'egg': Symbols.egg,
      'fastfood': Symbols.fastfood,
      'icecream': Symbols.icecream,
      'local_grocery_store': Symbols.local_grocery_store,
      'local_pizza': Symbols.local_pizza,
      'lunch_dining': Symbols.lunch_dining,
      'restaurant': Symbols.restaurant,
      'wine_bar': Symbols.wine_bar,
    },
    'Transportation': {
      'commute': Symbols.commute,
      'directions_bike': Symbols.directions_bike,
      'directions_boat': Symbols.directions_boat,
      'directions_bus': Symbols.directions_bus,
      'directions_car': Symbols.directions_car,
      'directions_railway': Symbols.directions_railway,
      'ev_station': Symbols.ev_station,
      'flight': Symbols.flight,
      'local_shipping': Symbols.local_shipping,
      'local_taxi': Symbols.local_taxi,
    },
    'Home': {
      'bed': Symbols.bed,
      'bolt': Symbols.bolt,
      'chair': Symbols.chair,
      'home': Symbols.home,
      'kitchen': Symbols.kitchen,
      'light': Symbols.light,
      'local_laundry_service': Symbols.local_laundry_service,
      'mop': Symbols.mop,
      'phone_iphone': Symbols.phone_iphone,
      'tv': Symbols.tv,
      'water_drop': Symbols.water_drop,
      'wifi': Symbols.wifi,
    },
    'Health': {
      'fitness_center': Symbols.fitness_center,
      'health_and_safety': Symbols.health_and_safety,
      'medical_services': Symbols.medical_services,
      'medication': Symbols.medication,
      'psychology': Symbols.psychology,
      'self_care': Symbols.self_care,
      'spa': Symbols.spa,
      'vaccines': Symbols.vaccines,
    },
    'Entertainment': {
      'brush': Symbols.brush,
      'movie': Symbols.movie,
      'music_note': Symbols.music_note,
      'palette': Symbols.palette,
      'piano': Symbols.piano,
      'sports_esports': Symbols.sports_esports,
      'stadium': Symbols.stadium,
      'theater_comedy': Symbols.theater_comedy,
      'videogame_asset': Symbols.videogame_asset,
    },
    'Other': {
      'auto_awesome': Symbols.auto_awesome,
      'build': Symbols.build,
      'category': Symbols.category,
      'charity': Symbols.volunteer_activism,
      'cloud': Symbols.cloud,
      'eco': Symbols.eco,
      'event': Symbols.event,
      'group': Symbols.group,
      'label': Symbols.label,
      'person': Symbols.person,
      'public': Symbols.public,
      'security': Symbols.security,
      'vibration': Symbols.vibration,
      'work': Symbols.work,
      'school': Symbols.school,
      'pets': Symbols.pets,
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
    if (name == null) return Symbols.category;
    return allIcons[name] ?? Symbols.category;
  }
}

class IconPickerWidget extends StatefulWidget {
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
  State<IconPickerWidget> createState() => _IconPickerWidgetState();
}

class _IconPickerWidgetState extends State<IconPickerWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header & Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Icon',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search icons...',
                    prefixIcon: const Icon(Symbols.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Symbols.close),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Category Chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                'All',
                ...AppIcons.categories.keys,
              ].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Icon Grid
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final fillIcons = ref.watch(personalizationProvider).fillIcons;
                final filteredIcons = _getFilteredIcons();

                if (filteredIcons.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Symbols.search_off, size: 48, color: colorScheme.outline),
                        const SizedBox(height: 16),
                        Text('No icons found for "$_searchQuery"', 
                          style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline)),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: filteredIcons.length,
                  itemBuilder: (context, index) {
                    final entry = filteredIcons[index];
                    final isSelected = widget.selectedIcon == entry.key;

                    return InkWell(
                      onTap: () => widget.onIconSelected(entry.key),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? widget.selectedColor.withValues(alpha: 0.15)
                              : colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(color: widget.selectedColor, width: 2)
                              : null,
                        ),
                        child: Icon(
                          entry.value,
                          color: isSelected ? widget.selectedColor : colorScheme.onSurface,
                          fill: fillIcons ? 1.0 : 0.0,
                          size: 28,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<MapEntry<String, IconData>> _getFilteredIcons() {
    List<MapEntry<String, IconData>> icons = [];

    if (_selectedCategory == 'All') {
      icons = AppIcons.allIcons.entries.toList();
    } else {
      final catIcons = AppIcons.categories[_selectedCategory]!;
      icons = catIcons.entries.toList();
    }

    if (_searchQuery.isNotEmpty) {
      icons = icons
          .where((e) => e.key.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Sort alphabetically for easier browsing
    icons.sort((a, b) => a.key.compareTo(b.key));
    return icons;
  }
}
