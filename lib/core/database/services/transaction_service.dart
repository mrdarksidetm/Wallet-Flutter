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
    String? color,
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
        ..icon = icon ?? category.icon // Inherit category icon if null
        ..color = color ?? category.color // Inherit category color if null
        ..tags = tags
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      transaction.account.value = account;
      transaction.category.value = category;
      transaction.person.value = person;

      // Sync IDs for faster querying without loading links
      transaction.accountId = account.id;
      transaction.categoryId = category.id;
      transaction.personId = person?.id ?? 0;

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

      // [ACTION]: Sync with Goals if account is a Savings account
      if (account.type == AccountType.savings) {
        final linkedGoals = await isar.goals.filter().account((q) => q.idEqualTo(account.id)).findAll();
        for (var goal in linkedGoals) {
          if (type == TransactionType.income) {
            goal.currentAmount += amount;
          } else if (type == TransactionType.expense) {
            goal.currentAmount -= amount;
          }
          goal.isCompleted = goal.currentAmount >= goal.targetAmount;
          goal.updatedAt = DateTime.now();
          await isar.goals.put(goal);
        }
      }

      // 3. Save
      await isar.accounts.put(account);
      await isar.transactionModels.put(transaction);
    });
  }

  /// Updates a transaction and recalculates account balances.
  Future<void> updateTransaction(
      TransactionModel oldTransaction, TransactionModel newTransaction) async {
    await isar.writeTxn(() async {
      // 1. Fetch a fresh copy of the old transaction to ensure links can be loaded
      final txToRevert = await isar.transactionModels.get(oldTransaction.id);
      if (txToRevert == null) return;

      await txToRevert.account.load();
      await txToRevert.transferAccount.load();

      final oldAcc = txToRevert.account.value;
      final oldTransferAcc = txToRevert.transferAccount.value;

      // 2. Revert Old Balance
      if (oldAcc != null) {
        if (txToRevert.type == TransactionType.income) {
          oldAcc.balance -= txToRevert.amount;
        } else if (txToRevert.type == TransactionType.expense) {
          oldAcc.balance += txToRevert.amount;
        } else if (txToRevert.type == TransactionType.transfer && oldTransferAcc != null) {
          oldAcc.balance += txToRevert.amount;
          oldTransferAcc.balance -= txToRevert.amount;
          await isar.accounts.put(oldTransferAcc);
        }

        // [ACTION]: Revert Goal progress
        if (oldAcc.type == AccountType.savings) {
          final linkedGoals = await isar.goals.filter().account((q) => q.idEqualTo(oldAcc.id)).findAll();
          for (var goal in linkedGoals) {
            if (txToRevert.type == TransactionType.income) {
              goal.currentAmount -= txToRevert.amount;
            } else if (txToRevert.type == TransactionType.expense) {
              goal.currentAmount += txToRevert.amount;
            }
            goal.isCompleted = goal.currentAmount >= goal.targetAmount;
            await isar.goals.put(goal);
          }
        }
        await isar.accounts.put(oldAcc);
      }

      // 3. Apply New Balance
      final newAcc = newTransaction.account.value;
      final newTransferAcc = newTransaction.transferAccount.value;

      if (newAcc != null) {
        if (newTransaction.type == TransactionType.income) {
          newAcc.balance += newTransaction.amount;
        } else if (newTransaction.type == TransactionType.expense) {
          newAcc.balance -= newTransaction.amount;
        } else if (newTransaction.type == TransactionType.transfer && newTransferAcc != null) {
          newAcc.balance -= newTransaction.amount;
          newTransferAcc.balance += newTransaction.amount;
          await isar.accounts.put(newTransferAcc);
        }

        // [ACTION]: Apply New Goal progress
        if (newAcc.type == AccountType.savings) {
          final linkedGoals = await isar.goals.filter().account((q) => q.idEqualTo(newAcc.id)).findAll();
          for (var goal in linkedGoals) {
            if (newTransaction.type == TransactionType.income) {
              goal.currentAmount += newTransaction.amount;
            } else if (newTransaction.type == TransactionType.expense) {
              goal.currentAmount -= newTransaction.amount;
            }
            goal.isCompleted = goal.currentAmount >= goal.targetAmount;
            await isar.goals.put(goal);
          }
        }
        await isar.accounts.put(newAcc);
      }

      // 4. Inherit category icon/color if null
      final newCategory = newTransaction.category.value;
      if (newCategory != null) {
        newTransaction.icon ??= newCategory.icon;
        newTransaction.color ??= newCategory.color;
      }

      // Sync IDs
      newTransaction.accountId = newAcc?.id ?? oldTransaction.accountId;
      newTransaction.categoryId =
          newTransaction.category.value?.id ?? oldTransaction.categoryId;
      newTransaction.personId = newTransaction.person.value?.id ?? 0;

      newTransaction.updatedAt = DateTime.now();
      await isar.transactionModels.put(newTransaction);
    });
  }

  /// Deletes a transaction and restores account balances (HARD DELETE).
  Future<void> deleteTransaction(TransactionModel transaction) async {
    await isar.writeTxn(() async {
      // 1. Fetch a fresh, attached copy inside the transaction
      final tx = await isar.transactionModels.get(transaction.id);
      if (tx == null) return;

      // 2. Load links on the attached copy
      await tx.account.load();
      await tx.transferAccount.load();

      final account = tx.account.value;
      final transferAccount = tx.transferAccount.value;

      // 3. Revert balance if account exists
      if (account != null) {
        if (tx.type == TransactionType.income) {
          account.balance -= tx.amount;
        } else if (tx.type == TransactionType.expense) {
          account.balance += tx.amount;
        } else if (tx.type == TransactionType.transfer && transferAccount != null) {
          account.balance += tx.amount;
          transferAccount.balance -= tx.amount;
          await isar.accounts.put(transferAccount);
        }

        // [ACTION]: Revert Goal progress
        if (account.type == AccountType.savings) {
          final linkedGoals = await isar.goals.filter().account((q) => q.idEqualTo(account.id)).findAll();
          for (var goal in linkedGoals) {
            if (tx.type == TransactionType.income) {
              goal.currentAmount -= tx.amount;
            } else if (tx.type == TransactionType.expense) {
              goal.currentAmount += tx.amount;
            }
            goal.isCompleted = goal.currentAmount >= goal.targetAmount;
            await isar.goals.put(goal);
          }
        }
        await isar.accounts.put(account);
      }

      // 4. ALWAYS Hard Delete the transaction to ensure it's gone
      await isar.transactionModels.delete(tx.id);
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
