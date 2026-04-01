import 'package:isar/isar.dart';
import '../../database/models/account.dart';
import 'base_repository.dart';

class AccountRepository extends BaseRepository<Account> {
  AccountRepository(super.isar);

  Stream<List<Account>> watchAll() {
    return isar.accounts
        .filter()
        .isDeletedEqualTo(false)
        .sortByOrder()
        .watch(fireImmediately: true);
  }

  Future<void> softDelete(Id id) async {
    final account = await isar.accounts.get(id);
    if (account != null) {
      account.isDeleted = true;
      account.updatedAt = DateTime.now();
      await isar.writeTxn(() => isar.accounts.put(account));
    }
  }

  Future<Account?> getDefaultAccount() async {
    final accounts = await isar.accounts.where().findAll();
    try {
      return accounts.firstWhere((a) => a.isDefault && !a.isDeleted);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearDefaultAccount() async {
    await isar.writeTxn(() async {
      final accounts = await isar.accounts.where().findAll();
      final defaults = accounts.where((a) => a.isDefault).toList();
      for (var acc in defaults) {
        acc.isDefault = false;
        acc.updatedAt = DateTime.now();
      }
      await isar.accounts.putAll(defaults);
    });
  }

  Future<void> setDefault(Id id) async {
    await clearDefaultAccount();
    final account = await isar.accounts.get(id);
    if (account != null) {
      account.isDefault = true;
      account.updatedAt = DateTime.now();
      await isar.writeTxn(() => isar.accounts.put(account));
    }
  }
}
