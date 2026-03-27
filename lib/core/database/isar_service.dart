import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/account.dart';
import 'models/category.dart';
import 'models/transaction_model.dart';
import 'models/auxiliary_models.dart';
import 'services/seed_service.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      final isar = await Isar.open(
        [
          AccountSchema,
          CategorySchema,
          TransactionModelSchema,
          PersonSchema,
          PlaceSchema,
          BudgetSchema,
          LoanSchema,
          GoalSchema,
          RecurringSchema,
          LabelSchema,
        ],
        directory: dir.path,
        inspector: true,
      );
      
      // Seed default data if database is empty
      final seedService = SeedService(isar);
      await seedService.seedDefaults();

      return isar;
    }
    final existing = Isar.getInstance();
    if (existing == null) throw StateError('Isar instance not found after initialization.');
    return Future.value(existing);
  }
}

