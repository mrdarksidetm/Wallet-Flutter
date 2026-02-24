import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'isar_service.dart';
import 'repositories/account_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/transaction_repository.dart';
import 'repositories/finance_repositories.dart';
import 'services/transaction_service.dart';
import 'services/seed_service.dart';
import 'services/statistics_service.dart';
import 'services/budget_service.dart';
import 'services/loan_service.dart';
import 'services/goal_service.dart';
import 'services/csv_service.dart';
import 'services/person_service.dart';
import 'services/account_service.dart';
import 'services/category_service.dart';
import 'services/recurring_service.dart';
import '../services/exchange_rate_service.dart';
import 'models/account.dart';
import 'models/category.dart';
import 'models/transaction_model.dart';
import 'models/auxiliary_models.dart';

// --- Database Provider ---
final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

final isarProvider = FutureProvider<Isar>((ref) async {
  final service = ref.watch(isarServiceProvider);
  return await service.db;
});

// --- Repository Providers ---
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final isar = ref.watch(isarProvider).value!;
  return AccountRepository(isar);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final isar = ref.watch(isarProvider).value!;
  return CategoryRepository(isar);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final isar = ref.watch(isarProvider).value!;
  return TransactionRepository(isar);
});

// --- Service Providers ---
final transactionServiceProvider = Provider<TransactionService>((ref) {
  final isar = ref.watch(isarProvider).value!;
  final trxRepo = ref.watch(transactionRepositoryProvider);
  final accRepo = ref.watch(accountRepositoryProvider);
  return TransactionService(
    isar: isar,
    transactionRepository: trxRepo,
    accountRepository: accRepo,
  );
});

final seedServiceProvider = Provider<SeedService>((ref) {
  final isar = ref.watch(isarProvider).value!;
  return SeedService(isar);
});

// --- Finance Repositories ---
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final isar = ref.watch(isarProvider).value!;
  return BudgetRepository(isar);
});

final personRepositoryProvider = Provider<PersonRepository>((ref) {
  final isar = ref.watch(isarProvider).value!;
  return PersonRepository(isar);
});

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  final isar = ref.watch(isarProvider).value!;
  return LoanRepository(isar);
});

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final isar = ref.watch(isarProvider).value!;
  return GoalRepository(isar);
});

// --- Statistics Service ---
final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  final isar = ref.watch(isarProvider).value!;
  final accRepo = ref.watch(accountRepositoryProvider);
  final trxRepo = ref.watch(transactionRepositoryProvider);
  return StatisticsService(
    isar: isar,
    accountRepository: accRepo,
    transactionRepository: trxRepo,
  );
});

final budgetServiceProvider = Provider<BudgetService>((ref) {
  final isar = ref.watch(isarProvider).value!;
  final repo = ref.watch(budgetRepositoryProvider);
  return BudgetService(isar: isar, budgetRepository: repo);
});

final accountServiceProvider = Provider<AccountService>((ref) {
  final isar = ref.watch(isarProvider).value!;
  final repo = ref.watch(accountRepositoryProvider);
  return AccountService(isar: isar, accountRepository: repo);
});

final categoryServiceProvider = Provider<CategoryService>((ref) {
  final isar = ref.watch(isarProvider).value!;
  final repo = ref.watch(categoryRepositoryProvider);
  return CategoryService(isar: isar, categoryRepository: repo);
});

final personServiceProvider = Provider<PersonService>((ref) {
  final isar = ref.watch(isarProvider).value!;
  final repo = ref.watch(personRepositoryProvider);
  return PersonService(isar: isar, personRepository: repo);
});

final loanServiceProvider = Provider<LoanService>((ref) {
  final isar = ref.watch(isarProvider).value!;
  final repo = ref.watch(loanRepositoryProvider);
  return LoanService(isar: isar, loanRepository: repo);
});

final goalServiceProvider = Provider<GoalService>((ref) {
  final isar = ref.watch(isarProvider).value!;
  final repo = ref.watch(goalRepositoryProvider);
  return GoalService(isar: isar, goalRepository: repo);
});
final recurringServiceProvider = Provider<RecurringService>((ref) {
  final isar = ref.watch(isarProvider).value!;
  final trxService = ref.watch(transactionServiceProvider);
  return RecurringService(isar: isar, transactionService: trxService);
});

final csvServiceProvider = Provider<CsvService>((ref) {
  final isar = ref.watch(isarProvider).value!;
  return CsvService(isar);
});

// Re-export the exchange rate service provider for convenience
final appExchangeRateProvider = Provider<ExchangeRateService>((ref) {
  return ref.watch(exchangeRateServiceProvider);
});

// --- Stream Providers ---
final accountsStreamProvider = StreamProvider<List<Account>>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  return repo.watchAll();
});

final totalBalanceProvider = StreamProvider<double>((ref) {
  final service = ref.watch(statisticsServiceProvider);
  return service.watchTotalBalance();
});

final monthlyStatsProvider = StreamProvider<Map<String, double>>((ref) {
  final service = ref.watch(statisticsServiceProvider);
  return service.watchMonthlyStats();
});

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchAll();
});

final transactionsStreamProvider = StreamProvider<List<TransactionModel>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchLatest();
});

final budgetsStreamProvider = StreamProvider<List<Budget>>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.watchAll();
});

final loansStreamProvider = StreamProvider<List<Loan>>((ref) {
  final repo = ref.watch(loanRepositoryProvider);
  return repo.watchAll();
});

final goalsStreamProvider = StreamProvider<List<Goal>>((ref) {
  final repo = ref.watch(goalRepositoryProvider);
  return repo.watchAll();
});

final personsStreamProvider = StreamProvider<List<Person>>((ref) {
  final repo = ref.watch(personRepositoryProvider);
  return repo.watchAll();
});
