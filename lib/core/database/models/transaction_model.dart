import 'package:isar/isar.dart';
import 'account.dart';
import 'category.dart';
import 'auxiliary_models.dart';

part 'transaction_model.g.dart'; // Naming as transaction_model to avoid conflict with generic names

@collection
class TransactionModel {
  Id id = Isar.autoIncrement;

  double amount = 0.0;

  @Index()
  late DateTime date;

  String? note;

  @Enumerated(EnumType.name)
  late TransactionType type;

  // Relations using IsarLink
  final account = IsarLink<Account>();
  
  final category = IsarLink<Category>();
  
  final person = IsarLink<Person>();
  
  // For transfers only
  final transferAccount = IsarLink<Account>();

  List<String> tags = [];
  
  String? icon; // Allows a specific transaction to override a category icon

  // For recurring instances
  bool isRecurringInstance = false;
  int? originalRecurringId;

  // Phase 35: Privacy Geofencing (Foreground only location tagging)
  double? latitude;
  double? longitude;

  late DateTime createdAt;

  late DateTime updatedAt;

  bool isDeleted = false;
}

enum TransactionType {
  income,
  expense,
  transfer,
}
