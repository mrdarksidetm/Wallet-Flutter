import 'package:isar/isar.dart';
import '../models/auxiliary_models.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class RecurringService {
  final Isar isar;
  final TransactionService transactionService;

  RecurringService({required this.isar, required this.transactionService});

  Future<void> saveRecurring(Recurring recurring) async {
    await isar.writeTxn(() async {
      await isar.recurrings.put(recurring);
      await recurring.account.save();
      await recurring.category.save();
      if (recurring.type == TransactionType.transfer) {
        await recurring.transferAccount.save();
      }
    });
  }

  /// Checks and processes due recurring transactions
  Future<void> checkRecurringTransactions() async {
    final now = DateTime.now();
    
    // Find active recurring entries where nextDate is in the past or today
    final dueRecurring = await isar.recurrings
        .filter()
        .isActiveEqualTo(true)
        .nextDateLessThan(now)
        .findAll();

    for (var recurring in dueRecurring) {
      await _processRecurring(recurring);
    }
  }

  Future<void> _processRecurring(Recurring recurring) async {
    try {
      final account = recurring.account.value;
      final category = recurring.category.value;
      
      if (account == null || category == null) return;

      await transactionService.addTransaction(
        amount: recurring.amount,
        date: recurring.nextDate, 
        type: recurring.type,
        account: account,
        category: category,
        note: '${recurring.name} (Recurring)',
        transferAccount: recurring.transferAccount.value,
      );

      // Update next date
      await isar.writeTxn(() async {
        recurring.nextDate = _calculateNextDate(recurring.nextDate, recurring.frequency);
        recurring.updatedAt = DateTime.now();
        
        if (recurring.endDate != null && recurring.nextDate.isAfter(recurring.endDate!)) {
          recurring.isActive = false;
        }
        await isar.recurrings.put(recurring);
      });

    } catch (e) {
      // Log error or handle failure
    }
  }

  DateTime _calculateNextDate(DateTime current, RecurrenceFrequency frequency) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return current.add(const Duration(days: 1));
      case RecurrenceFrequency.weekly:
        return current.add(const Duration(days: 7));
      case RecurrenceFrequency.monthly:
        return DateTime(current.year, current.month + 1, current.day);
      case RecurrenceFrequency.yearly:
        return DateTime(current.year + 1, current.month, current.day);
    }
  }
}
