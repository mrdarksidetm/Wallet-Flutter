import 'package:isar/isar.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../database/models/transaction_model.dart';
import 'base_repository.dart';

class TransactionRepository extends BaseRepository<TransactionModel> {
  TransactionRepository(super.isar);

  Stream<List<TransactionModel>> watchLatest({int limit = 50}) {
    return isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .isArchivedEqualTo(false)
        .sortByDateDesc()
        .limit(limit)
        .watch(fireImmediately: true);
  }

  Stream<List<TransactionModel>> watchByAccount(Id accountId) {
    return isar.transactionModels
        .filter()
        .accountIdEqualTo(accountId)
        .isDeletedEqualTo(false)
        .isArchivedEqualTo(false)
        .sortByDateDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<TransactionModel>> watchArchived() {
    return isar.transactionModels
        .filter()
        .isDeletedEqualTo(false)
        .isArchivedEqualTo(true)
        .sortByDateDesc()
        .watch(fireImmediately: true);
  }

  Future<void> archive(Id id) async {
    final tx = await isar.transactionModels.get(id);
    if (tx != null) {
      tx.isArchived = true;
      tx.updatedAt = DateTime.now();
      await isar.writeTxn(() => isar.transactionModels.put(tx));
    }
  }

  Future<void> unarchive(Id id) async {
    final tx = await isar.transactionModels.get(id);
    if (tx != null) {
      tx.isArchived = false;
      tx.updatedAt = DateTime.now();
      await isar.writeTxn(() => isar.transactionModels.put(tx));
    }
  }

  Future<void> softDelete(Id id) async {
    final tx = await isar.transactionModels.get(id);
    if (tx != null) {
      tx.isDeleted = true;
      tx.updatedAt = DateTime.now();
      await isar.writeTxn(() => isar.transactionModels.put(tx));
    }
  }

  Future<Map<DateTime, int>> getTransactionHeatmapData() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final transactions = await isar.transactionModels
        .filter()
        .dateBetween(startOfMonth, endOfMonth)
        .findAll();

    final Map<DateTime, int> heatmap = {};
    for (var tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      heatmap[date] = (heatmap[date] ?? 0) + 1;
    }

    // Convert count to intensity (0-3)
    final intensityMap = heatmap.map((date, count) {
      int intensity = 0;
      if (count > 0) intensity = 1;
      if (count > 3) intensity = 2;
      if (count > 7) intensity = 3;
      return MapEntry(date, intensity);
    });

    return intensityMap;
  }

  Future<List<FlSpot>> getMonthlyTrendData() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final transactions = await isar.transactionModels
        .filter()
        .dateBetween(thirtyDaysAgo, now)
        .sortByDate()
        .findAll();

    final Map<int, double> dailyTotals = {};
    // Initialize last 30 days with 0
    for (int i = 0; i <= 30; i++) {
      final date = thirtyDaysAgo.add(Duration(days: i));
      dailyTotals[date.day] = 0;
    }

    for (var tx in transactions) {
      if (tx.type == TransactionType.expense) {
        dailyTotals[tx.date.day] = (dailyTotals[tx.date.day] ?? 0) + tx.amount;
      }
    }

    final List<FlSpot> spots = [];
    for (int i = 0; i <= 30; i++) {
      final date = thirtyDaysAgo.add(Duration(days: i));
      spots.add(FlSpot(i.toDouble(), dailyTotals[date.day] ?? 0));
    }

    return spots;
  }

  Future<List<TransactionModel>> search({
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    List<int>? accountIds,
    List<int>? categoryIds,
  }) async {
    QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition> q =
        isar.transactionModels.filter().idGreaterThan(-1);

    if (startDate != null && endDate != null) {
      q = q.and().dateBetween(startDate, endDate);
    }

    if (type != null) {
      q = q.and().typeEqualTo(type);
    }

    var results = await q.sortByDateDesc().findAll();

    if (query != null && query.isNotEmpty) {
      final lower = query.toLowerCase();
      results = results
          .where((t) => (t.note?.toLowerCase().contains(lower) ?? false))
          .toList();
    }

    if (accountIds != null && accountIds.isNotEmpty) {
      results = results
          .where((t) => accountIds.contains(t.account.value?.id))
          .toList();
    }

    if (categoryIds != null && categoryIds.isNotEmpty) {
      results = results
          .where((t) => categoryIds.contains(t.category.value?.id))
          .toList();
    }

    return results;
  }

  Future<List<TransactionModel>> searchTransactions(String query) async {
    if (query.isEmpty) return [];

    final byNote = await isar.transactionModels
        .filter()
        .noteContains(query, caseSensitive: false)
        .sortByDateDesc()
        .findAll();

    return byNote;
  }
}
