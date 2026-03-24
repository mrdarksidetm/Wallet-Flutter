import 'package:isar/isar.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';

class CategoryService {
  final Isar isar;
  final CategoryRepository categoryRepository;
  
  CategoryService({required this.isar, required this.categoryRepository});

  Future<void> addCategory({required String name, required String icon, required String color, required CategoryType type}) async {
    final cat = Category()
      ..name = name
      ..icon = icon
      ..color = color
      ..type = type;
    await categoryRepository.save(cat);
  }

  Future<void> saveCategory(Category category) async {
    await categoryRepository.save(category);
  }

  Future<void> updateCategory(Category category, Category updatedCategory) async {
    updatedCategory.id = category.id;
    await categoryRepository.save(updatedCategory);
  }

  Future<void> deleteCategory(Id id) async {
    await categoryRepository.delete(id);
  }
}
