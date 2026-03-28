import 'package:isar/isar.dart';
import '../models/auxiliary_models.dart';
import '../models/category.dart';
import '../models/transaction_model.dart';
import '../repositories/finance_repositories.dart';

class BudgetService {
  final Isar isar;
  final BudgetRepository budgetRepository;

  BudgetService({required this.isar, required this.budgetRepository});

  Future<void> addBudget({
    required double amount,
    required Category category,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await isar.writeTxn(() async {
      final budget = Budget()
        ..amount = amount
        ..period = period
        ..startDate = startDate
        ..endDate = endDate
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      budget.category.value = category;

      await isar.budgets.put(budget);
      await budget.category.save();
    });
  }

  Future<void> deleteBudget(Id id) async {
    await budgetRepository.delete(id);
  }

  // Calculate spent amount for a budget
  Future<double> getSpentAmount(Budget budget) async {
    final categoryId = budget.category.value?.id;
    if (categoryId == null) return 0.0;

    // Query transactions for the category within the budget period
    final transactions = await isar.transactionModels
        .filter()
        .categoryIdEqualTo(categoryId)
        .and()
        .typeEqualTo(TransactionType.expense)
        .and()
        .dateBetween(budget.startDate, budget.endDate)
        .and()
        .isDeletedEqualTo(false)
        .findAll();

    double spent = 0.0;
    for (final tx in transactions) {
      spent += tx.amount;
    }
    return spent;
  }

  // Helper to sync category budgets if needed
  Future<void> updateCategoryBudgetStatus(
      Category category, double limit) async {
    await isar.writeTxn(() async {
      category.isBudget = limit > 0;
      await isar.categorys.put(category);
    });
  }
}
