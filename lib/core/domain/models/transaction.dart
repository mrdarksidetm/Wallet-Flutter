enum TransactionType {
  income,
  expense,
  transfer
}

/// A robust, scalable Transaction model for personal finance.
/// 
/// Why use an Enum for types? 
/// Enums provide compile-time safety, ensuring that a transaction can only
/// be one of the predefined types (income, expense, transfer). This prevents
/// typos and invalid states compared to using raw strings, and allows for switch
/// statement exhaustiveness checking in Dart.
/// 
/// Relational IDs (categoryId, accountId):
/// Storing only the relational IDs (instead of the full Category or Account object)
/// normalizes the database, keeping the Transaction model lightweight. This is crucial
/// for scalability when dealing with thousands of transactions. The UI layer or 
/// repository can perform joins with these IDs when displaying data.
class Transaction {
  final String id;
  final double amount;
  final String? note;
  final DateTime date;
  final TransactionType type;
  final String categoryId;
  final String accountId;

  Transaction({
    required this.id,
    required this.amount,
    this.note,
    required this.date,
    required this.type,
    required this.categoryId,
    required this.accountId,
  });

  /// Factory constructor to generate a Transaction from a local storage JSON map
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      categoryId: json['categoryId'] as String,
      accountId: json['accountId'] as String,
    );
  }

  /// Converts the Transaction into a JSON map for local storage preparation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String(),
      'type': type.name,
      'categoryId': categoryId,
      'accountId': accountId,
    };
  }
}
