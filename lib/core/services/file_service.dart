import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileService {
  static Future<String> saveImagePermanently(String tempPath) async {
    // [ACTION]: Get the application documents directory for permanent storage.
    // [RATIONALE]: Files in the temporary directory can be deleted by the OS at any time.
    final directory = await getApplicationDocumentsDirectory();
    
    // [ACTION]: Create a unique filename to avoid collisions and preserve the extension.
    final String extension = p.extension(tempPath);
    final String fileName = 'profile_photo_${DateTime.now().millisecondsSinceEpoch}$extension';
    final permanentPath = p.join(directory.path, fileName);
    
    final tempFile = File(tempPath);
    if (await tempFile.exists()) {
      final permanentFile = await tempFile.copy(permanentPath);
      return permanentFile.path;
    }
    
    return tempPath;
  }
}
