import 'package:isar/isar.dart';
import 'package:rxdart/rxdart.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/transaction_model.dart';
import '../repositories/account_repository.dart';
import '../repositories/transaction_repository.dart';

class StatisticsService {
  final Isar isar;
  final AccountRepository accountRepository;
  final TransactionRepository transactionRepository;

  StatisticsService({
    required this.isar,
    required this.accountRepository,
    required this.transactionRepository,
  });

  Future<double> getTotalBalance() async {
    final accounts = await isar.accounts.where().findAll();
    return accounts.fold<double>(
        0.0, (double sum, Account account) => sum + account.balance);
  }

  Stream<double> watchTotalBalance() {
    return isar.accounts.where().watch(fireImmediately: true).map((accounts) {
      return accounts.fold<double>(
          0.0, (double sum, Account account) => sum + account.balance);
    });
  }

  Stream<double> watchAssetBalance() {
    return isar.accounts
        .filter()
        .typeEqualTo(AccountType.investment)
        .or()
        .typeEqualTo(AccountType.asset)
        .watch(fireImmediately: true)
        .map((accounts) {
      return accounts.fold<double>(
          0.0, (double sum, Account account) => sum + account.balance);
    });
  }

  Future<double> getMonthlyIncome(DateTime date) async {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

    return await isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .isArchivedEqualTo(false)
        .typeEqualTo(TransactionType.income)
        .dateBetween(start, end)
        .amountProperty()
        .sum();
  }

  Future<double> getMonthlyExpense(DateTime date) async {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

    return await isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .isArchivedEqualTo(false)
        .typeEqualTo(TransactionType.expense)
        .dateBetween(start, end)
        .amountProperty()
        .sum();
  }

  Future<double> getPeriodExpense(DateTime start, DateTime end) async {
    return await isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .isArchivedEqualTo(false)
        .typeEqualTo(TransactionType.expense)
        .dateBetween(start, end)
        .amountProperty()
        .sum();
  }

  Future<Map<Category, double>> getCategoryBreakdown(
      DateTime start, DateTime end) async {
    final transactions = await isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .isArchivedEqualTo(false)
        .typeEqualTo(TransactionType.expense)
        .dateBetween(start, end)
        .findAll();

    final Map<Category, double> breakdown = {};
    for (var tx in transactions) {
      final category = tx.category.value;
      if (category != null) {
        breakdown[category] = (breakdown[category] ?? 0) + tx.amount;
      }
    }
    return breakdown;
  }

  Future<List<MapEntry<DateTime, double>>> getDailyStats(
      DateTime start, DateTime end) async {
    final transactions = await isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .isArchivedEqualTo(false)
        .typeEqualTo(TransactionType.expense)
        .dateBetween(start, end)
        .findAll();

    final Map<DateTime, double> daily = {};
    for (var tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      daily[date] = (daily[date] ?? 0) + tx.amount;
    }

    final sorted = daily.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted;
  }

  Stream<Map<String, double>> watchRecentStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = today.subtract(const Duration(days: 7));
    final thirtyDaysAgo = today.subtract(const Duration(days: 30));

    return isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .isArchivedEqualTo(false)
        .dateGreaterThan(thirtyDaysAgo)
        .watch(fireImmediately: true)
        .map((transactions) {
      double last7Days = 0;
      double last30Days = 0;

      for (var tx in transactions) {
        if (tx.type == TransactionType.expense) {
          if (tx.date.isAfter(sevenDaysAgo)) {
            last7Days += tx.amount;
          }
          last30Days += tx.amount;
        }
      }
      return {
        'last7Days': last7Days,
        'last30Days': last30Days,
      };
    });
  }

  Stream<List<Map<String, dynamic>>> watchBudgets() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    // Watch both categories and transactions to update when either changes
    return CombineLatestStream.combine2(
      isar.transactionModels.where().watch(fireImmediately: true),
      isar.categorys.where().watch(fireImmediately: true),
      (t, c) => null,
    ).asyncMap((_) async {
      final categories =
          await isar.categorys.filter().isBudgetEqualTo(true).findAll();

      final List<Map<String, dynamic>> budgetStats = [];

      for (var category in categories) {
        final spent = await isar.transactionModels
            .filter()
            .categoryIdEqualTo(category.id)
            .dateBetween(startOfMonth, endOfMonth)
            .typeEqualTo(TransactionType.expense)
            .isDeletedEqualTo(false)
            .isArchivedEqualTo(false)
            .amountProperty()
            .sum();

        final limit = category.budgetLimit ?? 0.0;
        final percent = limit > 0 ? (spent / limit) : 0.0;

        budgetStats.add({
          'category': category,
          'spent': spent,
          'limit': limit,
          'percent': percent,
        });
      }
      return budgetStats;
    });
  }

  Future<List<MapEntry<DateTime, double>>> getCategoryMonthlyStats(
      Id categoryId) async {
    final now = DateTime.now();
    final List<MapEntry<DateTime, double>> stats = [];

    for (var i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final start = DateTime(date.year, date.month, 1);
      final end = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

      final spent = await isar.transactionModels
          .filter()
          .categoryIdEqualTo(categoryId)
          .dateBetween(start, end)
          .typeEqualTo(TransactionType.expense)
          .isDeletedEqualTo(false)
          .isArchivedEqualTo(false)
          .amountProperty()
          .sum();

      stats.add(MapEntry(date, spent));
    }
    return stats;
  }

  Stream<Map<String, double>> watchMonthlyStats() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .isArchivedEqualTo(false)
        .dateBetween(start, end)
        .watch(fireImmediately: true)
        .map((transactions) {
      double income = 0;
      double expense = 0;
      for (var tx in transactions) {
        if (tx.type == TransactionType.income) income += tx.amount;
        if (tx.type == TransactionType.expense) expense += tx.amount;
      }
      return {'income': income, 'expense': expense};
    });
  }

  Future<Map<DateTime, int>> getTransactionHeatmapData() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final transactions = await isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .isArchivedEqualTo(false)
        .dateBetween(startOfMonth, endOfMonth)
        .findAll();

    final Map<DateTime, int> heatmap = {};
    for (var tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      heatmap[date] = (heatmap[date] ?? 0) + 1;
    }

    // Intensity calculation (0: none, 1: 1-2, 2: 3-5, 3: 5+)
    final Map<DateTime, int> intensityMap = {};
    heatmap.forEach((date, count) {
      if (count == 0) {
        intensityMap[date] = 0;
      } else if (count <= 2) {
        intensityMap[date] = 1;
      } else if (count <= 5) {
        intensityMap[date] = 2;
      } else {
        intensityMap[date] = 3;
      }
    });

    return intensityMap;
  }

  Future<List<MapEntry<DateTime, double>>> getMonthlyTrendData() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final transactions = await isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .isArchivedEqualTo(false)
        .dateBetween(thirtyDaysAgo, now)
        .typeEqualTo(TransactionType.expense)
        .findAll();

    final Map<DateTime, double> daily = {};
    for (var tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      daily[date] = (daily[date] ?? 0) + tx.amount;
    }

    // Fill missing days with 0
    for (var i = 0; i <= 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dayOnly = DateTime(date.year, date.month, date.day);
      daily[dayOnly] ??= 0;
    }

    final sorted = daily.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted;
  }
}
