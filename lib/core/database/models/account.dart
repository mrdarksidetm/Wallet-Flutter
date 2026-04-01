import 'package:isar/isar.dart';

part 'account.g.dart';

@collection
class Account {
  Id id = Isar.autoIncrement;

  @Index()
  String name = '';

  String bankName = '';

  String number = '';

  @Index()
  DateTime validThru = DateTime.now();

  String icon = 'account_balance_wallet';

  String color = '0xFF2196F3';

  bool isPredefined = false;

  double balance = 0.0;

  bool isArchived = false;

  bool isDeleted = false;

  bool isDefault = false;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();

  int order = 0;

  @Index()
  @Enumerated(EnumType.name)
  AccountType type = AccountType.cash;
}

enum AccountType {
  cash,
  card,
  savings;

  String get name => toString().split('.').last;
}
