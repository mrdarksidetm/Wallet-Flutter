import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Phase 48: Multi-Account Reconciliation Workflow
///
/// Allows users to manually verify app data against a physical bank statement.
/// Uses Riverpod to dynamically emit differences as transactions are checked/unchecked.
class ReconciliationNotifier extends StateNotifier<double> {
  double _bankBalance = 0.0;
  double _clearedAppBalance = 0.0;

  ReconciliationNotifier() : super(0.0);

  void setBankStatementBalance(double balance) {
    _bankBalance = balance;
    _updateDifference();
  }

  void toggleTransactionCleared(double amount, bool isCleared) {
    if (isCleared) {
      _clearedAppBalance += amount;
    } else {
      _clearedAppBalance -= amount;
    }
    _updateDifference();
  }

  void _updateDifference() {
    state = _bankBalance - _clearedAppBalance;
  }
}

final reconciliationProvider = StateNotifierProvider<ReconciliationNotifier, double>((ref) {
  return ReconciliationNotifier();
});
