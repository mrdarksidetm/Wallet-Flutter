import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;

class BackupService {
  final Isar isar;

  BackupService(this.isar);

  Future<String> createBackup() async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) throw Exception('Permission denied');
    }

    final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(directory.path, 'WalletBackups'));
    if (!await backupDir.exists()) await backupDir.create(recursive: true);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = p.join(backupDir.path, 'wallet_backup_$timestamp.isar');

    // Isar copyToFile creates a compact backup of the database
    await isar.copyToFile(backupPath);
    return backupPath;
  }

  Future<void> restoreBackup(String path) async {
    final backupFile = File(path);
    if (!await backupFile.exists()) throw Exception('Backup file not found');

    // Restore logic: 
    // 1. Close current isar
    // 2. Replace database file
    // 3. Reopen isar
    
    // Note: Since Isar is usually managed by a provider, a full app restart 
    // might be required after file replacement for a clean state.
    
    final dbDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dbDir.path, '${isar.name}.isar');

    // Close instance
    await isar.close();

    // Replace file
    await backupFile.copy(dbPath);

    // After this, the app should be restarted or the Isar provider invalidated.
  }
}
