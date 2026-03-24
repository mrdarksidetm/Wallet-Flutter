import 'package:isar/isar.dart';
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
    return accounts.fold<double>(0.0, (double sum, Account account) => sum + account.balance);
  }

  Stream<double> watchTotalBalance() {
    return isar.accounts.where().watch(fireImmediately: true).map((accounts) {
      return accounts.fold<double>(0.0, (double sum, Account account) => sum + account.balance);
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
      return accounts.fold<double>(0.0, (double sum, Account account) => sum + account.balance);
    });
  }

  Future<double> getMonthlyIncome(DateTime date) async {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
    
    return await isar.transactionModels
        .filter()
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
        .typeEqualTo(TransactionType.expense)
        .dateBetween(start, end)
        .amountProperty()
        .sum();
  }

  Future<double> getPeriodExpense(DateTime start, DateTime end) async {
    return await isar.transactionModels
        .filter()
        .typeEqualTo(TransactionType.expense)
        .dateBetween(start, end)
        .amountProperty()
        .sum();
  }

  Future<Map<Category, double>> getCategoryBreakdown(DateTime start, DateTime end) async {
    final transactions = await isar.transactionModels
        .filter()
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

  Future<List<MapEntry<DateTime, double>>> getDailyStats(DateTime start, DateTime end) async {
    final transactions = await isar.transactionModels
        .filter()
        .typeEqualTo(TransactionType.expense)
        .dateBetween(start, end)
        .findAll();

    final Map<DateTime, double> daily = {};
    for (var tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      daily[date] = (daily[date] ?? 0) + tx.amount;
    }
    
    final sorted = daily.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return sorted;
  }

  Stream<Map<String, double>> watchRecentStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = today.subtract(const Duration(days: 7));
    final thirtyDaysAgo = today.subtract(const Duration(days: 30));

    return isar.transactionModels
        .filter()
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
    return isar.categorys
        .filter()
        .isBudgetEqualTo(true)
        .watch(fireImmediately: true)
        .asyncMap((categories) async {
      final List<Map<String, dynamic>> budgetStats = [];
      
      for (var category in categories) {
        final spent = await isar.transactionModels
            .filter()
            .categoryIdEqualTo(category.id)
            .dateBetween(startOfMonth, endOfMonth)
            .typeEqualTo(TransactionType.expense)
            .amountProperty()
            .sum();
            
        budgetStats.add({
          'category': category,
          'spent': spent,
          'limit': category.budgetLimit ?? 0.0,
          'percent': (category.budgetLimit != null && category.budgetLimit! > 0) 
              ? (spent / category.budgetLimit!) 
              : 0.0,
        });
      }
      return budgetStats;
    });
  }

  Stream<Map<String, double>> watchMonthlyStats() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return isar.transactionModels
        .filter()
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
}
