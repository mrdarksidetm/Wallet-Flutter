import 'package:isar/isar.dart';
import 'category.dart';
import 'account.dart';
import 'transaction_model.dart';

part 'auxiliary_models.g.dart';

// --- Person ---
@collection
class Person {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String uuid = '';

  @Index()
  String name = '';
  String? contact;
  String? avatar;
  String color = '0xFF2196F3';
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  bool isDeleted = false;
}

// --- Place ---
@collection
class Place {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String uuid = '';

  String name = '';
  String? address;
  double? latitude;
  double? longitude;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  bool isDeleted = false;
}

// --- Budget ---
@collection
class Budget {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String uuid = '';

  double amount = 0.0;
  final category = IsarLink<Category>();

  @Enumerated(EnumType.name)
  BudgetPeriod period = BudgetPeriod.monthly;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  bool isActive = true;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  bool isDeleted = false;
}

enum BudgetPeriod {
  weekly,
  monthly,
  yearly,
  oneTime;

  String get name => toString().split('.').last;
}

// --- Loan ---
@collection
class Loan {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String uuid = '';

  final person = IsarLink<Person>();

  double amount = 0.0;

  @Enumerated(EnumType.name)
  LoanType type = LoanType.borrowed;

  DateTime? dueDate;
  bool isPaid = false;
  bool isActive = true;
  String? note;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  bool isDeleted = false;
}

enum LoanType {
  lent, // I gave money
  borrowed; // I took money

  String get name => toString().split('.').last;
}

// --- Goal ---
@collection
class Goal {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String uuid = '';

  String name = '';
  double targetAmount = 0.0;
  double currentAmount = 0.0;
  DateTime deadline = DateTime.now();
  String color = '0xFF2196F3';
  String? icon;

  final account = IsarLink<Account>();

  bool isCompleted = false;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  bool isDeleted = false;
}

// --- Recurring ---
@collection
class Recurring {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String uuid = '';

  String name = '';
  double amount = 0.0;

  @Enumerated(EnumType.name)
  TransactionType type = TransactionType.expense;

  final account = IsarLink<Account>();
  final category = IsarLink<Category>();
  final transferAccount = IsarLink<Account>();

  @Enumerated(EnumType.name)
  RecurrenceFrequency frequency = RecurrenceFrequency.monthly;

  DateTime nextDate = DateTime.now();
  DateTime? endDate;

  bool isActive = true;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  bool isDeleted = false;
}

enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly;

  String get name => toString().split('.').last;
}

// --- Label ---
@collection
class Label {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String name = '';
  String color = '0xFF2196F3';
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  bool isDeleted = false;
}
