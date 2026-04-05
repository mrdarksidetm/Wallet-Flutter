import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'services/backup_service.dart';
import 'services/performance_audit_service.dart';
import '../services/exchange_rate_service.dart';
import 'models/account.dart';
import 'models/category.dart';
import 'models/transaction_model.dart';
import 'models/auxiliary_models.dart';
import '../theme/personalization_provider.dart';

// --- Storage Providers ---
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'sharedPreferencesProvider must be overridden in main.dart');
});

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

final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  final isar = ref.watch(isarProvider).value!;
  return RecurringRepository(isar);
});

// --- Service Providers ---
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

final backupServiceProvider = Provider<BackupService>((ref) {
  final isar = ref.watch(isarProvider).value!;
  return BackupService(isar);
});

final performanceAuditServiceProvider =
    Provider<PerformanceAuditService>((ref) {
  final isar = ref.watch(isarProvider).value!;
  return PerformanceAuditService(isar);
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

final totalAssetBalanceProvider = StreamProvider<double>((ref) {
  final service = ref.watch(statisticsServiceProvider);
  return service.watchAssetBalance();
});

// --- Settings Providers ---
final currencyProvider = Provider<String>((ref) {
  final personalization = ref.watch(personalizationProvider);
  final currency = personalization.defaultCurrency;
  if (currency == null) {
    // Return a default currency symbol to avoid app crash
    return 'USD';
  }
  return currency;
});

// --- Search Providers ---
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchTransactionsProvider =
    FutureProvider<List<TransactionModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final repo = ref.watch(transactionRepositoryProvider);
  return await repo.searchTransactions(query);
});

final budgetStatsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  // Listen to transaction and category changes to force rebuild of the budget stream
  ref.watch(transactionsStreamProvider);
  ref.watch(categoriesStreamProvider);
  final service = ref.watch(statisticsServiceProvider);
  return service.watchBudgets();
});

final monthlyStatsProvider = StreamProvider<Map<String, double>>((ref) {
  final service = ref.watch(statisticsServiceProvider);
  return service.watchMonthlyStats();
});

final recentStatsProvider = StreamProvider<Map<String, double>>((ref) {
  final service = ref.watch(statisticsServiceProvider);
  return service.watchRecentStats();
});

final categoryBreakdownProvider =
    FutureProvider.family<Map<Category, double>, (DateTimeRange?, int?, List<String>?)>(
        (ref, params) async {
  final range = params.$1;
  final accountId = params.$2;
  final tags = params.$3;
  if (range == null) return {};
  // Watch transactions to force rebuild when data changes
  ref.watch(transactionsStreamProvider);
  final service = ref.watch(statisticsServiceProvider);
  return await service.getCategoryBreakdown(range.start, range.end, accountId: accountId, tags: tags);
});

final dailyStatsProvider =
    FutureProvider.family<List<MapEntry<DateTime, double>>, DateTimeRange?>(
        (ref, range) async {
  if (range == null) return [];
  // Watch transactions to force rebuild when data changes
  ref.watch(transactionsStreamProvider);
  final service = ref.watch(statisticsServiceProvider);
  return await service.getDailyStats(range.start, range.end);
});

final quickInsightsProvider =
    FutureProvider.family<Map<String, dynamic>, DateTimeRange?>(
        (ref, range) async {
  if (range == null) return {};
  // Watch transactions to force rebuild when data changes
  ref.watch(transactionsStreamProvider);
  final service = ref.watch(statisticsServiceProvider);
  return await service.getQuickInsights(range.start, range.end);
});

final categoryMonthlyStatsProvider =
    FutureProvider.family<List<MapEntry<DateTime, double>>, int>(
        (ref, categoryId) async {
  final service = ref.watch(statisticsServiceProvider);
  return await service.getCategoryMonthlyStats(categoryId, DateTime.now());
});

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchAll();
});

final transactionsStreamProvider =
    StreamProvider<List<TransactionModel>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchLatest();
});

final archivedTransactionsStreamProvider =
    StreamProvider<List<TransactionModel>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchArchived();
});

final accountTransactionsProvider =
    StreamProvider.family<List<TransactionModel>, Id>((ref, accountId) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchByAccount(accountId);
});

final personTransactionsProvider =
    StreamProvider.family<List<TransactionModel>, Id>((ref, personId) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchByPerson(personId);
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

final recurringsStreamProvider = StreamProvider<List<Recurring>>((ref) {
  final repo = ref.watch(recurringRepositoryProvider);
  return repo.watchAll();
});
