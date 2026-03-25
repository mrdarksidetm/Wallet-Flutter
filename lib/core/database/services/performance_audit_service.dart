import 'package:isar/isar.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/transaction_model.dart';

class PerformanceAuditService {
  final Isar isar;

  PerformanceAuditService(this.isar);

  Future<Map<String, dynamic>> runAudit() async {
    final results = <String, dynamic>{};
    
    // 1. Clear existing transactions for a clean test
    await isar.writeTxn(() => isar.transactionModels.clear());

    // 2. Prepare 10,000 transactions
    final accounts = await isar.accounts.where().findAll();
    final categories = await isar.categorys.where().findAll();
    
    if (accounts.isEmpty || categories.isEmpty) {
      return {'error': 'Need at least one account and one category to run audit'};
    }

    final accountId = accounts.first.id;
    final categoryId = categories.first.id;

    final transactions = List.generate(10000, (i) {
      return TransactionModel()
        ..amount = (i + 1) * 1.5
        ..date = DateTime.now().subtract(Duration(minutes: i))
        ..type = i % 2 == 0 ? TransactionType.expense : TransactionType.income
        ..accountId = accountId
        ..categoryId = categoryId
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();
    });

    // 3. Measure Insertion Time
    final stopwatch = Stopwatch()..start();
    await isar.writeTxn(() => isar.transactionModels.putAll(transactions));
    stopwatch.stop();
    results['insertion_time_ms'] = stopwatch.elapsedMilliseconds;

    // 4. Measure Query Time (Indexed: Date Desc)
    stopwatch.reset();
    stopwatch.start();
    final recentTxs = await isar.transactionModels
        .where()
        .sortByDateDesc()
        .limit(50)
        .findAll();
    stopwatch.stop();
    results['query_recent_50_ms'] = stopwatch.elapsedMilliseconds;
    results['count_retrieved'] = recentTxs.length;

    // 5. Measure Query Time (Filtered + Indexed: Type)
    stopwatch.reset();
    stopwatch.start();
    final expenses = await isar.transactionModels
        .where()
        .typeEqualTo(TransactionType.expense)
        .findAll();
    stopwatch.stop();
    results['query_all_expenses_ms'] = stopwatch.elapsedMilliseconds;
    results['expense_count'] = expenses.length;

    // 6. Measure Aggregation Time
    stopwatch.reset();
    stopwatch.start();
    final total = await isar.transactionModels
        .where()
        .amountProperty()
        .sum();
    stopwatch.stop();
    results['aggregation_sum_ms'] = stopwatch.elapsedMilliseconds;
    results['total_amount'] = total;

    return results;
  }
}
