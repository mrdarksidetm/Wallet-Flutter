import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String uuid = const Uuid().v4();

  @Index()
  String name = '';

  String description = '';

  String icon = 'category';

  String color = '0xFF2196F3';

  double? budgetLimit;

  bool isBudget = false;

  bool isPredefined = false;

  bool isDeleted = false;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  @Index()
  @Enumerated(EnumType.name)
  CategoryType type = CategoryType.expense;
}

enum CategoryType {
  income,
  expense,
  transfer; // Added missing transfer type

  String get name => toString().split('.').last;
}
