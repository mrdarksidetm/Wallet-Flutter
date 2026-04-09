import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_symbols_icons/symbols_map.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../theme/personalization_provider.dart';

class IconMetadata {
  final String name;
  final List<String> categories;
  final List<String> tags;
  final String source; // 'ms' (material symbols), 'mdi', 'fa'

  IconMetadata({required this.name, required this.categories, required this.tags, this.source = 'ms'});

  factory IconMetadata.fromJson(Map<String, dynamic> json) {
    return IconMetadata(
      name: json['name'] as String,
      categories: List<String>.from(json['categories'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      source: json['source'] as String? ?? 'ms',
    );
  }
}

/// Provider to track and persist recently used icons.
final recentIconsProvider = StateNotifierProvider<RecentIconsNotifier, List<String>>((ref) {
  return RecentIconsNotifier();
});

class RecentIconsNotifier extends StateNotifier<List<String>> {
  RecentIconsNotifier() : super([]) {
    _loadRecents();
  }

  static const _key = 'recent_icons';

  Future<void> _loadRecents() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_key) ?? [];
  }

  Future<void> addIcon(String name) async {
    final newList = [name, ...state.where((i) => i != name)].take(20).toList();
    state = newList;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newList);
  }
}

class AppIcons {
  static final Map<String, IconData> _iconCache = {};

  static IconData getIcon(String? name) {
    if (name == null || name.isEmpty) return Symbols.category;
    if (_iconCache.containsKey(name)) return _iconCache[name]!;

    IconData? icon;

    // 1. Resolve by prefix
    if (name.startsWith('mdi:')) {
      final iconName = name.substring(4);
      icon = MdiIcons.fromString(iconName);
    } else if (name.startsWith('fa:')) {
      final iconName = name.substring(3);
      // Fallback for FA as it's harder to resolve dynamically without reflection
      // We use a basic mapping or default
      icon = _getFaIcon(iconName);
    } else {
      // Default to Material Symbols
      icon = materialSymbolsMap[name];
    }

    if (icon != null) {
      _iconCache[name] = icon;
      return icon;
    }
    return Symbols.category;
  }

  static IconData? _getFaIcon(String name) {
    // Basic common FA icons mapping
    final Map<String, IconData> faMap = {
      'wallet': FontAwesomeIcons.wallet,
      'bank': FontAwesomeIcons.bank,
      'credit-card': FontAwesomeIcons.creditCard,
      'money-bill': FontAwesomeIcons.moneyBill,
      'chart-pie': FontAwesomeIcons.chartPie,
      'car': FontAwesomeIcons.car,
      'house': FontAwesomeIcons.house,
      'burger': FontAwesomeIcons.burger,
      'gift': FontAwesomeIcons.gift,
      'heart': FontAwesomeIcons.heart,
    };
    return faMap[name];
  }
}

class IconPickerWidget extends ConsumerStatefulWidget {
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
  ConsumerState<IconPickerWidget> createState() => _IconPickerWidgetState();
}

