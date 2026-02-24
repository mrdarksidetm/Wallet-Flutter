import 'package:flutter/material.dart';

class MaterialIconPicker extends StatefulWidget {
  final IconData? initialIcon;
  final ValueChanged<IconData> onIconSelected;

  const MaterialIconPicker({
    super.key,
    this.initialIcon,
    required this.onIconSelected,
  });

  @override
  State<MaterialIconPicker> createState() => _MaterialIconPickerState();
}

class _MaterialIconPickerState extends State<MaterialIconPicker> {
  String _searchQuery = '';
  late List<MapEntry<String, IconData>> _filteredIcons;

  // A comprehensive list of common Material Icons for the user to choose from.
  static const Map<String, IconData> _icons = {
    'Category': Icons.category,
    'Fast Food': Icons.fastfood,
    'Restaurant': Icons.restaurant,
    'Local Dining': Icons.local_dining,
    'Coffee': Icons.coffee,
    'Local Cafe': Icons.local_cafe,
    'Car': Icons.directions_car,
    'Commute': Icons.commute,
    'Local Gas Station': Icons.local_gas_station,
    'Flight': Icons.flight,
    'Home': Icons.home,
    'House': Icons.house,
    'Weekend': Icons.weekend,
    'Shopping Cart': Icons.shopping_cart,
    'Shopping Bag': Icons.shopping_bag,
    'Store': Icons.store,
    'Phone': Icons.phone,
    'Smartphone': Icons.smartphone,
    'Computer': Icons.computer,
    'Laptop': Icons.laptop,
    'Device Hub': Icons.device_hub,
    'Movies': Icons.movie,
    'Theater': Icons.theaters,
    'Music': Icons.music_note,
    'Audiotrack': Icons.audiotrack,
    'Fitness Center': Icons.fitness_center,
    'Pool': Icons.pool,
    'Medical Services': Icons.medical_services,
    'Local Hospital': Icons.local_hospital,
    'Health Information': Icons.health_and_safety,
    'School': Icons.school,
    'Book': Icons.book,
    'Local Library': Icons.local_library,
    'Pets': Icons.pets,
    'Money': Icons.attach_money,
    'Wallet': Icons.account_balance_wallet,
    'Account Balance': Icons.account_balance,
    'Savings': Icons.savings,
    'Credit Card': Icons.credit_card,
    'Receipt': Icons.receipt,
    'Paid': Icons.paid,
    'Work': Icons.work,
    'Business Center': Icons.business_center,
    'Card Travel': Icons.card_travel,
    'Gift': Icons.card_giftcard,
    'Spa': Icons.spa,
    'Beach': Icons.beach_access,
    'Airport Shuttle': Icons.airport_shuttle,
    'Ev Station': Icons.ev_station,
    'Subway': Icons.subway,
    'Train': Icons.train,
    'Two Wheeler': Icons.two_wheeler,
    'Pedal Bike': Icons.pedal_bike,
    'Sailing': Icons.sailing,
    'Local Grocery Store': Icons.local_grocery_store,
    'Local Convenience Store': Icons.local_convenience_store,
    'Local Mall': Icons.local_mall,
    'Local Pharmacy': Icons.local_pharmacy,
    'Local Florist': Icons.local_florist,
    'Local Laundry Service': Icons.local_laundry_service,
  }; // Expanded this list considerably

  @override
  void initState() {
    super.initState();
    _filterIcons('');
  }

  void _filterIcons(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredIcons = _icons.entries
          .where((entry) => entry.key.toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search Icons...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _filterIcons,
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _filteredIcons.length,
            itemBuilder: (context, index) {
              final iconEntry = _filteredIcons[index];
              return InkWell(
                onTap: () => widget.onIconSelected(iconEntry.value),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iconEntry.value,
                      color: widget.initialIcon == iconEntry.value
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      iconEntry.key,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
