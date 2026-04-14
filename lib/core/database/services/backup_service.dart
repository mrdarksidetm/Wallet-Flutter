import 'dart:io';
import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class BackupService {
  final Isar isar;
  final Ref ref;

  BackupService(this.isar, this.ref);

  Future<String> createBackup() async {
    // 1. Request Permission (Modern Android handling)
    if (Platform.isAndroid) {
      // [ACTION]: Request both storage and manageExternalStorage for broad compatibility.
      // [RATIONALE]: Newer Android versions (11+) require MANAGE_EXTERNAL_STORAGE for non-media files.
      await Permission.storage.request();
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }
    }

    // 2. Prompt User for Directory (SAF)
    final String? selectedDirectory =
        await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      throw Exception('Operation cancelled by user');
    }

    final tempDir = await getTemporaryDirectory();
    final backupTempPath = p.join(tempDir.path, 'temp_backup_${DateTime.now().millisecondsSinceEpoch}');
    final directory = Directory(backupTempPath);
    await directory.create(recursive: true);

    try {
      // 3. Backup Database
      final isarPath = p.join(directory.path, 'database.isar');
      await isar.copyToFile(isarPath);

      // 4. Backup SharedPreferences (Settings)
      final prefs = ref.read(sharedPreferencesProvider);
      final keys = prefs.getKeys();
      final Map<String, dynamic> prefsMap = {};
      for (final key in keys) {
        prefsMap[key] = prefs.get(key);
      }
      final prefsFile = File(p.join(directory.path, 'preferences.json'));
      await prefsFile.writeAsString(json.encode(prefsMap));

      // 5. Backup Profile Photos
      final appDocDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(directory.path);
      // We look for files starting with 'profile_photo_' in the app documents directory
      final List<File> photoFiles = [];
      await for (final entity in appDocDir.list()) {
        if (entity is File && p.basename(entity.path).startsWith('profile_photo_')) {
          photoFiles.add(entity);
        }
      }
      
      if (photoFiles.isNotEmpty) {
        final photosExportDir = Directory(p.join(directory.path, 'photos'));
        await photosExportDir.create();
        for (final photo in photoFiles) {
          await photo.copy(p.join(photosExportDir.path, p.basename(photo.path)));
        }
      }

      // 6. Create ZIP Archive
      final encoder = ZipFileEncoder();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final zipFileName = 'wallet_full_backup_$timestamp.zip';
      final zipPath = p.join(tempDir.path, zipFileName);
      
      encoder.create(zipPath);
      await encoder.addDirectory(directory);
      encoder.close();

      // 7. Move to user selected directory
      final finalPath = p.join(selectedDirectory, zipFileName);
      await File(zipPath).copy(finalPath);
      
      // Cleanup temp
      await directory.delete(recursive: true);
      await File(zipPath).delete();

      return finalPath;
    } catch (e) {
      // Cleanup on error
      if (await directory.exists()) await directory.delete(recursive: true);
      throw Exception('Backup failed: $e');
    }
  }

  Future<bool> restoreBackup() async {
    // 1. Pick the ZIP file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null || result.files.isEmpty) return false;

    final backupFile = File(result.files.single.path!);
    final tempDir = await getTemporaryDirectory();
    final extractPath = p.join(tempDir.path, 'restore_${DateTime.now().millisecondsSinceEpoch}');
    
    try {
      // 2. Extract ZIP
      final bytes = await backupFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          File(p.join(extractPath, filename))
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory(p.join(extractPath, filename)).createSync(recursive: true);
        }
      }

      // The archive usually contains a top-level folder with the temp name used during creation
      // Let's find where database.isar is
      String? rootPath;
      final dir = Directory(extractPath);
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File && p.basename(entity.path) == 'database.isar') {
          rootPath = p.dirname(entity.path);
          break;
        }
      }

      if (rootPath == null) throw Exception('Invalid backup: database.isar not found');

      // 3. Restore Photos
      final photosSourceDir = Directory(p.join(rootPath, 'photos'));
      if (await photosSourceDir.exists()) {
        final appDocDir = await getApplicationDocumentsDirectory();
        await for (final entity in photosSourceDir.list()) {
          if (entity is File) {
            await entity.copy(p.join(appDocDir.path, p.basename(entity.path)));
          }
        }
      }

      // 4. Restore SharedPreferences
      final prefsFile = File(p.join(rootPath, 'preferences.json'));
      if (await prefsFile.exists()) {
        final prefsMap = json.decode(await prefsFile.readAsString()) as Map<String, dynamic>;
        final prefs = ref.read(sharedPreferencesProvider);
        // Clear current first? Maybe safer to just overwrite.
        for (final entry in prefsMap.entries) {
          final value = entry.value;
          if (value is String) await prefs.setString(entry.key, value);
          else if (value is bool) await prefs.setBool(entry.key, value);
          else if (value is int) await prefs.setInt(entry.key, value);
          else if (value is double) await prefs.setDouble(entry.key, value);
          else if (value is List) await prefs.setStringList(entry.key, value.cast<String>());
        }
      }

      // 5. Restore Database (Last step because we need to close Isar)
      final isarBackupFile = File(p.join(rootPath, 'database.isar'));
      final dbDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbDir.path, '${isar.name}.isar');

      await isar.close();
      await isarBackupFile.copy(dbPath);

      // Cleanup
      await Directory(extractPath).delete(recursive: true);
      
      return true;
    } catch (e) {
      if (await Directory(extractPath).exists()) await Directory(extractPath).delete(recursive: true);
      throw Exception('Restore failed: $e');
    }
  }
}
