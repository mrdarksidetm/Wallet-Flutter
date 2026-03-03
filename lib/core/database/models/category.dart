import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  late String name;

  late String icon;

  late String color;

  @Enumerated(EnumType.name)
  late CategoryType type;

  double? budgetLimit; // Nullable if no budget set specifically on category

  late DateTime createdAt;

  late DateTime updatedAt;

  bool isDeleted = false;
}

enum CategoryType {
  income,
  expense,
  transfer,
}
