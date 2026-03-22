import 'package:isar/isar.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/auxiliary_models.dart';
import '../models/transaction_model.dart';
import '../repositories/account_repository.dart';
import '../repositories/transaction_repository.dart';

class TransactionService {
  final Isar isar;
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;

  TransactionService({
    required this.isar,
    required this.transactionRepository,
    required this.accountRepository,
  });

  /// Adds a transaction and updates the associated account balance atomically.
  Future<void> addTransaction({
    required double amount,
    required DateTime date,
    required TransactionType type,
    required Account account,
    required Category category,
    Person? person,
    String? note,
    String? icon,
    Account? transferAccount,
    List<String> tags = const [],
  }) async {
    // 1. Validation
    if (amount <= 0) throw Exception('Amount must be greater than 0');
    if (type == TransactionType.transfer && transferAccount == null) {
      throw Exception('Transfer account is required for transfers');
    }
    if (type == TransactionType.transfer && account.id == transferAccount?.id) {
      throw Exception('Cannot transfer to the same account');
    }

    await isar.writeTxn(() async {
      final transaction = TransactionModel()
        ..amount = amount
        ..date = date
        ..type = type
        ..note = note
        ..icon = icon
        ..tags = tags
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      transaction.account.value = account;
      transaction.category.value = category;
      transaction.person.value = person;

      // 2. Update Balance
      if (type == TransactionType.income) {
        account.balance += amount;
      } else if (type == TransactionType.expense) {
        account.balance -= amount;
      } else if (type == TransactionType.transfer && transferAccount != null) {
        account.balance -= amount;
        transferAccount.balance += amount;
        transaction.transferAccount.value = transferAccount;
        await isar.accounts.put(transferAccount);
      }

      // 3. Save
      await isar.accounts.put(account);
      await isar.transactionModels.put(transaction);
      // Links are saved automatically when the object is put (if they are IsarLinks)
      // or we just need to ensure the IDs are set, which .value = ... does.
      // Explicit .save() starts a new transaction, causing a crash.
    });
  }

  /// Updates a transaction and recalculates account balances.
  Future<void> updateTransaction(TransactionModel oldTransaction, TransactionModel newTransaction) async {
    await isar.writeTxn(() async {
      final account = oldTransaction.account.value;
      final category = oldTransaction.category.value;
      final transferAccount = oldTransaction.transferAccount.value;

      if (account == null || category == null) return;

      // 1. Revert Old Balance
      if (oldTransaction.type == TransactionType.income) {
        account.balance -= oldTransaction.amount;
      } else if (oldTransaction.type == TransactionType.expense) {
        account.balance += oldTransaction.amount;
      } else if (oldTransaction.type == TransactionType.transfer && transferAccount != null) {
        account.balance += oldTransaction.amount;
        transferAccount.balance -= oldTransaction.amount;
        await isar.accounts.put(transferAccount);
      }

      // 2. Apply New Balance (assuming account/type might have changed)
      final newAcc = newTransaction.account.value ?? account;
      final newAmount = newTransaction.amount;
      final newType = newTransaction.type;
      final newTransferAcc = newTransaction.transferAccount.value;

      if (newType == TransactionType.income) {
        newAcc.balance += newAmount;
      } else if (newType == TransactionType.expense) {
        newAcc.balance -= newAmount;
      } else if (newType == TransactionType.transfer && newTransferAcc != null) {
        newAcc.balance -= newAmount;
        newTransferAcc.balance += newAmount;
        await isar.accounts.put(newTransferAcc);
      }

      // 3. Save Changes
      if (account.id != newAcc.id) {
         await isar.accounts.put(account); // Save the reverted one
      }
      await isar.accounts.put(newAcc);
      
      // Update the person link and custom icon
      newTransaction.person.value = newTransaction.person.value; 
      
      newTransaction.updatedAt = DateTime.now();
      await isar.transactionModels.put(newTransaction);
    });
  }

  /// Deletes a transaction and restores account balances.
  Future<void> deleteTransaction(TransactionModel transaction) async {
    await isar.writeTxn(() async {
      final account = transaction.account.value;
      final transferAccount = transaction.transferAccount.value;

      if (account == null) return;

      // 1. Restore Balance
      if (transaction.type == TransactionType.income) {
        account.balance -= transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        account.balance += transaction.amount;
      } else if (transaction.type == TransactionType.transfer && transferAccount != null) {
        account.balance += transaction.amount;
        transferAccount.balance -= transaction.amount;
        await isar.accounts.put(transferAccount);
      }

      // 2. Save Account & Delete Transaction
      await isar.accounts.put(account);
      await isar.transactionModels.delete(transaction.id);
    });
  }

  /// Archives a transaction by setting its isArchived flag to true.
  Future<void> archiveTransaction(TransactionModel transaction) async {
    await isar.writeTxn(() async {
      transaction.isArchived = true;
      transaction.updatedAt = DateTime.now();
      await isar.transactionModels.put(transaction);
    });
  }
}
