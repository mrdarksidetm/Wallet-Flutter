import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';

class AppUpdate {
  final String version;
  final String changelog;
  final String downloadUrl;
  final DateTime publishedAt;

  AppUpdate({
    required this.version,
    required this.changelog,
    required this.downloadUrl,
    required this.publishedAt,
  });

  factory AppUpdate.fromJson(Map<String, dynamic> json, String architecture) {
    try {
      final assets = json['assets'] as List;
      String downloadUrl = json['html_url'];

      if (assets.isNotEmpty) {
        // If the current build is universal, we prefer the universal APK
        if (architecture == 'universal') {
          final universal = assets.where((asset) {
            final name = asset['name'].toString().toLowerCase();
            return name.endsWith('.apk') && name.contains('universal');
          });
          if (universal.isNotEmpty) {
            return AppUpdate(
              version: json['tag_name'].toString().replaceAll('v', ''),
              changelog: json['body'] ?? 'No changelog provided.',
              downloadUrl: universal.first['browser_download_url'],
              publishedAt: DateTime.parse(json['published_at']),
            );
          }
        }

        // 1. Try to find APK matching exact architecture
        final archSpecific = assets.where((asset) {
          final name = asset['name'].toString().toLowerCase();
          if (!name.endsWith('.apk')) return false;

          if (architecture == 'arm64-v8a') {
            return name.contains('arm64-v8a') || name.contains('arm64-8a');
          }
          if (architecture == 'armeabi-v7a') {
            return name.contains('armeabi-v7a') || name.contains('arm-v7a');
          }
          return name.contains(architecture.toLowerCase());
        });

        if (archSpecific.isNotEmpty) {
          downloadUrl = archSpecific.first['browser_download_url'];
        } else {
          // 2. Fallback to 'universal'
          final universal = assets.where((asset) {
            final name = asset['name'].toString().toLowerCase();
            return name.endsWith('.apk') && name.contains('universal');
          });

          if (universal.isNotEmpty) {
            downloadUrl = universal.first['browser_download_url'];
          } else {
            // 3. Last resort: any APK
            final anyApk = assets
                .where((asset) => asset['name'].toString().endsWith('.apk'));
            if (anyApk.isNotEmpty) {
              downloadUrl = anyApk.first['browser_download_url'];
            }
          }
        }
      }

      return AppUpdate(
        version: json['tag_name'].toString().replaceAll('v', ''),
        changelog: json['body'] ?? 'No changelog provided.',
        downloadUrl: downloadUrl,
        publishedAt: DateTime.parse(json['published_at']),
      );
    } catch (e) {
      // Return a dummy update object if parsing fails to avoid crash
      return AppUpdate(
        version: '0.0.0',
        changelog: 'Error parsing update info.',
        downloadUrl: '',
        publishedAt: DateTime.now(),
      );
    }
  }
}

class UpdateService {
  final String repoUrl =
      'https://api.github.com/repos/mrdarksidetm/Wallet-Flutter/releases/latest';
  final Dio _dio = Dio();
  static const _platform = MethodChannel('com.mrdarksidetm.wallet/app_info');

  Future<String> getDeviceArchitecture() async {
    if (!Platform.isAndroid) return 'universal';

    try {
      // First, check if the app was installed as a universal (fat) APK
      final bool isUniversal = await _platform.invokeMethod('isUniversalBuild') ?? false;
      if (isUniversal) return 'universal';

      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final abis = androidInfo.supportedAbis;

      if (abis.contains('arm64-v8a')) return 'arm64-v8a';
      if (abis.contains('armeabi-v7a')) return 'armeabi-v7a';
      if (abis.contains('x86_64')) return 'x86_64';
    } catch (_) {}

    return 'universal';
  }

  Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<AppUpdate?> checkForUpdates() async {
    try {
      final architecture = await getDeviceArchitecture();
      final response = await _dio.get(repoUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        return AppUpdate.fromJson(data, architecture);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  bool isNewerVersion(String currentVersion, String latestVersion) {
    try {
      final current = currentVersion.split('.').map(int.parse).toList();
      final latest = latestVersion.split('.').map(int.parse).toList();

      for (var i = 0; i < latest.length; i++) {
        if (i >= current.length) return true;
        if (latest[i] > current[i]) return true;
        if (latest[i] < current[i]) return false;
      }
    } catch (_) {
      return latestVersion != currentVersion;
    }
    return false;
  }

  Stream<OtaEvent> downloadAndInstall(String url) {
    return OtaUpdate().execute(
      url,
      destinationFilename: 'wallet_update.apk',
    );
  }
}

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});