class _IconPickerWidgetState extends ConsumerState<IconPickerWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedSource = 'All'; // 'All', 'Material Symbols', 'Material Design', 'FontAwesome'
  List<IconMetadata> _allIcons = [];
  List<String> _dynamicCategories = ['All', 'Recent'];
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
      
      final loadedIcons = icons.map((i) => IconMetadata.fromJson(i)).toList();
      
      // Inject some popular MDI and FA icons for testing since we don't have their full JSON yet
      // In a real app, we would have a combined JSON or multiple JSONs
      _injectExtraIcons(loadedIcons);

      // Extract dynamic categories
      final Set<String> categories = {};
      for (var icon in loadedIcons) {
        for (var cat in icon.categories) {
          if (cat.isNotEmpty) categories.add(cat);
        }
      }
      
      final sortedCats = categories.toList()..sort();

      if (mounted) {
        setState(() {
          _allIcons = loadedIcons;
          _dynamicCategories = ['All', 'Recent', ...sortedCats.map((c) => _capitalize(c))];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading icon metadata: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _injectExtraIcons(List<IconMetadata> target) {
    // Inject MDI
    target.add(IconMetadata(name: 'mdi:wallet', categories: ['finance'], tags: ['money', 'wallet'], source: 'mdi'));
    target.add(IconMetadata(name: 'mdi:piggy-bank', categories: ['finance'], tags: ['savings'], source: 'mdi'));
    target.add(IconMetadata(name: 'mdi:car-electric', categories: ['transport'], tags: ['tesla', 'car'], source: 'mdi'));
    
    // Inject FA
    target.add(IconMetadata(name: 'fa:wallet', categories: ['finance'], tags: ['money'], source: 'fa'));
    target.add(IconMetadata(name: 'fa:bank', categories: ['places'], tags: ['bank'], source: 'fa'));
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          _buildSearchHeader(colorScheme, textTheme),
          const SizedBox(height: 16),
          _buildSourceTabs(colorScheme),
          const SizedBox(height: 8),
          if (!_isLoading) _buildCategoryChips(),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildIconGrid(colorScheme, textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Icon',
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              if (_searchQuery.isNotEmpty)
                Text(
                  '${_getFilteredIcons().length} results',
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search 5,000+ icons (e.g. food, car)...',
              prefixIcon: Icon(Symbols.search, color: colorScheme.primary),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceTabs(ColorScheme colorScheme) {
    final sources = ['All', 'Material Symbols', 'Material Design', 'FontAwesome'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: sources.map((source) {
            final isSelected = _selectedSource == source;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(source, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedSource = source;
                    _selectedCategory = 'All'; // Reset category when changing source
                  });
                },
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _dynamicCategories.length,
        itemBuilder: (context, index) {
          final cat = _dynamicCategories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat, style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedCategory = cat);
              },
              showCheckmark: false,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconGrid(ColorScheme colorScheme, TextTheme textTheme) {
    final filteredIcons = _getFilteredIcons();
    final fillIcons = ref.watch(personalizationProvider).fillIcons;

    if (filteredIcons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.search_off, size: 64, color: colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text('No matching icons', style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline)),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: GridView.builder(
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

          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 300),
            columnCount: 5,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: InkWell(
                  onTap: () {
                    ref.read(recentIconsProvider.notifier).addIcon(iconMeta.name);
                    widget.onIconSelected(iconMeta.name);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isSelected ? widget.selectedColor.withValues(alpha: 0.15) : colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected ? Border.all(color: widget.selectedColor, width: 2) : null,
                        ),
                        child: Center(
                          child: Icon(
                            iconData,
                            color: isSelected ? widget.selectedColor : colorScheme.onSurface,
                            fill: (fillIcons && iconMeta.source == 'ms') ? 1.0 : 0.0,
                            size: 28,
                          ),
                        ),
                      ),
                      if (iconMeta.source != 'ms')
                        Positioned(
                          right: 4, bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
                            child: Text(
                              iconMeta.source.toUpperCase(), 
                              style: TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<IconMetadata> _getFilteredIcons() {
    final query = _searchQuery.toLowerCase();
    
    // 1. Handle "Recent" category
    if (_selectedCategory == 'Recent') {
      final recents = ref.watch(recentIconsProvider);
      return recents.map((name) => _allIcons.firstWhere((i) => i.name == name, 
          orElse: () => IconMetadata(name: name, categories: [], tags: [], source: 'ms'))).toList();
    }

    // 2. Main Filter Logic
    return _allIcons.where((icon) {
      // Source Filter
      if (_selectedSource == 'Material Symbols' && icon.source != 'ms') return false;
      if (_selectedSource == 'Material Design' && icon.source != 'mdi') return false;
      if (_selectedSource == 'FontAwesome' && icon.source != 'fa') return false;

      // Category Filter
      if (_selectedCategory != 'All' && 
          !icon.categories.contains(_selectedCategory.toLowerCase())) {
        return false;
      }

      // Search Filter
      if (query.isNotEmpty) {
        if (icon.name.contains(query)) return true;
        if (icon.tags.any((tag) => tag.contains(query))) return true;
        return false;
      }
      return true;
    }).toList();
  }
}
