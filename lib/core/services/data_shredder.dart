import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Phase 30: Secure Data Shredding
///
/// Exposes a "Factory Reset" logic sequence to wipe all user data cleanly.
/// This is critical for offline-first privacy. We clear Isar collections,
/// and clear shared preferences/cache directories to prevent ghost data extraction.
class DataShredder {
  static Future<bool> factoryReset(Isar isar) async {
    try {
      // 1. Drop all data from the Isar database
      await isar.writeTxn(() async {
        await isar.clear();
      });

      // 2. Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 3. Clear cache directory (crash logs, temp files)
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }
      
      // 4. Clear app document directory (backups, csvs)
      final docDir = await getApplicationDocumentsDirectory();
      if (docDir.existsSync()) {
        for (var file in docDir.listSync()) {
          if (file is File) {
            file.deleteSync();
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
