import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;

  late String description;

  late String icon; // Changed from int to String

  late String color; // Added missing color

  double? budgetLimit; // Added missing budgetLimit

  bool isBudget = false; // Added to enable/disable budget for category

  bool isPredefined = false;

  bool isDeleted = false;

  late DateTime createdAt;
  late DateTime updatedAt;
  
  @Index()
  @Enumerated(EnumType.name)
  late CategoryType type;
}

enum CategoryType {
  income,
  expense,
  transfer, // Added missing transfer type
}
