import 'package:isar/isar.dart';
import '../models/auxiliary_models.dart';
import '../repositories/finance_repositories.dart';

class LoanService {
  final Isar isar;
  final LoanRepository loanRepository;

  LoanService({required this.isar, required this.loanRepository});

  Future<void> saveLoan(Loan loan, {String? personName}) async {
    await isar.writeTxn(() async {
      if (personName != null) {
        var person =
            await isar.persons.filter().nameEqualTo(personName).findFirst();
        if (person == null) {
          person = Person()
            ..name = personName
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();
          await isar.persons.put(person);
        }
        loan.person.value = person;
      }
      await isar.loans.put(loan);
      await loan.person.save();
    });
  }

  Future<void> addLoan({
    required Person person,
    required double amount,
    required LoanType type,
    DateTime? dueDate,
    String? note,
  }) async {
    await isar.writeTxn(() async {
      final loan = Loan()
        ..amount = amount
        ..type = type
        ..dueDate = dueDate
        ..note = note
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      loan.person.value = person;

      await isar.loans.put(loan);
      await loan.person.save();
    });
  }

  Future<void> markAsPaid(Loan loan, bool isPaid) async {
    await isar.writeTxn(() async {
      loan.isPaid = isPaid;
      loan.updatedAt = DateTime.now();
      await isar.loans.put(loan);
    });
  }

  Future<void> deleteLoan(Id id) async {
    await loanRepository.delete(id);
  }
}
