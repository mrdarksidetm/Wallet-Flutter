import 'package:isar/isar.dart';

part 'account.g.dart';

@collection
class Account {
  Id id = Isar.autoIncrement;

  late String name;
  
  late String bankName;
  
  late String number;
  
  @Index()
  late DateTime validThru;
  
  late int icon; // Original Paisa uses int for icons
  
  bool isPredefined = false;

  double balance = 0.0;

  late DateTime createdAt;

  late DateTime updatedAt;
  
  @Enumerated(EnumType.name)
  late AccountType type;
}

enum AccountType {
  cash,
  bank,
  creditCard,
  wallet,
  investment,
  other,
}
