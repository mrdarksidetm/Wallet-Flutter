import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'account.g.dart';

@collection
class Account {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String uuid = const Uuid().v4();

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
