import 'package:isar/isar.dart';

part 'debt_model.g.dart';

@collection
class DebtModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String personName;
  
  late double amount;
  
  late String note;
  
  @Index()
  late DateTime date;

  @Index()
  late DateTime? dueDate;

  @enumerated
  late DebtType type;

  late bool isSettled;

  late DateTime createdAt;
}

enum DebtType {
  lent,
  borrowed,
}
