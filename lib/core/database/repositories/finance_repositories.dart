import 'package:isar/isar.dart';
import '../../database/models/auxiliary_models.dart';
import 'base_repository.dart';

class BudgetRepository extends BaseRepository<Budget> {
  BudgetRepository(super.isar);

  Stream<List<Budget>> watchAll() {
    return isar.budgets.where().sortByEndDate().watch(fireImmediately: true);
  }
}

class PersonRepository extends BaseRepository<Person> {
  PersonRepository(super.isar);

  Stream<List<Person>> watchAll() {
    return isar.persons.where().sortByName().watch(fireImmediately: true);
  }
}

class LoanRepository extends BaseRepository<Loan> {
  LoanRepository(super.isar);

  Stream<List<Loan>> watchAll() {
    return isar.loans.where().sortByDueDate().watch(fireImmediately: true);
  }
}

class GoalRepository extends BaseRepository<Goal> {
  GoalRepository(super.isar);

  Stream<List<Goal>> watchAll() {
    return isar.goals.where().sortByDeadline().watch(fireImmediately: true);
  }
}

class RecurringRepository extends BaseRepository<Recurring> {
  RecurringRepository(super.isar);

  Stream<List<Recurring>> watchAll() {
    return isar.recurrings.where().sortByNextDate().watch(fireImmediately: true);
  }
}
