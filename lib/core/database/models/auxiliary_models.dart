import 'package:isar/isar.dart';
import 'category.dart';
import 'account.dart';
import 'transaction_model.dart';

part 'auxiliary_models.g.dart';

// --- Person ---
@collection
class Person {
  Id id = Isar.autoIncrement;
  @Index()
  late String name;
  String? contact;
  String? avatar;
  late String color;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDeleted = false;
}

// --- Place ---
@collection
class Place {
  Id id = Isar.autoIncrement;
  late String name;
  String? address;
  double? latitude;
  double? longitude;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDeleted = false;
}

// --- Budget ---
@collection
class Budget {
  Id id = Isar.autoIncrement;
  double amount = 0.0;
  final category = IsarLink<Category>();
  
  @Enumerated(EnumType.name)
  late BudgetPeriod period;
  
  late DateTime startDate;
  late DateTime endDate;
  
  bool isActive = true;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDeleted = false;
}

enum BudgetPeriod {
  weekly,
  monthly,
  yearly,
  oneTime,
}

// --- Loan ---
@collection
class Loan {
  Id id = Isar.autoIncrement;
  
  final person = IsarLink<Person>();
  
  double amount = 0.0;
  
  @Enumerated(EnumType.name)
  late LoanType type;
  
  DateTime? dueDate;
  bool isPaid = false;
  bool isActive = true;
  String? note;
  
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDeleted = false;
}

enum LoanType {
  lent, // I gave money
  borrowed, // I took money
}

// --- Goal ---
@collection
class Goal {
  Id id = Isar.autoIncrement;
  late String name;
  double targetAmount = 0.0;
  double currentAmount = 0.0;
  late DateTime deadline;
  late String color;
  String? icon;
  
  bool isCompleted = false;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDeleted = false;
}

// --- Recurring ---
@collection
class Recurring {
  Id id = Isar.autoIncrement;
  
  late String name;
  late double amount;
  
  @Enumerated(EnumType.name)
  late TransactionType type;
  
  final account = IsarLink<Account>();
  final category = IsarLink<Category>();
  final transferAccount = IsarLink<Account>();
  
  @Enumerated(EnumType.name)
  late RecurrenceFrequency frequency;
  
  late DateTime nextDate;
  DateTime? endDate;
  
  bool isActive = true;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDeleted = false;
}

enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly,
}

// --- Label ---
@collection
class Label {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String name;
  late String color;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDeleted = false;
}
