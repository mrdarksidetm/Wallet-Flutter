import 'dart:io';
import 'package:csv/csv.dart' as csv;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import '../models/transaction_model.dart';

class CsvService {
  final Isar isar;

  CsvService(this.isar);

  Future<void> exportTransactions() async {
    // 1. Request Storage Permission
    if (!await _requestPermission()) {
      throw Exception('Storage permission denied');
    }

    // 2. Fetch Data
    final transactions = await isar.transactionModels.where().sortByDateDesc().findAll();
    
    // 3. Convert to CSV List
    List<List<dynamic>> rows = [];
    rows.add([
      'Date',
      'Time',
      'Type',
      'Amount',
      'Category',
      'Account',
      'Transfer Account',
      'Note',
      'Tags'
    ]); // Header

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

    // 4. Generate CSV String
    String csvData = const csv.ListToCsvConverter().convert(rows);

    // 5. Save to File
    final directory = await _getDownloadDirectory();
    final path = '${directory.path}/wallet_export_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    await file.writeAsString(csvData);
    
    // 6. Open File
    await OpenFilex.open(path);
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      // Android 11+ (API 30+) scoped storage usually doesn't need explicit permission for own app dirs,
      // but for "Downloads" or external, it might.
      // Manage External Storage is only for file managers.
      // For standard export, we often use generic storage or just write to app docs and share.
      // Trying generic storage permission logic.
      if (await Permission.storage.request().isGranted) return true;
      if (await Permission.manageExternalStorage.request().isGranted) return true;
      return false;
    }
    return true;
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // Create a directory in Download folder if possible, or use external storage dir
      Directory? directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
      return directory ?? await getApplicationDocumentsDirectory();
    }
    return await getApplicationDocumentsDirectory();
  }
}
