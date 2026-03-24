import 'package:isar/isar.dart';
import 'account.dart';
import 'category.dart';
import 'auxiliary_models.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id id = Isar.autoIncrement;

  late double amount;

  String? note; // Changed from 'name' to 'note' to match UI

  @Index()
  late DateTime date; // Changed from 'time' to 'date' to match UI

  @Index()
  @Enumerated(EnumType.name)
  late TransactionType type;

  @Index()
  late int accountId;

  @Index()
  late int categoryId;

  String? icon;
  List<String>? tags;
  bool isArchived = false;
  bool isDeleted = false;
  bool isTemplate = false; // Added to mark template transactions for recurring use

  final account = IsarLink<Account>();
  final category = IsarLink<Category>();
  final transferAccount = IsarLink<Account>();
  final person = IsarLink<Person>();

  late DateTime createdAt;
  late DateTime updatedAt;
}

enum TransactionType {
  income,
  expense,
  transfer,
}
