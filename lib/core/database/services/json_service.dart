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
    if (Platform.isAndroid) {
      await Permission.storage.request();
    }

    final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) throw Exception('Export cancelled');

    final transactions = await isar.transactionModels.where().sortByDateDesc().findAll();
    
    final List<Map<String, dynamic>> jsonList = [];
    for (var tx in transactions) {
      await tx.category.load();
      await tx.account.load();
      await tx.transferAccount.load();

      jsonList.add({
        'uuid': tx.uuid,
        'amount': tx.amount,
        'date': tx.date.toIso8601String(),
        'type': tx.type.name,
        'note': tx.note,
        'categoryId': tx.categoryId,
        'categoryUuid': tx.category.value?.uuid,
        'categoryName': tx.category.value?.name,
        'accountId': tx.accountId,
        'accountUuid': tx.account.value?.uuid,
        'accountName': tx.account.value?.name,
        'transferAccountId': tx.transferAccount.value?.id,
        'transferAccountUuid': tx.transferAccount.value?.uuid,
        'transferAccountName': tx.transferAccount.value?.name,
        'tags': tx.tags,
      });
    }

    final String jsonData = jsonEncode(jsonList);
    final path = p.join(selectedDirectory, 'wallet_export_${DateTime.now().millisecondsSinceEpoch}.json');
    final file = File(path);
    await file.writeAsString(jsonData);
  }

  Future<void> importTransactions() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'txt'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = File(result.files.single.path!);
    final input = await file.readAsString();
    final dynamic decoded = jsonDecode(input);

    if (decoded is Map<String, dynamic> && decoded.containsKey('transactions')) {
      await _importPaisaBackup(decoded);
    } else if (decoded is List) {
      await _importStandardBackup(decoded);
    }
  }

  Future<void> _importPaisaBackup(Map<String, dynamic> backup) async {
    await isar.writeTxn(() async {
      // 1. Import Accounts
      final Map<String, Account> uuidToAccount = {};
      final List<dynamic> accountsJson = backup['accounts'] ?? [];
      for (var json in accountsJson) {
        final uuid = json['uuid'] as String;
        var account = await isar.accounts.filter().uuidEqualTo(uuid).findFirst();
        if (account == null) {
          account = Account()
            ..uuid = uuid
            ..name = json['name'] ?? 'Imported'
            ..bankName = json['bankName'] ?? ''
            ..balance = (json['amount'] as num?)?.toDouble() ?? 0.0
            ..color = _formatPaisaColor(json['color'])
            ..icon = 'account_balance_wallet' // Default fallback for integer icon codes
            ..type = _mapPaisaAccountType(json['type'])
            ..createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now()
            ..updatedAt = DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now();
          await isar.accounts.put(account);
        }
        uuidToAccount[uuid] = account;
      }

      // 2. Import Categories
      final Map<String, Category> uuidToCategory = {};
      final List<dynamic> categoriesJson = backup['categories'] ?? [];
      for (var json in categoriesJson) {
        final uuid = json['uuid'] as String;
        var category = await isar.categorys.filter().uuidEqualTo(uuid).findFirst();
        if (category == null) {
          category = Category()
            ..uuid = uuid
            ..name = json['name'] ?? 'Imported'
            ..description = json['description'] ?? ''
            ..color = _formatPaisaColor(json['color'])
            ..icon = 'category' // Default fallback for integer icon codes
            ..type = json['type'] == 1 ? CategoryType.income : CategoryType.expense
            ..createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now()
            ..updatedAt = DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now();
          await isar.categorys.put(category);
        }
        uuidToCategory[uuid] = category;
      }

      // 3. Import Transactions
      final List<dynamic> transactionsJson = backup['transactions'] ?? [];
      for (var json in transactionsJson) {
        final uuid = json['uuid'] as String;
        final existing = await isar.transactionModels.filter().uuidEqualTo(uuid).findFirst();
        if (existing != null) continue;

        final accountUuid = json['account'] as String?;
        final categoryUuid = json['category'] as String?;
        final account = uuidToAccount[accountUuid];
        final category = uuidToCategory[categoryUuid];

        if (account == null || category == null) continue;

        final transaction = TransactionModel()
          ..uuid = uuid
          ..amount = (json['amount'] as num?)?.toDouble() ?? 0.0
          ..date = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now()
          ..type = json['type'] == 1 ? TransactionType.income : TransactionType.expense
          ..note = json['name']
          ..accountId = account.id
          ..categoryId = category.id
          ..tags = (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? []
          ..createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now()
          ..updatedAt = DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now();

        transaction.account.value = account;
        transaction.category.value = category;

        await isar.transactionModels.put(transaction);
        await transaction.account.save();
        await transaction.category.save();
      }
    });
  }

  Future<void> _importStandardBackup(List<dynamic> jsonList) async {
    await isar.writeTxn(() async {
      for (var item in jsonList) {
        final data = item as Map<String, dynamic>;
        
        final uuid = data['uuid'] as String? ?? '';
        if (uuid.isNotEmpty) {
          final existing = await isar.transactionModels.filter().uuidEqualTo(uuid).findFirst();
          if (existing != null) continue;
        }

        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        final date = DateTime.tryParse(data['date'] ?? '') ?? DateTime.now();
        final type = TransactionType.values.firstWhere(
          (e) => e.name == data['type'], 
          orElse: () => TransactionType.expense
        );
        final categoryName = data['categoryName'] as String? ?? 'Imported';
        final accountName = data['accountName'] as String? ?? 'Imported';

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
          ..uuid = uuid
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

  String _formatPaisaColor(dynamic colorValue) {
    if (colorValue == null) return '0xFF2196F3';
    if (colorValue is int) {
      return '0x${colorValue.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    }
    return colorValue.toString();
  }

  AccountType _mapPaisaAccountType(int? type) {
    switch (type) {
      case 0: return AccountType.cash;
      case 1: return AccountType.card;
      case 2: return AccountType.savings;
      default: return AccountType.cash;
    }
  }
}
