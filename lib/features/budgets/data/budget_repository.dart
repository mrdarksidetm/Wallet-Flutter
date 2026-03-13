import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../../core/database/isar_service.dart';
import '../../../../core/database/models/auxiliary_models.dart';
import '../../../../core/database/providers.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider); // Assuming this provider exists
  return BudgetRepository(isarService);
});

class BudgetRepository {
  final IsarService _isarService;

  BudgetRepository(this._isarService);

  // 1. Get all budgets
  Future<List<Budget>> getBudgets() async {
    final isar = await _isarService.db;
    return await isar.budgets.where().filter().isDeletedEqualTo(false).findAll();
  }

  // 2. Watch all budgets for real-time updates
  Stream<List<Budget>> watchBudgets() async* {
    final isar = await _isarService.db;
    yield* isar.budgets.where().filter().isDeletedEqualTo(false).watch(fireImmediately: true);
  }

  // 3. Add a new budget
  Future<void> addBudget(Budget budget) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      // 1. Isar requires linked objects to be saved FIRST if they are new (have no ID)
      if (budget.category.value != null) {
        await isar.categorys.put(budget.category.value!);
      }
      // 2. Save the parent object
      await isar.budgets.put(budget);
      // 3. Save the link
      await budget.category.save();
    });
  }

  // 4. Update an existing budget
  Future<void> updateBudget(Budget budget) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      budget.updatedAt = DateTime.now();
      
      if (budget.category.value != null) {
        await isar.categorys.put(budget.category.value!);
      }
      
      await isar.budgets.put(budget);
      await budget.category.save();
    });
  }

  // 5. Soft Delete a budget
  Future<void> deleteBudget(int id) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      final budget = await isar.budgets.get(id);
      if (budget != null) {
        budget.isDeleted = true;
        budget.updatedAt = DateTime.now();
        await isar.budgets.put(budget);
      }
    });
  }
}
