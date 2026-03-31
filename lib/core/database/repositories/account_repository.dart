import 'package:isar/isar.dart';
import '../../database/models/account.dart';
import 'base_repository.dart';

class AccountRepository extends BaseRepository<Account> {
  AccountRepository(super.isar);

  Stream<List<Account>> watchAll() {
    return isar.accounts.where().sortByOrder().watch(fireImmediately: true);
  }

  // Custom queries can go here (e.g., Get by Type)
}
