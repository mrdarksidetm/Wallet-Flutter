import 'package:wallet/core/theme/color_extension.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/providers.dart';
import '../../../shared/widgets/paisa_list_tile.dart';
import 'add_edit_category_screen.dart';

// Helper to reliably convert the IconData string representation back into an IconData object
IconData getIconDataFromString(String iconString) {
  // Simple heuristic for our custom generic storage format:
  // Usually looks like "IconData(U+0E14B)" or just "U+0E14B"
  try {
    if (iconString.startsWith('U+')) {
      final codePoint = int.parse(iconString.substring(2), radix: 16);
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    }
    // Fallback if we accidentally saved the name 'category' early on
    return Icons.category;
  } catch (e) {
    return Icons.category;
  }
}

String getStringFromIconData(IconData icon) {
  return 'U+${icon.codePoint.toRadixString(16).toUpperCase()}';
}

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) return const Center(child: Text('No categories found.'));
          
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final color = (cat.color).parseHexColor();
              
              return PaisaListTile(
                title: cat.name,
                subtitle: cat.type.name.toUpperCase(),
                icon: getIconDataFromString(cat.icon),
                iconColor: Colors.white,
                iconBackgroundColor: color,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => ref.read(categoryServiceProvider).deleteCategory(cat.id),
                ),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditCategoryScreen(category: cat))),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditCategoryScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
