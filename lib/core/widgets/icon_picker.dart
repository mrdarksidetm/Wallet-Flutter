import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_symbols_icons/symbols_map.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
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
  static Map<String, IconData>? _mdiNameMap;

  static IconData getIcon(String? name, {String? style}) {
    if (name == null || name.isEmpty) return Symbols.category;
    
    final cacheKey = style != null ? '$name:$style' : name;
    if (_iconCache.containsKey(cacheKey)) return _iconCache[cacheKey]!;

    IconData? icon;

    // 1. Resolve by prefix
    if (name.startsWith('mdi:')) {
      final iconName = name.substring(4);
      icon = _getMdiIcon(iconName);
    } else if (name.startsWith('fa:')) {
      final iconName = name.substring(3);
      icon = _getFaIcon(iconName);
    } else if (name.startsWith('mi:')) {
      // Standard Material Icons fallback
      final iconName = name.substring(3);
      icon = _getMiIcon(iconName);
    } else {
      // Default to Material Symbols with style support
      // To support dynamic styles without breaking icon tree shaking (which requires const IconData),
      // we look up the pre-defined styled icon from the materialSymbolsMap instead of
      // creating a new IconData at runtime.
      String lookupName = name;
      
      // Strip any existing style suffix to avoid name_rounded_rounded
      if (lookupName.endsWith('_rounded')) {
        lookupName = lookupName.substring(0, lookupName.length - 8);
      } else if (lookupName.endsWith('_sharp')) {
        lookupName = lookupName.substring(0, lookupName.length - 6);
      }

      if (style != null && style != 'Outlined') {
        final styledName = '${lookupName}_${style.toLowerCase()}';
        icon = materialSymbolsMap[styledName] ?? materialSymbolsMap[lookupName];
      } else {
        icon = materialSymbolsMap[lookupName];
      }
    }

    if (icon != null) {
      _iconCache[cacheKey] = icon;
      return icon;
    }
    return Symbols.category;
  }

  static IconData? _getMdiIcon(String name) {
    if (_mdiNameMap == null) {
      _mdiNameMap = {};
      for (final icon in MdiIcons.values) {
        final meta = MdiIcons.maybeMetadataOf(icon);
        if (meta != null) {
          _mdiNameMap![meta.name] = icon;
        }
      }
    }
    return _mdiNameMap![name];
  }

  static IconData? _getMiIcon(String name) {
    // Basic mapping for common Material Icons not in Symbols
    // This is a safety fallback
    return null; 
  }

  static IconData? _getFaIcon(String name) {
    final Map<String, IconData> faMap = {
      // Finance & Commerce
      'wallet': FontAwesomeIcons.wallet.data, 'bank': FontAwesomeIcons.bank.data, 'credit-card': FontAwesomeIcons.creditCard.data,
      'money-bill': FontAwesomeIcons.moneyBill.data, 'coins': FontAwesomeIcons.coins.data, 'money-check-dollar': FontAwesomeIcons.moneyCheckDollar.data,
      'receipt': FontAwesomeIcons.receipt.data, 'piggy-bank': FontAwesomeIcons.piggyBank.data, 'landmark': FontAwesomeIcons.landmark.data,
      'dollar-sign': FontAwesomeIcons.dollarSign.data, 'euro-sign': FontAwesomeIcons.euroSign.data, 'bitcoin': FontAwesomeIcons.bitcoin.data,
      'shopping-bag': FontAwesomeIcons.shoppingBag.data, 'shopping-cart': FontAwesomeIcons.shoppingCart.data, 'tag': FontAwesomeIcons.tag.data,
      'store': FontAwesomeIcons.store.data, 'briefcase': FontAwesomeIcons.briefcase.data, 'sack-dollar': FontAwesomeIcons.sackDollar.data,
      'hand-holding-dollar': FontAwesomeIcons.handHoldingDollar.data, 'money-bill-transfer': FontAwesomeIcons.moneyBillTransfer.data,
      
      // Transport & Travel
      'car': FontAwesomeIcons.car.data, 'bicycle': FontAwesomeIcons.bicycle.data, 'bus': FontAwesomeIcons.bus.data,
      'plane': FontAwesomeIcons.plane.data, 'train': FontAwesomeIcons.train.data, 'gas-pump': FontAwesomeIcons.gasPump.data,
      'motorcycle': FontAwesomeIcons.motorcycle.data, 'truck': FontAwesomeIcons.truck.data, 'taxi': FontAwesomeIcons.taxi.data,
      'ship': FontAwesomeIcons.ship.data, 'hotel': FontAwesomeIcons.hotel.data, 'passport': FontAwesomeIcons.passport.data,
      
      // Food & Drink
      'burger': FontAwesomeIcons.burger.data, 'coffee': FontAwesomeIcons.coffee.data, 'utensils': FontAwesomeIcons.utensils.data,
      'wine-glass': FontAwesomeIcons.wineGlass.data, 'mug-hot': FontAwesomeIcons.mugHot.data, 'ice-cream': FontAwesomeIcons.iceCream.data,
      'apple-whole': FontAwesomeIcons.appleWhole.data, 'carrot': FontAwesomeIcons.carrot.data, 'pizza-slice': FontAwesomeIcons.pizzaSlice.data,
      'bowl-food': FontAwesomeIcons.bowlFood.data, 'cake-candles': FontAwesomeIcons.cakeCandles.data, 'glass-water': FontAwesomeIcons.glassWater.data,
      
      // Social & People
      'heart': FontAwesomeIcons.heart.data, 'star': FontAwesomeIcons.star.data, 'user': FontAwesomeIcons.user.data,
      'bell': FontAwesomeIcons.bell.data, 'camera': FontAwesomeIcons.camera.data, 'envelope': FontAwesomeIcons.envelope.data,
      'phone': FontAwesomeIcons.phone.data, 'location-dot': FontAwesomeIcons.locationDot.data, 'users': FontAwesomeIcons.users.data,
      'user-group': FontAwesomeIcons.userGroup.data, 'comment': FontAwesomeIcons.comment.data, 'share-nodes': FontAwesomeIcons.shareNodes.data,
      
      // Tech & Media
      'laptop': FontAwesomeIcons.laptop.data, 'mobile': FontAwesomeIcons.mobile.data, 'tv': FontAwesomeIcons.tv.data,
      'gamepad': FontAwesomeIcons.gamepad.data, 'music': FontAwesomeIcons.music.data, 'film': FontAwesomeIcons.film.data,
      'ticket': FontAwesomeIcons.ticket.data, 'headset': FontAwesomeIcons.headset.data, 'camera-retro': FontAwesomeIcons.cameraRetro.data,
      'microphone': FontAwesomeIcons.microphone.data, 'wifi': FontAwesomeIcons.wifi.data, 'bluetooth': FontAwesomeIcons.bluetooth.data,
      
      // Lifestyle & Home
      'house': FontAwesomeIcons.house.data, 'gift': FontAwesomeIcons.gift.data, 'shirt': FontAwesomeIcons.shirt.data,
      'graduation-cap': FontAwesomeIcons.graduationCap.data, 'couch': FontAwesomeIcons.couch.data, 'bed': FontAwesomeIcons.bed.data,
      'bath': FontAwesomeIcons.bath.data, 'umbrella': FontAwesomeIcons.umbrella.data, 'mountain': FontAwesomeIcons.mountain.data,
      'tree': FontAwesomeIcons.tree.data, 'sun': FontAwesomeIcons.sun.data, 'moon': FontAwesomeIcons.moon.data,
      
      // Health & Sports
      'medkit': FontAwesomeIcons.medkit.data, 'stethoscope': FontAwesomeIcons.stethoscope.data, 'pills': FontAwesomeIcons.pills.data,
      'dumbbell': FontAwesomeIcons.dumbbell.data, 'soccer-ball': FontAwesomeIcons.soccerBall.data, 'basketball': FontAwesomeIcons.basketball.data,
      'trophy': FontAwesomeIcons.trophy.data, 'heart-pulse': FontAwesomeIcons.heartPulse.data, 'prescription-bottle': FontAwesomeIcons.prescriptionBottle.data,
      'baseball': FontAwesomeIcons.baseball.data, 'football': FontAwesomeIcons.football.data,
      
      // Tools & Others
      'gear': FontAwesomeIcons.gear.data, 'tools': FontAwesomeIcons.tools.data, 'wrench': FontAwesomeIcons.wrench.data,
      'hammer': FontAwesomeIcons.hammer.data, 'screwdriver-wrench': FontAwesomeIcons.screwdriverWrench.data, 'brush': FontAwesomeIcons.brush.data,
      'key': FontAwesomeIcons.key.data, 'lock': FontAwesomeIcons.lock.data, 'trash': FontAwesomeIcons.trash.data,
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
  String _selectedSource = 'All'; 
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
      // 1. Dynamic Discovery of ALL Material Symbols (Direct from package map)
      final List<IconMetadata> symbols = materialSymbolsMap.keys.map((name) => IconMetadata(
        name: name,
        categories: ['symbols'],
        tags: [name.replaceAll('_', ' ')],
        source: 'ms'
      )).toList();

      // 2. Dynamic Discovery of ALL Material Design Icons (Direct from package)
      final List<IconMetadata> mdi = MdiIcons.values.map((icon) {
        final meta = MdiIcons.maybeMetadataOf(icon);
        final name = meta?.name ?? '';
        final List<String> cats = [];
        
        // Heuristic categorization for MDI
        final lowerName = name.toLowerCase();
        if (RegExp(r'cash|bank|wallet|money|credit|currency|account-balance|finance|check|bill|coins|receipt').hasMatch(lowerName)) cats.add('finance');
        if (RegExp(r'food|restaurant|coffee|fruit|vegetable|beer|cup|pizza|burger|ice-cream|cafe|drink').hasMatch(lowerName)) cats.add('food');
        if (RegExp(r'car|bus|train|plane|bike|truck|transport|navigation|map|location|gps|travel').hasMatch(lowerName)) cats.add('transport');
        if (RegExp(r'account|person|human|chat|message|social|user|heart|star|friends|family|people').hasMatch(lowerName)) cats.add('social');
        if (RegExp(r'health|medical|hospital|heart|doctor|pill|fitness|gym|running|wellness').hasMatch(lowerName)) cats.add('health');
        if (RegExp(r'tool|wrench|hammer|cog|setting|build|repair|maintenance|config').hasMatch(lowerName)) cats.add('tools');
        if (RegExp(r'shopping|cart|bag|tag|store|commerce|sell|buy|price').hasMatch(lowerName)) cats.add('shopping');
        if (RegExp(r'laptop|mobile|tv|gamepad|computer|phone|tech|digital|electronics').hasMatch(lowerName)) cats.add('tech');
        if (RegExp(r'house|home|building|lifestyle|music|film|movie|ticket|art|design|style').hasMatch(lowerName)) cats.add('lifestyle');
        
        return IconMetadata(
          name: 'mdi:$name',
          categories: cats.isEmpty ? ['mdi'] : cats,
          tags: [name.replaceAll('-', ' ')],
          source: 'mdi'
        );
      }).where((m) => m.name != 'mdi:').toList();

      // 3. Comprehensive FontAwesome list with explicit categories
      final List<IconMetadata> fa = [
        // Finance
        IconMetadata(name: 'fa:wallet', categories: ["finance"], tags: ['wallet'], source: 'fa'),
        IconMetadata(name: 'fa:bank', categories: ["finance"], tags: ['bank'], source: 'fa'),
        IconMetadata(name: 'fa:credit-card', categories: ["finance"], tags: ['credit card'], source: 'fa'),
        IconMetadata(name: 'fa:money-bill', categories: ["finance"], tags: ['money bill'], source: 'fa'),
        IconMetadata(name: 'fa:coins', categories: ["finance"], tags: ['coins'], source: 'fa'),
        IconMetadata(name: 'fa:money-check-dollar', categories: ["finance"], tags: ['money check dollar'], source: 'fa'),
        IconMetadata(name: 'fa:receipt', categories: ["finance"], tags: ['receipt'], source: 'fa'),
        IconMetadata(name: 'fa:piggy-bank', categories: ["finance"], tags: ['piggy bank'], source: 'fa'),
        IconMetadata(name: 'fa:landmark', categories: ["finance"], tags: ['landmark'], source: 'fa'),
        IconMetadata(name: 'fa:dollar-sign', categories: ["finance"], tags: ['dollar sign'], source: 'fa'),
        IconMetadata(name: 'fa:euro-sign', categories: ["finance"], tags: ['euro sign'], source: 'fa'),
        IconMetadata(name: 'fa:bitcoin', categories: ["finance"], tags: ['bitcoin'], source: 'fa'),
        IconMetadata(name: 'fa:sack-dollar', categories: ["finance"], tags: ['sack dollar'], source: 'fa'),
        IconMetadata(name: 'fa:hand-holding-dollar', categories: ["finance"], tags: ['hand holding dollar'], source: 'fa'),
        IconMetadata(name: 'fa:money-bill-transfer', categories: ["finance"], tags: ['money bill transfer'], source: 'fa'),
        
        // Transport
        IconMetadata(name: 'fa:car', categories: ["transport"], tags: ['car'], source: 'fa'),
        IconMetadata(name: 'fa:bicycle', categories: ["transport"], tags: ['bicycle'], source: 'fa'),
        IconMetadata(name: 'fa:bus', categories: ["transport"], tags: ['bus'], source: 'fa'),
        IconMetadata(name: 'fa:plane', categories: ["transport"], tags: ['plane'], source: 'fa'),
        IconMetadata(name: 'fa:train', categories: ["transport"], tags: ['train'], source: 'fa'),
        IconMetadata(name: 'fa:gas-pump', categories: ["transport"], tags: ['gas pump'], source: 'fa'),
        IconMetadata(name: 'fa:motorcycle', categories: ["transport"], tags: ['motorcycle'], source: 'fa'),
        IconMetadata(name: 'fa:truck', categories: ["transport"], tags: ['truck'], source: 'fa'),
        IconMetadata(name: 'fa:taxi', categories: ["transport"], tags: ['taxi'], source: 'fa'),
        IconMetadata(name: 'fa:ship', categories: ["transport"], tags: ['ship'], source: 'fa'),
        IconMetadata(name: 'fa:hotel', categories: ["transport"], tags: ['hotel'], source: 'fa'),
        IconMetadata(name: 'fa:passport', categories: ["transport"], tags: ['passport'], source: 'fa'),
        
        // Food
        IconMetadata(name: 'fa:burger', categories: ["food"], tags: ['burger'], source: 'fa'),
        IconMetadata(name: 'fa:coffee', categories: ["food"], tags: ['coffee'], source: 'fa'),
        IconMetadata(name: 'fa:utensils', categories: ["food"], tags: ['utensils'], source: 'fa'),
        IconMetadata(name: 'fa:wine-glass', categories: ["food"], tags: ['wine glass'], source: 'fa'),
        IconMetadata(name: 'fa:mug-hot', categories: ["food"], tags: ['mug hot'], source: 'fa'),
        IconMetadata(name: 'fa:ice-cream', categories: ["food"], tags: ['ice cream'], source: 'fa'),
        IconMetadata(name: 'fa:apple-whole', categories: ["food"], tags: ['apple whole'], source: 'fa'),
        IconMetadata(name: 'fa:carrot', categories: ["food"], tags: ['carrot'], source: 'fa'),
        IconMetadata(name: 'fa:pizza-slice', categories: ["food"], tags: ['pizza slice'], source: 'fa'),
        IconMetadata(name: 'fa:bowl-food', categories: ["food"], tags: ['bowl food'], source: 'fa'),
        IconMetadata(name: 'fa:cake-candles', categories: ["food"], tags: ['cake candles'], source: 'fa'),
        IconMetadata(name: 'fa:glass-water', categories: ["food"], tags: ['glass water'], source: 'fa'),
        
        // Social
        IconMetadata(name: 'fa:heart', categories: ["social"], tags: ['heart'], source: 'fa'),
        IconMetadata(name: 'fa:star', categories: ["social"], tags: ['star'], source: 'fa'),
        IconMetadata(name: 'fa:user', categories: ["social"], tags: ['user'], source: 'fa'),
        IconMetadata(name: 'fa:bell', categories: ["social"], tags: ['bell'], source: 'fa'),
        IconMetadata(name: 'fa:camera', categories: ["social"], tags: ['camera'], source: 'fa'),
        IconMetadata(name: 'fa:envelope', categories: ["social"], tags: ['envelope'], source: 'fa'),
        IconMetadata(name: 'fa:phone', categories: ["social"], tags: ['phone'], source: 'fa'),
        IconMetadata(name: 'fa:location-dot', categories: ["social"], tags: ['location dot'], source: 'fa'),
        IconMetadata(name: 'fa:users', categories: ["social"], tags: ['users'], source: 'fa'),
        IconMetadata(name: 'fa:user-group', categories: ["social"], tags: ['user group'], source: 'fa'),
        IconMetadata(name: 'fa:comment', categories: ["social"], tags: ['comment'], source: 'fa'),
        IconMetadata(name: 'fa:share-nodes', categories: ["social"], tags: ['share nodes'], source: 'fa'),
        
        // Tech
        IconMetadata(name: 'fa:laptop', categories: ["tech"], tags: ['laptop'], source: 'fa'),
        IconMetadata(name: 'fa:mobile', categories: ["tech"], tags: ['mobile'], source: 'fa'),
        IconMetadata(name: 'fa:tv', categories: ["tech"], tags: ['tv'], source: 'fa'),
        IconMetadata(name: 'fa:gamepad', categories: ["tech"], tags: ['gamepad'], source: 'fa'),
        IconMetadata(name: 'fa:headset', categories: ["tech"], tags: ['headset'], source: 'fa'),
        IconMetadata(name: 'fa:camera-retro', categories: ["tech"], tags: ['camera retro'], source: 'fa'),
        IconMetadata(name: 'fa:microphone', categories: ["tech"], tags: ['microphone'], source: 'fa'),
        IconMetadata(name: 'fa:wifi', categories: ["tech"], tags: ['wifi'], source: 'fa'),
        IconMetadata(name: 'fa:bluetooth', categories: ["tech"], tags: ['bluetooth'], source: 'fa'),
        
        // Tools
        IconMetadata(name: 'fa:gear', categories: ["tools"], tags: ['gear'], source: 'fa'),
        IconMetadata(name: 'fa:tools', categories: ["tools"], tags: ['tools'], source: 'fa'),
        IconMetadata(name: 'fa:wrench', categories: ["tools"], tags: ['wrench'], source: 'fa'),
        IconMetadata(name: 'fa:hammer', categories: ["tools"], tags: ['hammer'], source: 'fa'),
        IconMetadata(name: 'fa:briefcase', categories: ["tools"], tags: ['briefcase'], source: 'fa'),
        IconMetadata(name: 'fa:screwdriver-wrench', categories: ["tools"], tags: ['screwdriver wrench'], source: 'fa'),
        IconMetadata(name: 'fa:brush', categories: ["tools"], tags: ['brush'], source: 'fa'),
        IconMetadata(name: 'fa:key', categories: ["tools"], tags: ['key'], source: 'fa'),
        IconMetadata(name: 'fa:lock', categories: ["tools"], tags: ['lock'], source: 'fa'),
        IconMetadata(name: 'fa:trash', categories: ["tools"], tags: ['trash'], source: 'fa'),
        
        // Health
        IconMetadata(name: 'fa:medkit', categories: ["health"], tags: ['medkit'], source: 'fa'),
        IconMetadata(name: 'fa:stethoscope', categories: ["health"], tags: ['stethoscope'], source: 'fa'),
        IconMetadata(name: 'fa:pills', categories: ["health"], tags: ['pills'], source: 'fa'),
        IconMetadata(name: 'fa:dumbbell', categories: ["health"], tags: ['dumbbell'], source: 'fa'),
        IconMetadata(name: 'fa:heart-pulse', categories: ["health"], tags: ['heart pulse'], source: 'fa'),
        IconMetadata(name: 'fa:prescription-bottle', categories: ["health"], tags: ['prescription bottle'], source: 'fa'),
        
        // Sports
        IconMetadata(name: 'fa:soccer-ball', categories: ["sports"], tags: ['soccer ball'], source: 'fa'),
        IconMetadata(name: 'fa:basketball', categories: ["sports"], tags: ['basketball'], source: 'fa'),
        IconMetadata(name: 'fa:trophy', categories: ["sports"], tags: ['trophy'], source: 'fa'),
        IconMetadata(name: 'fa:baseball', categories: ["sports"], tags: ['baseball'], source: 'fa'),
        IconMetadata(name: 'fa:football', categories: ["sports"], tags: ['football'], source: 'fa'),
        
        // Shopping
        IconMetadata(name: 'fa:shopping-bag', categories: ["shopping"], tags: ['shopping bag'], source: 'fa'),
        IconMetadata(name: 'fa:shopping-cart', categories: ["shopping"], tags: ['shopping cart'], source: 'fa'),
        IconMetadata(name: 'fa:tag', categories: ["shopping"], tags: ['tag'], source: 'fa'),
        IconMetadata(name: 'fa:store', categories: ["shopping"], tags: ['store'], source: 'fa'),
        
        // Lifestyle
        IconMetadata(name: 'fa:house', categories: ["lifestyle"], tags: ['house'], source: 'fa'),
        IconMetadata(name: 'fa:gift', categories: ["lifestyle"], tags: ['gift'], source: 'fa'),
        IconMetadata(name: 'fa:music', categories: ["lifestyle"], tags: ['music'], source: 'fa'),
        IconMetadata(name: 'fa:film', categories: ["lifestyle"], tags: ['film'], source: 'fa'),
        IconMetadata(name: 'fa:ticket', categories: ["lifestyle"], tags: ['ticket'], source: 'fa'),
        IconMetadata(name: 'fa:shirt', categories: ["lifestyle"], tags: ['shirt'], source: 'fa'),
        IconMetadata(name: 'fa:graduation-cap', categories: ["lifestyle"], tags: ['graduation cap'], source: 'fa'),
        IconMetadata(name: 'fa:couch', categories: ["lifestyle"], tags: ['couch'], source: 'fa'),
        IconMetadata(name: 'fa:bed', categories: ["lifestyle"], tags: ['bed'], source: 'fa'),
        IconMetadata(name: 'fa:bath', categories: ["lifestyle"], tags: ['bath'], source: 'fa'),
        IconMetadata(name: 'fa:umbrella', categories: ["lifestyle"], tags: ['umbrella'], source: 'fa'),
        IconMetadata(name: 'fa:mountain', categories: ["lifestyle"], tags: ['mountain'], source: 'fa'),
        IconMetadata(name: 'fa:tree', categories: ["lifestyle"], tags: ['tree'], source: 'fa'),
        IconMetadata(name: 'fa:sun', categories: ["lifestyle"], tags: ['sun'], source: 'fa'),
        IconMetadata(name: 'fa:moon', categories: ["lifestyle"], tags: ['moon'], source: 'fa'),
      ];

      final allLoaded = [...symbols, ...mdi, ...fa];

      // 4. Enrich categories from JSON if exists
      try {
        final String response = await rootBundle.loadString('assets/metadata/icons.json');
        final data = json.decode(response);
        final List icons = data['icons'];
        final Map<String, List<String>> catMap = {};
        for (var i in icons) {
          catMap[i['name']] = List<String>.from(i['categories'] ?? []);
        }
        
        for (var i = 0; i < allLoaded.length; i++) {
          if (allLoaded[i].source == 'ms' && catMap.containsKey(allLoaded[i].name)) {
            allLoaded[i] = IconMetadata(
              name: allLoaded[i].name,
              categories: catMap[allLoaded[i].name]!,
              tags: allLoaded[i].tags,
              source: 'ms'
            );
          }
        }
      } catch (_) {}

      // Extract dynamic categories from ALL icons
      final Set<String> categories = {};
      for (var icon in allLoaded) {
        for (var cat in icon.categories) {
          if (cat.isNotEmpty && cat != 'symbols' && cat != 'mdi' && cat != 'fa') {
            categories.add(cat);
          }
        }
      }
      
      final sortedCats = categories.toList()..sort();

      if (mounted) {
        setState(() {
          _allIcons = allLoaded;
          _dynamicCategories = ['All', 'Recent', ...sortedCats.map((c) => _capitalize(c))];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading exhaustive icon set: $e');
      if (mounted) setState(() => _isLoading = false);
    }
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
              hintText: 'Search 10,000+ icons (e.g. food, car)...',
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
