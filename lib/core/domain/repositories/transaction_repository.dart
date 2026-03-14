import 'transaction.dart';

/// Abstract repository defining the contract for transaction operations.
/// This acts as a scalable interface, allowing the implementation to be easily 
/// swapped (e.g., Local Database, Remote API, Mock for testing) without altering UI code.
abstract class TransactionRepository {
  Future<void> add(Transaction transaction);
  Future<void> update(Transaction transaction);
  Future<void> delete(String id);
  Future<List<Transaction>> getAllTransactions();
  
  /// Gets transactions filtered by a specific month and year.
  Future<List<Transaction>> getTransactionsByMonth(int month, int year);
}

/// Concrete implementation of the TransactionRepository.
/// 
/// Monthly Filtering Logic:
/// The [getTransactionsByMonth] method works by retrieving the dataset and 
/// filtering the [DateTime.month] and [DateTime.year] properties. In a robust 
/// SQL/NoSQL implementation, this filter would be passed directly into the query 
/// engine (e.g., `WHERE date >= start_of_month AND date <= end_of_month`) for 
/// optimized performance. Here, it is demonstrated using Dart iterables for flexibility.
class LocalTransactionRepository implements TransactionRepository {
  // Simulating an in-memory storage for this example implementation.
  // In reality, this would wrap an Isar, Hive, or SQLite instance.
  final List<Transaction> _storage = [];

  @override
  Future<void> add(Transaction transaction) async {
    _storage.add(transaction);
  }

  @override
  Future<void> update(Transaction transaction) async {
    final index = _storage.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _storage[index] = transaction;
    }
  }

  @override
  Future<void> delete(String id) async {
    _storage.removeWhere((t) => t.id == id);
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final copy = List<Transaction>.from(_storage);
    // Sort descending by date (newest first)
    copy.sort((a, b) => b.date.compareTo(a.date));
    return copy;
  }

  @override
  Future<List<Transaction>> getTransactionsByMonth(int month, int year) async {
    final results = _storage.where((t) {
      return t.date.month == month && t.date.year == year;
    }).toList();
    
    // Sort descending by date
    results.sort((a, b) => b.date.compareTo(a.date));
    return results;
  }
}
