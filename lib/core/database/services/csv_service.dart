import 'dart:io';
import 'package:csv/csv.dart' as csv;
import 'package:isar/isar.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/transaction_model.dart';
import '../models/account.dart';
import '../models/category.dart';

class CsvService {
  final Isar isar;

  CsvService(this.isar);

  Future<void> importTransactions() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = File(result.files.single.path!);
    final input = await file.readAsString();
    
    final fields = const csv.CsvToListConverter().convert(input);
    if (fields.length < 2) throw Exception('CSV file is empty or invalid');

    await isar.writeTxn(() async {
      for (var i = 1; i < fields.length; i++) {
        final row = fields[i];
        if (row.length < 6) continue;

        try {
          final dateStr = row[0].toString();
          final timeStr = row[1].toString();
          final typeStr = row[2].toString().toLowerCase();
          final amount = double.tryParse(row[3].toString()) ?? 0.0;
          final categoryName = row[4].toString();
          final accountName = row[5].toString();
          final transferAccountName = row.length > 6 ? row[6].toString() : '';
          final note = row.length > 7 ? row[7].toString() : '';
          final tagsStr = row.length > 8 ? row[8].toString() : '';

          final dateTime = DateTime.tryParse('${dateStr}T$timeStr') ?? DateTime.now();
          
          var account = await isar.accounts.filter().nameEqualTo(accountName).findFirst();
          if (account == null) {
            account = Account()
              ..name = accountName
              ..type = AccountType.cash
              ..color = '0xFF9E9E9E'
              ..icon = 'account_balance_wallet'
              ..bankName = ''
              ..number = ''
              ..validThru = DateTime.now()
              ..createdAt = DateTime.now()
              ..updatedAt = DateTime.now();
            await isar.accounts.put(account);
          }

          final type = typeStr == 'income' ? TransactionType.income : TransactionType.expense;
          var category = await isar.categorys.filter().nameEqualTo(categoryName).findFirst();
          if (category == null) {
            category = Category()
              ..name = categoryName
              ..type = type == TransactionType.income ? CategoryType.income : CategoryType.expense
              ..color = '0xFF9E9E9E'
              ..icon = 'category'
              ..description = ''
              ..createdAt = DateTime.now()
              ..updatedAt = DateTime.now();
            await isar.categorys.put(category);
          }

          final transaction = TransactionModel()
            ..amount = amount
            ..date = dateTime
            ..type = type
            ..note = note
            ..accountId = account.id
            ..categoryId = category.id
            ..tags = tagsStr.isNotEmpty ? tagsStr.split(';') : []
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();

          transaction.account.value = account;
          transaction.category.value = category;

          if (type == TransactionType.transfer && transferAccountName.isNotEmpty) {
             var tAccount = await isar.accounts.filter().nameEqualTo(transferAccountName).findFirst();
             if (tAccount != null) {
               transaction.transferAccount.value = tAccount;
             }
          }

          await isar.transactionModels.put(transaction);
          await transaction.account.save();
          await transaction.category.save();
          if (transaction.transferAccount.value != null) {
            await transaction.transferAccount.save();
          }

          if (type == TransactionType.income) {
            account.balance += amount;
          } else if (type == TransactionType.expense) {
            account.balance -= amount;
          }
          await isar.accounts.put(account);

        } catch (e) {
          continue;
        }
      }
    });
  }

  Future<void> exportTransactions() async {
    // 1. Check/Request Permission on Android
    if (Platform.isAndroid) {
      if (!await Permission.storage.request().isGranted && 
          !await Permission.manageExternalStorage.request().isGranted) {
        // Many newer devices require MANAGE_EXTERNAL_STORAGE for non-media files
      }
    }

    // 2. Prompt User for Directory
    final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) throw Exception('Export cancelled');

    // 3. Fetch Data
    final transactions = await isar.transactionModels.where().sortByDateDesc().findAll();
    
    // 4. Convert to CSV List
    List<List<dynamic>> rows = [];
    rows.add(['Date', 'Time', 'Type', 'Amount', 'Category', 'Account', 'Transfer Account', 'Note', 'Tags']);

    for (var tx in transactions) {
      rows.add([
        tx.date.toIso8601String().split('T')[0],
        tx.date.toIso8601String().split('T')[1].split('.')[0],
        tx.type.name.toUpperCase(),
        tx.amount,
        tx.category.value?.name ?? 'Unknown',
        tx.account.value?.name ?? 'Unknown',
        tx.transferAccount.value?.name ?? '',
        tx.note ?? '',
        tx.tags?.join(';') ?? '',
      ]);
    }

    // 5. Generate CSV String
    String csvData = const csv.ListToCsvConverter().convert(rows);

    try {
      // 6. Save to File in selected directory
      final path = p.join(selectedDirectory, 'wallet_export_${DateTime.now().millisecondsSinceEpoch}.csv');
      final file = File(path);
      await file.writeAsString(csvData);
      
      // 7. Open File (Optional)
      try {
        await OpenFilex.open(path);
      } catch (_) {}
    } catch (e) {
      throw Exception('Could not write to folder. Please ensure you have given storage permission to Wallet. Error: $e');
    }
  }
}
