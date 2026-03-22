import 'package:isar/isar.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late double amount;
  
  late String note;
  
  @Index()
  late DateTime date;

  @enumerated
  late TransactionType type;

  // Relationships (Ported logic: Original used IDs, we use Isar Links)
  @Index()
  late String accountUuid;
  
  @Index()
  late String categoryUuid;

  // Metadata for Sync / Logic
  late bool isRecurring;
  String? recurringId;

  late DateTime createdAt;
  late DateTime updatedAt;
}

enum TransactionType {
  expense,
  income,
  transfer,
}
