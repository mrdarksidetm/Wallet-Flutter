import 'package:isar/isar.dart';
import 'account.dart';
import 'category.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id id = Isar.autoIncrement;

  late String name;

  late double amount; // Paisa calls this 'currency' but it's the amount

  bool isIncome = false; // Original Paisa calls this 'addOrSub'

  @Index()
  late DateTime time;

  @Enumerated(EnumType.name)
  late TransactionType type;

  late int accountId;

  late int categoryId;

  // Links for Isar performance
  final account = IsarLink<Account>();
  final category = IsarLink<Category>();

  late DateTime createdAt;
  late DateTime updatedAt;
}

enum TransactionType {
  income,
  expense,
  transfer,
}
