import 'package:isar/isar.dart';
import '../models/account.dart';
import '../models/category.dart';

class SeedService {
  final Isar isar;

  SeedService(this.isar);

  Future<void> seedDefaults() async {
    final categoryCount = await isar.categorys.count();
    final accountCount = await isar.accounts.count();

    if (categoryCount > 0 && accountCount > 0) return;

    await isar.writeTxn(() async {
      if (categoryCount == 0) {
        final defaults = [
          // Income
          Category()
            ..name = 'Salary'
            ..icon = 'payments'
            ..color = '0xFF4CAF50'
            ..type = CategoryType.income
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
          Category()
            ..name = 'Dividend'
            ..icon = 'trending_up'
            ..color = '0xFF8BC34A'
            ..type = CategoryType.income
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
          // Expense
          Category()
            ..name = 'Food & Drinks'
            ..icon = 'restaurant'
            ..color = '0xFFFFC107'
            ..type = CategoryType.expense
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
          Category()
            ..name = 'Transport'
            ..icon = 'directions_bus'
            ..color = '0xFF2196F3'
            ..type = CategoryType.expense
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
          Category()
            ..name = 'Shopping'
            ..icon = 'shopping_bag'
            ..color = '0xFFE91E63'
            ..type = CategoryType.expense
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
          Category()
            ..name = 'Bills'
            ..icon = 'receipt_long'
            ..color = '0xFF9C27B0'
            ..type = CategoryType.expense
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
          Category()
            ..name = 'Health'
            ..icon = 'medical_services'
            ..color = '0xFFF44336'
            ..type = CategoryType.expense
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
        ];
        await isar.categorys.putAll(defaults);
      }

      // 3. Add default Cash account if none
      final accCount = await isar.accounts.count();
      if (accCount == 0) {
        final cash = Account()
          ..name = 'Cash'
          ..type = AccountType.cash
          ..balance = 0.0
          ..color = '0xFF4CAF50'
          ..icon = 'payments'
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();
        await isar.accounts.put(cash);
      }
    });
  }
}
