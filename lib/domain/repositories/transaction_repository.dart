abstract class TransactionRepository {
  Stream<List<dynamic>> watchTransactions(); // dynamic for now until entity defined
  Future<void> addTransaction(dynamic transaction);
}
