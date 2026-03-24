import 'package:isar/isar.dart';

part 'account.g.dart';

@collection
class Account {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;
  
  late String bankName;
  
  late String number;
  
  @Index()
  late DateTime validThru;
  
  late String icon; // Changed from int to String
  
  late String color; // Added missing color

  bool isPredefined = false;

  double balance = 0.0;

  bool isArchived = false;

  bool isDeleted = false;

  late DateTime createdAt;

  late DateTime updatedAt;
  
  @Index()
  @Enumerated(EnumType.name)
  late AccountType type;
}

enum AccountType {
  cash,
  bank,
  creditCard,
  wallet,
  investment,
  asset,
  other,
}
