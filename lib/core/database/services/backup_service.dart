import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class BackupService {
  final Isar isar;

  BackupService(this.isar);

  Future<String> createBackup() async {
    // 1. Request Permission (Modern Android handling)
    if (Platform.isAndroid) {
      await Permission.storage.request();
      // Note: On Android 13+, Permission.storage might be permanentlyDenied even if SAF works.
      // But we request it just in case some legacy logic triggers.
    }

    // 2. Prompt User for Directory (SAF)
    final String? selectedDirectory =
        await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      throw Exception('Operation cancelled by user');
    }

    final backupDir = Directory(selectedDirectory);
    if (!await backupDir.exists()) {
      try {
        await backupDir.create(recursive: true);
      } catch (e) {
        throw Exception('Storage Permission Denied or folder inaccessible: $e');
      }
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final backupPath = p.join(backupDir.path, 'wallet_backup_$timestamp.isar');

    try {
      // Isar copyToFile creates a compact backup of the database
      await isar.copyToFile(backupPath);
      return backupPath;
    } catch (e) {
      throw Exception('Failed to write backup file: $e');
    }
  }

  Future<bool> restoreBackup() async {
    // 1. Pick the file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, // .isar files might not have a registered mime type
    );

    if (result == null || result.files.isEmpty) return false;

    final backupFile = File(result.files.single.path!);
    if (!await backupFile.exists()) throw Exception('Backup file not found');

    final dbDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dbDir.path, '${isar.name}.isar');

    // Close instance - CRITICAL: All providers will be broken after this!
    await isar.close();

    // Replace file
    await backupFile.copy(dbPath);

    return true;
  }
}
