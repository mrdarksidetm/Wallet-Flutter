import 'dart:convert';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import '../models/transaction_model.dart';
import '../models/account.dart';
import '../models/category.dart';

class JsonService {
  final Isar isar;

  JsonService(this.isar);

  Future<void> exportTransactions() async {
    // 1. Permission Check
    if (Platform.isAndroid) {
      await Permission.storage.request();
    }

    // 2. Directory Picker
    final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) throw Exception('Export cancelled');

    // 3. Fetch Transactions
    final transactions = await isar.transactionModels.where().sortByDateDesc().findAll();
    
    final List<Map<String, dynamic>> jsonList = [];
    for (var tx in transactions) {
      await tx.category.load();
      await tx.account.load();
      await tx.transferAccount.load();

      jsonList.add({
        'id': tx.id,
        'amount': tx.amount,
        'date': tx.date.toIso8601String(),
        'type': tx.type.name,
        'note': tx.note,
        'categoryId': tx.categoryId,
        'categoryName': tx.category.value?.name,
        'accountId': tx.accountId,
        'accountName': tx.account.value?.name,
        'transferAccountId': tx.transferAccount.value?.id,
        'transferAccountName': tx.transferAccount.value?.name,
        'tags': tx.tags,
      });
    }

    // 4. Write to File
    final String jsonData = jsonEncode(jsonList);
    final path = p.join(selectedDirectory, 'wallet_export_${DateTime.now().millisecondsSinceEpoch}.json');
    final file = File(path);
    await file.writeAsString(jsonData);
  }

  Future<void> importTransactions() async {
    // 1. File Picker
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'txt'],
    );

    if (result == null || result.files.isEmpty) return;

    // 2. Parse JSON
    final file = File(result.files.single.path!);
    final input = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(input);

    await isar.writeTxn(() async {
      for (var item in jsonList) {
        final data = item as Map<String, dynamic>;
        
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        final date = DateTime.tryParse(data['date'] ?? '') ?? DateTime.now();
        final type = TransactionType.values.firstWhere(
          (e) => e.name == data['type'], 
          orElse: () => TransactionType.expense
        );
        final categoryName = data['categoryName'] as String? ?? 'Imported';
        final accountName = data['accountName'] as String? ?? 'Imported';

        // Find or Create Account
        var account = await isar.accounts.filter().nameEqualTo(accountName).findFirst();
        if (account == null) {
          account = Account()
            ..name = accountName
            ..type = AccountType.cash
            ..color = '0xFF9E9E9E'
            ..icon = 'account_balance_wallet'
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();
          await isar.accounts.put(account);
        }

        // Find or Create Category
        var category = await isar.categorys.filter().nameEqualTo(categoryName).findFirst();
        if (category == null) {
          category = Category()
            ..name = categoryName
            ..type = type == TransactionType.income ? CategoryType.income : CategoryType.expense
            ..color = '0xFF9E9E9E'
            ..icon = 'category'
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();
          await isar.categorys.put(category);
        }

        final transaction = TransactionModel()
          ..amount = amount
          ..date = date
          ..type = type
          ..note = data['note']
          ..accountId = account.id
          ..categoryId = category.id
          ..tags = (data['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? []
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        transaction.account.value = account;
        transaction.category.value = category;

        await isar.transactionModels.put(transaction);
        await transaction.account.save();
        await transaction.category.save();
      }
    });
  }
}
