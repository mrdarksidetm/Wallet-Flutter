import 'package:isar/isar.dart';
import '../../database/models/transaction_model.dart';
import 'base_repository.dart';

class TransactionRepository extends BaseRepository<TransactionModel> {
  TransactionRepository(super.isar);

  Stream<List<TransactionModel>> watchLatest({int limit = 50}) {
    return isar.transactionModels
        .where()
        .sortByDateDesc()
        .limit(limit)
        .watch(fireImmediately: true);
  }

  Stream<List<TransactionModel>> watchByAccount(Id accountId) {
    return isar.transactionModels
        .filter()
        .accountIdEqualTo(accountId)
        .sortByDateDesc()
        .watch(fireImmediately: true);
  }

  Future<List<TransactionModel>> search({
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    List<int>? accountIds,
    List<int>? categoryIds,
  }) async {
    // Start with a base filter that includes all (id > -1) to ensure we have QAfterFilterCondition
    // This allows us to chain .and() logic and end up with a state that supports .sortBy...()
    QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition> q =
        isar.transactionModels.filter().idGreaterThan(-1);

    if (startDate != null && endDate != null) {
      q = q.and().dateBetween(startDate, endDate);
    }

    if (type != null) {
      q = q.and().typeEqualTo(type);
    }

    // Note: Isar filters on links (account/category) are tricky in simple queries without links logic
    // For now, we fetch and filter in memory if IDs provided, valid for local DB size.

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

    // Simple search by note
    final byNote = await isar.transactionModels
        .filter()
        .noteContains(query, caseSensitive: false)
        .sortByDateDesc()
        .findAll();

    // Also try to search related names or amounts
    // Note: Isar doesn't support direct filtering on links in one query easily
    // So we combine or stick to note for now for performance
    return byNote;
  }
}
