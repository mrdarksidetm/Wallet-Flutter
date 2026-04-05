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
    final accounts = await isar.accounts.filter().isDeletedEqualTo(false).findAll();
    return accounts.fold<double>(
        0.0, (double sum, Account account) => sum + account.balance);
  }

  Stream<double> watchTotalBalance() {
    return isar.accounts
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map((accounts) {
      return accounts.fold<double>(
          0.0, (double sum, Account account) => sum + account.balance);
    });
  }

  Stream<double> watchAssetBalance() {
    return isar.accounts
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .group((q) => q
            .typeEqualTo(AccountType.savings)
            .or()
            .typeEqualTo(AccountType.card))
        .watch(fireImmediately: true)
        .map((accounts) {
      return accounts.fold<double>(
          0.0, (double sum, Account account) => sum + account.balance);
    });
  }

  Future<double> getMonthlyIncome(DateTime date) async {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0);

    final transactions = await isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .isArchivedEqualTo(false)
        .typeEqualTo(TransactionType.income)
        .dateBetween(start, end)
        .findAll();

    return transactions.fold<double>(
        0.0, (double sum, TransactionModel tx) => sum + tx.amount);
  }

  Future<double> getMonthlyExpense(DateTime date) async {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0);

    final transactions = await isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .isArchivedEqualTo(false)
        .typeEqualTo(TransactionType.expense)
        .dateBetween(start, end)
        .findAll();

    return transactions.fold<double>(
        0.0, (double sum, TransactionModel tx) => sum + tx.amount);
  }

  Stream<Map<String, double>> watchMonthlyStats() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);

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

  Future<Map<Category, double>> getCategoryBreakdown(
      DateTime start, DateTime end, {int? accountId, List<String>? tags, TransactionType type = TransactionType.expense}) async {
    var query = isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .isArchivedEqualTo(false)
        .typeEqualTo(type)
        .dateBetween(start, end);

    if (accountId != null) {
      query = query.accountIdEqualTo(accountId);
    }

    final transactions = await query.findAll();

    final Map<int, double> categoryIdToAmount = {};
    final Map<int, Category> categoryIdToCategory = {};

    for (var tx in transactions) {
      // Manual tag filtering since Isar 3.x filter on List<String> can be tricky without part-of-tag
      if (tags != null && tags.isNotEmpty) {
        final txTags = tx.tags ?? [];
        if (!tags.any((t) => txTags.contains(t))) continue;
      }

      final categoryId = tx.categoryId;
      categoryIdToAmount[categoryId] = (categoryIdToAmount[categoryId] ?? 0) + tx.amount;
      
      if (!categoryIdToCategory.containsKey(categoryId)) {
        await tx.category.load();
        final category = tx.category.value;
        if (category != null) {
          categoryIdToCategory[categoryId] = category;
        }
      }
    }

    final Map<Category, double> breakdown = {};
    categoryIdToAmount.forEach((id, amount) {
      final category = categoryIdToCategory[id];
      if (category != null) {
        breakdown[category] = amount;
      }
    });

    return breakdown;
  }

  Future<double> getCategoryMonthlyTotal(int categoryId, DateTime date) async {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0);
    
    final transactions = await isar.transactionModels
        .filter()
        .categoryIdEqualTo(categoryId)
        .dateBetween(start, end)
        .isDeletedEqualTo(false)
        .findAll();
        
    return transactions.fold<double>(0.0, (sum, tx) => sum + tx.amount);
  }

  Future<List<MapEntry<DateTime, double>>> getCategoryMonthlyStats(int categoryId, DateTime date) async {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0);
    
    final transactions = await isar.transactionModels
        .filter()
        .categoryIdEqualTo(categoryId)
        .dateBetween(start, end)
        .isDeletedEqualTo(false)
        .findAll();

    final Map<DateTime, double> daily = {};
    for (var tx in transactions) {
      final d = DateTime(tx.date.year, tx.date.month, tx.date.day);
      daily[d] = (daily[d] ?? 0) + tx.amount;
    }

    final sorted = daily.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted;
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
    
    // Fill all days with 0.0 to avoid "small dot" issues in charts
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      final d = start.add(Duration(days: i));
      daily[DateTime(d.year, d.month, d.day)] = 0.0;
    }

    for (var tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      daily[date] = (daily[date] ?? 0.0) + tx.amount;
    }

    final sorted = daily.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted;
  }

  Stream<Map<String, double>> watchRecentStats() {
    return watchSpendingTrends();
  }

  Stream<Map<String, double>> watchSpendingTrends() {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

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
    return watchBudgetStats();
  }

  Stream<List<Map<String, dynamic>>> watchBudgetStats() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return Rx.combineLatest2(
      isar.transactionModels
          .filter()
          .isDeletedEqualTo(false)
          .isArchivedEqualTo(false)
          .dateBetween(startOfMonth, endOfMonth)
          .typeEqualTo(TransactionType.expense)
          .watch(fireImmediately: true),
      isar.categorys.where().watch(fireImmediately: true),
      (t, c) => null,
    ).asyncMap((_) async {
      final categories =
          await isar.categorys.filter().isBudgetEqualTo(true).findAll();

      final List<Map<String, dynamic>> budgetStats = [];

      for (var category in categories) {
        final List<TransactionModel> spentTxs = await isar.transactionModels
            .filter()
            .categoryIdEqualTo(category.id)
            .dateBetween(startOfMonth, endOfMonth)
            .typeEqualTo(TransactionType.expense)
            .isDeletedEqualTo(false)
            .isArchivedEqualTo(false)
            .findAll();

        final double totalSpent =
            spentTxs.fold<double>(0.0, (sum, tx) => sum + tx.amount);

        budgetStats.add({
          'categoryId': category.id,
          'categoryName': category.name,
          'budgetLimit': category.budgetLimit ?? 0.0,
          'spent': totalSpent,
          'percentage': category.budgetLimit != null && category.budgetLimit! > 0
              ? (totalSpent / category.budgetLimit!) * 100
              : 0.0,
        });
      }
      return budgetStats;
    });
  }

  Future<Map<DateTime, int>> getTransactionHeatmapData() async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);

    final transactions = await isar.transactionModels
        .filter()
        .dateGreaterThan(startOfYear)
        .isDeletedEqualTo(false)
        .findAll();

    final Map<DateTime, int> heatmap = {};
    for (var tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      heatmap[date] = (heatmap[date] ?? 0) + 1;
    }
    return heatmap;
  }

  Future<Map<String, dynamic>> getQuickInsights(DateTime start, DateTime end) async {
    final transactions = await isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .isArchivedEqualTo(false)
        .dateBetween(start, end)
        .findAll();

    double totalIncome = 0;
    double totalExpense = 0;
    final int transactionCount = transactions.length;
    final Map<int, double> categorySpending = {};
    TransactionModel? largestExpense;

    for (var tx in transactions) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else if (tx.type == TransactionType.expense) {
        totalExpense += tx.amount;
        categorySpending[tx.categoryId] = (categorySpending[tx.categoryId] ?? 0) + tx.amount;
        if (largestExpense == null || tx.amount > largestExpense.amount) {
          largestExpense = tx;
        }
      }
    }

    final double savingsRate = totalIncome > 0 ? ((totalIncome - totalExpense) / totalIncome) * 100 : 0;
    final int days = end.difference(start).inDays + 1;
    final double avgDailySpend = days > 0 ? totalExpense / days : 0;

    int topCategoryId = -1;
    double topCategoryAmount = 0;
    categorySpending.forEach((id, amount) {
      if (amount > topCategoryAmount) {
        topCategoryAmount = amount;
        topCategoryId = id;
      }
    });

    String topCategoryName = 'None';
    if (topCategoryId != -1) {
      final cat = await isar.categorys.get(topCategoryId);
      topCategoryName = cat?.name ?? 'Unknown';
    }

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'savingsRate': savingsRate,
      'avgDailySpend': avgDailySpend,
      'transactionCount': transactionCount,
      'topCategory': topCategoryName,
      'topCategoryPercentage': totalExpense > 0 ? (topCategoryAmount / totalExpense) * 100 : 0,
      'largestExpense': largestExpense?.note ?? 'None',
      'largestExpenseAmount': largestExpense?.amount ?? 0,
    };
  }
}
