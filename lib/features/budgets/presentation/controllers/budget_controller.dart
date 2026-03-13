import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/models/auxiliary_models.dart';
import '../../data/budget_repository.dart';

final budgetControllerProvider = StateNotifierProvider<BudgetController, AsyncValue<List<Budget>>>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return BudgetController(repository);
});

class BudgetController extends StateNotifier<AsyncValue<List<Budget>>> {
  final BudgetRepository _repository;

  BudgetController(this._repository) : super(const AsyncValue.loading()) {
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    try {
      final budgets = await _repository.getBudgets();
      state = AsyncValue.data(budgets);
    } catch (e, stack) {
       state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addBudget(Budget budget) async {
    try {
      await _repository.addBudget(budget);
      await _loadBudgets(); // Refresh list after adding
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
       await _repository.updateBudget(budget);
       await _loadBudgets();
    } catch (e, stack) {
       state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
       await _repository.deleteBudget(id);
       await _loadBudgets();
    } catch (e, stack) {
       state = AsyncValue.error(e, stack);
    }
  }

   Future<void> toggleActiveStatus(Budget budget, bool isActive) async {
    try {
       final updatedBudget = budget..isActive = isActive;
       await _repository.updateBudget(updatedBudget);
       await _loadBudgets();
    } catch (e, stack) {
       state = AsyncValue.error(e, stack);
    }
  }
}
