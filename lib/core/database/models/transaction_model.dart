import 'package:isar/isar.dart';
import 'account.dart';
import 'category.dart';
import 'auxiliary_models.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String uuid = '';

  double amount = 0.0;

  String? note; // Changed from 'name' to 'note' to match UI

  @Index()
  DateTime date = DateTime.now(); // Changed from 'time' to 'date' to match UI

  @Index()
  @Enumerated(EnumType.name)
  TransactionType type = TransactionType.expense;

  @Index()
  int accountId = 0;

  @Index()
  int categoryId = 0;

  @Index()
  int personId = 0;

  String? icon;
  String? color;
  List<String>? tags;
  bool isArchived = false;
  bool isDeleted = false;
  bool isTemplate =
      false; // Added to mark template transactions for recurring use

  final account = IsarLink<Account>();
  final category = IsarLink<Category>();
  final transferAccount = IsarLink<Account>();
  final person = IsarLink<Person>();

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}

enum TransactionType {
  income,
  expense,
  transfer;

  String get name => toString().split('.').last;
}
