import 'dart:convert';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import '../models/transaction_model.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/auxiliary_models.dart';

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
            ..icon = _mapPaisaIcon(json['icon'], 'account_balance_wallet')
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
            ..icon = _mapPaisaIcon(json['icon'], 'category')
            ..type = json['type'] == 1 ? CategoryType.income : CategoryType.expense
            ..createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now()
            ..updatedAt = DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now();
          await isar.categorys.put(category);
        }
        uuidToCategory[uuid] = category;
      }

      // 3. Import Persons (Peoples)
      final Map<String, Person> uuidToPerson = {};
      final List<dynamic> peoplesJson = backup['peoples'] ?? [];
      for (var json in peoplesJson) {
        final uuid = json['uuid'] as String;
        var person = await isar.persons.filter().uuidEqualTo(uuid).findFirst();
        if (person == null) {
          person = Person()
            ..uuid = uuid
            ..name = json['name'] ?? 'Imported'
            ..contact = json['phoneNumber']
            ..color = _formatPaisaColor(json['color'])
            ..createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now()
            ..updatedAt = DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now();
          await isar.persons.put(person);
        }
        uuidToPerson[uuid] = person;
      }

      // 4. Import Loans
      final List<dynamic> loansJson = backup['loans'] ?? [];
      for (var json in loansJson) {
        final uuid = json['uuid'] as String;
        var loan = await isar.loans.filter().uuidEqualTo(uuid).findFirst();
        if (loan == null) {
          final personUuid = json['people'] as String?;
          var person = uuidToPerson[personUuid];
          
          // If no person linked, we might need a dummy person or handle it
          if (person == null && personUuid == null) {
             // Create a person with loan name if person is null in Paisa
             final name = json['name'] ?? 'Loan';
             person = await isar.persons.filter().nameEqualTo(name).findFirst();
             if (person == null) {
               person = Person()
                 ..name = name
                 ..color = _formatPaisaColor(json['color']);
               await isar.persons.put(person);
             }
          }

          loan = Loan()
            ..uuid = uuid
            ..amount = (json['amount'] as num?)?.toDouble() ?? 0.0
            ..type = json['type'] == 1 ? LoanType.borrowed : LoanType.lent
            ..isPaid = json['status'] == 1
            ..note = json['description']
            ..dueDate = DateTime.tryParse(json['expiryDateTime'] ?? '')
            ..createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now()
            ..updatedAt = DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now();
          
          if (person != null) {
            loan.person.value = person;
          }
          await isar.loans.put(loan);
          if (person != null) {
            await loan.person.save();
          }
        }
      }

      // 5. Import Transactions
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

      // 6. Recalculate Account Balances after all transactions are imported
      await _recalculateBalances();
    });
  }

  Future<void> _recalculateBalances() async {
    final accounts = await isar.accounts.where().findAll();
    for (var account in accounts) {
      final transactions = await isar.transactionModels
          .filter()
          .accountIdEqualTo(account.id)
          .isDeletedEqualTo(false)
          .findAll();

      double balance = 0.0;
      for (var tx in transactions) {
        if (tx.type == TransactionType.income) {
          balance += tx.amount;
        } else if (tx.type == TransactionType.expense) {
          balance -= tx.amount;
        }
        // Transfers are tricky if both accounts are in the same backup, 
        // but for a single account import, we just consider its own involvement.
      }
      account.balance = balance;
      await isar.accounts.put(account);
    }
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
          ..amount = amount
          ..date = date
          ..type = type
          ..note = data['note']
          ..accountId = account.id
          ..categoryId = category.id
          ..tags = (data['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? []
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        if (uuid.isNotEmpty) {
          transaction.uuid = uuid;
        }

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
      // Paisa uses 32-bit integers for colors (AARRGGBB)
      // We convert it to the 0xFF... string format
      return '0x${colorValue.toUnsigned(32).toRadixString(16).padLeft(8, '0').toUpperCase()}';
    }
    
    final colorStr = colorValue.toString();
    if (colorStr.startsWith('#')) {
      return '0xFF${colorStr.substring(1).toUpperCase()}';
    }
    return colorStr;
  }

  String _mapPaisaIcon(dynamic iconValue, String fallback) {
    if (iconValue == null) return fallback;

    // Paisa uses integer codes for icons. 
    // This is a partial mapping based on common Paisa icons to Material Symbols.
    final Map<int, String> iconMapping = {
      983273: 'payments',       // Cash/Money
      983079: 'account_balance_wallet',
      983451: 'shopping_cart',
      983678: 'restaurant',     // Food
      983679: 'directions_bus', // Transport
      983362: 'home',
      983804: 'medical_services',
      983471: 'school',
      984102: 'fitness_center',
      983709: 'movie',
      983307: 'phone',
      983411: 'lightbulb',      // Bills/Electricity
      983072: 'category',
      989276: 'handshake',      // Loan/Lent
      987119: 'person',
      // Add more as discovered
    };

    if (iconValue is int) {
      return iconMapping[iconValue] ?? fallback;
    }
    
    return iconValue.toString();
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
