import 'package:isar/isar.dart';
import '../../database/models/auxiliary_models.dart';
import 'base_repository.dart';

class BudgetRepository extends BaseRepository<Budget> {
  BudgetRepository(super.isar);

  Stream<List<Budget>> watchAll() {
    return isar.budgets.where().sortByEndDate().watch(fireImmediately: true).asyncMap((budgets) async {
      for (final b in budgets) {
        await b.category.load();
      }
      return budgets;
    });
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
    return isar.loans.where().sortByDueDate().watch(fireImmediately: true).asyncMap((loans) async {
      for (final l in loans) {
        await l.person.load();
      }
      return loans;
    });
  }
}

class GoalRepository extends BaseRepository<Goal> {
  GoalRepository(super.isar);

  Stream<List<Goal>> watchAll() {
    return isar.goals.where().sortByDeadline().watch(fireImmediately: true).asyncMap((goals) async {
      for (final g in goals) {
        await g.account.load();
      }
      return goals;
    });
  }
}

class RecurringRepository extends BaseRepository<Recurring> {
  RecurringRepository(super.isar);

  Stream<List<Recurring>> watchAll() {
    return isar.recurrings
        .where()
        .sortByNextDate()
        .watch(fireImmediately: true)
        .asyncMap((recurrings) async {
          for (final r in recurrings) {
            await Future.wait([
              r.category.load(),
              r.account.load(),
              r.transferAccount.load(),
            ]);
          }
          return recurrings;
        });
  }
}
