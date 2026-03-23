import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  late String name;

  late String description;

  late int icon;

  bool isPredefined = false;

  late DateTime createdAt;
  late DateTime updatedAt;
  
  @Enumerated(EnumType.name)
  late CategoryType type;
}

enum CategoryType {
  income,
  expense,
}
