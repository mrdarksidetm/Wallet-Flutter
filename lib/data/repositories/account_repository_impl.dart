import 'package:isar/isar.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../models/account_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  final Isar isar;

  AccountRepositoryImpl(this.isar);

  @override
  Future<void> addAccount(AccountEntity entity) async {
    final model = _toModel(entity);
    await isar.writeTxn(() async {
      await isar.accountModels.put(model);
    });
  }

  @override
  Future<void> deleteAccount(String uuid) async {
    await isar.writeTxn(() async {
      await isar.accountModels.filter().uuidEqualTo(uuid).deleteAll();
    });
  }

  @override
  Future<List<AccountEntity>> getAccounts() async {
    final models = await isar.accountModels.where().findAll();
    return models.map(_toEntity).toList();
  }

  @override
  Future<void> updateAccount(AccountEntity entity) async {
    final existing = await isar.accountModels.filter().uuidEqualTo(entity.uuid).findFirst();
    if (existing != null) {
      final model = _toModel(entity)..id = existing.id;
      await isar.writeTxn(() async {
        await isar.accountModels.put(model);
      });
    }
  }

  @override
  Stream<List<AccountEntity>> watchAccounts() {
    return isar.accountModels.where().watch(fireImmediately: true).map(
          (models) => models.map(_toEntity).toList(),
        );
  }

  AccountEntity _toEntity(AccountModel model) => AccountEntity(
        uuid: model.uuid,
        name: model.name,
        bankName: model.bankName,
        icon: model.icon,
        initialBalance: model.initialBalance,
        currentBalance: model.currentBalance,
        currencyCode: model.currencyCode,
        createdAt: model.createdAt,
        isDefault: model.isDefault,
        type: model.type,
      );

  AccountModel _toModel(AccountEntity entity) => AccountModel()
    ..uuid = entity.uuid
    ..name = entity.name
    ..bankName = entity.bankName
    ..icon = entity.icon
    ..initialBalance = entity.initialBalance
    ..currentBalance = entity.currentBalance
    ..currencyCode = entity.currencyCode
    ..createdAt = entity.createdAt
    ..isDefault = entity.isDefault
    ..type = entity.type;
}
