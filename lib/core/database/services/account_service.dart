import 'package:isar/isar.dart';
import '../models/account.dart';
import '../repositories/account_repository.dart';

class AccountService {
  final Isar isar;
  final AccountRepository accountRepository;
  
  AccountService({required this.isar, required this.accountRepository});

  Future<void> addAccount({required String name, required String icon, required String color, required double balance, required AccountType type}) async {
    final acc = Account()
      ..name = name
      ..icon = icon
      ..color = color
      ..balance = balance
      ..type = type
      ..createdAt = DateTime.now();
    await accountRepository.save(acc);
  }

  Future<void> saveAccount(Account account) async {
    await accountRepository.save(account);
  }

  Future<void> updateAccount(Account account, Account updatedAccount) async {
    updatedAccount.id = account.id;
    await accountRepository.save(updatedAccount);
  }

  Future<void> deleteAccount(Id id) async {
    await accountRepository.delete(id);
  }
}
