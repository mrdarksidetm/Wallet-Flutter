import 'package:isar/isar.dart';
import '../database/models/account.dart';
import '../database/models/transaction_model.dart';

/// Phase 49: Simulated "Round-Up" Savings Goals
///
/// Appends logic to automatically "round up" expenses and transfer the change
/// to a savings account.
///
/// CRITICAL: Transaction Atomicity
/// Uses Isar's `writeTxn` block so that the original expense AND the
/// round-up transfer are committed together. If either fails, the entire block rolls back.
class RoundUpService {
  final Isar isar;

  RoundUpService(this.isar);

  Future<void> insertExpenseWithRoundUp(TransactionModel expense,
      int savingsAccountId, bool isRoundUpEnabled) async {
    await isar.writeTxn(() async {
      // 1. Insert original expense
      await isar.transactionModels.put(expense);

      // 2. Calculate fractional difference if Round Up is active
      if (isRoundUpEnabled && expense.type == TransactionType.expense) {
        final ceilValue = expense.amount.ceilToDouble();
        final difference = ceilValue - expense.amount;

        if (difference > 0) {
          final roundUpTransfer = TransactionModel()
            ..amount = difference
            ..note = "Round-up from ${expense.note ?? 'expense'}"
            ..date = expense.date
            ..type = TransactionType.transfer
            ..accountId = expense.accountId // Link to the original account for context
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();

          // Properly set IsarLinks
          roundUpTransfer.account.value = expense.account.value;
          roundUpTransfer.category.value = expense.category.value;
          
          // Set the target transfer account
          final savingsAccount = await isar.accounts.get(savingsAccountId);
          if (savingsAccount != null) {
            roundUpTransfer.transferAccount.value = savingsAccount;
            
            // Atomically update savings account balance
            savingsAccount.balance += difference;
            await isar.accounts.put(savingsAccount);
          }

          await isar.transactionModels.put(roundUpTransfer);
        }
      }
    });
  }
}
