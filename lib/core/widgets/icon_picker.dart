import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_symbols_icons/symbols_map.dart';
import '../theme/personalization_provider.dart';

class IconMetadata {
  final String name;
  final List<String> categories;
  final List<String> tags;

  IconMetadata({required this.name, required this.categories, required this.tags});

  factory IconMetadata.fromJson(Map<String, dynamic> json) {
    return IconMetadata(
      name: json['name'] as String,
      categories: List<String>.from(json['categories']),
      tags: List<String>.from(json['tags']),
    );
  }
}

class AppIcons {
  static final Map<String, IconData> _iconCache = {};

  static IconData getIcon(String? name) {
    if (name == null || name.isEmpty) return Symbols.category;
    
    // Check cache first
    if (_iconCache.containsKey(name)) return _iconCache[name]!;

    // materialSymbolsMap provides a direct string-to-IconData mapping
    // for all icons in the package.
    final icon = materialSymbolsMap[name];
    if (icon != null) {
      _iconCache[name] = icon;
      return icon;
    }

    return Symbols.category;
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
  List<IconMetadata> _allIcons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      final String response = await rootBundle.loadString('assets/metadata/icons.json');
      final data = json.decode(response);
      final List icons = data['icons'];
      
      setState(() {
        _allIcons = icons.map((i) => IconMetadata.fromJson(i)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading icon metadata: $e');
      setState(() => _isLoading = false);
    }
  }

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
                    hintText: 'Search 3,000+ icons (e.g. car, bill, bank)...',
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
          if (!_isLoading) _buildCategoryChips(),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildIconGrid(colorScheme, textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['All', 'Action', 'Alert', 'Audio', 'Communication', 'Content', 'Device', 'Editor', 'File', 'Hardware', 'Home', 'Maps', 'Navigation', 'Notification', 'Photography', 'Places', 'Social', 'Sport', 'Transportation', 'Travel'];
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
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
        },
      ),
    );
  }

  Widget _buildIconGrid(ColorScheme colorScheme, TextTheme textTheme) {
    final filteredIcons = _getFilteredIcons();

    if (filteredIcons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.search_off, size: 48, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text('No icons found', style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline)),
          ],
        ),
      );
    }

    return Consumer(
      builder: (context, ref, _) {
        final fillIcons = ref.watch(personalizationProvider).fillIcons;
        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: filteredIcons.length,
          itemBuilder: (context, index) {
            final iconMeta = filteredIcons[index];
            final isSelected = widget.selectedIcon == iconMeta.name;
            final iconData = AppIcons.getIcon(iconMeta.name);

            return InkWell(
              onTap: () => widget.onIconSelected(iconMeta.name),
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
                  iconData,
                  color: isSelected ? widget.selectedColor : colorScheme.onSurface,
                  fill: fillIcons ? 1.0 : 0.0,
                  size: 28,
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<IconMetadata> _getFilteredIcons() {
    final Map<String, List<String>> keywordMap = {
      'car': ['transportation', 'auto', 'vehicle', 'drive', 'garage'],
      'bill': ['editor', 'payment', 'receipt', 'invoice', 'money', 'finance'],
      'bank': ['places', 'account', 'finance', 'money', 'safe', 'business'],
      'food': ['places', 'restaurant', 'cafe', 'eat', 'dinner', 'lunch', 'dining'],
      'shop': ['places', 'shopping', 'store', 'cart', 'buy', 'retail'],
      'health': ['alert', 'medical', 'hospital', 'doctor', 'fitness', 'wellness'],
      'home': ['home', 'house', 'living', 'building', 'room'],
      'tech': ['device', 'computer', 'laptop', 'smartphone', 'electronics'],
      'travel': ['travel', 'flight', 'airplane', 'hotel', 'trip', 'vacation'],
      'social': ['social', 'people', 'friends', 'chat', 'message', 'group'],
    };

    return _allIcons.where((icon) {
      // Filter by category
      if (_selectedCategory != 'All' && !icon.categories.contains(_selectedCategory.toLowerCase())) {
        return false;
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        
        // Exact name match or substring name match
        if (icon.name.contains(query)) return true;
        
        // Check tags
        if (icon.tags.any((tag) => tag.contains(query))) return true;

        // Smart search using keyword mapping
        for (var entry in keywordMap.entries) {
          if (query.contains(entry.key)) {
            // Check if icon has any of the mapped keywords in its name, categories or tags
            for (var keyword in entry.value) {
              if (icon.name.contains(keyword)) return true;
              if (icon.categories.contains(keyword)) return true;
              if (icon.tags.contains(keyword)) return true;
            }
          }
        }

        return false;
      }

      return true;
    }).toList();
  }
}
