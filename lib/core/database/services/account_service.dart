import 'package:isar/isar.dart';
import '../models/account.dart';
import '../repositories/account_repository.dart';

class AccountService {
  final Isar isar;
  final AccountRepository accountRepository;

  AccountService({required this.isar, required this.accountRepository});

  Future<void> addAccount({
    required String name,
    required String icon,
    required String color,
    required double balance,
    required AccountType type,
    bool isDefault = false,
  }) async {
    if (isDefault) {
      await accountRepository.clearDefaultAccount();
    }
    final acc = Account()
      ..name = name
      ..icon = icon
      ..color = color
      ..balance = balance
      ..type = type
      ..isDefault = isDefault
      ..createdAt = DateTime.now();
    await accountRepository.save(acc);
  }

  Future<void> saveAccount(Account account) async {
    if (account.isDefault) {
      await accountRepository.clearDefaultAccount();
    }
    await accountRepository.save(account);
  }

  Future<void> updateAccount(Account account, Account updatedAccount) async {
    if (updatedAccount.isDefault) {
      await accountRepository.clearDefaultAccount();
    }
    updatedAccount.id = account.id;
    await accountRepository.save(updatedAccount);
  }

  Future<void> deleteAccount(Id id) async {
    await accountRepository.softDelete(id);
  }

  Future<void> setDefaultAccount(Id id) async {
    await accountRepository.setDefault(id);
  }

  Future<void> updateAccountsOrder(List<Account> accounts) async {
    for (int i = 0; i < accounts.length; i++) {
      accounts[i].order = i;
    }
    await isar.writeTxn(() async {
      await isar.accounts.putAll(accounts);
    });
  }
}
