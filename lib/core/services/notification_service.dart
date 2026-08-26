import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Phase 24: Local Scheduled Notifications
///
/// This service handles on-device reminders without a server.
/// It uses the 'flutter_local_notifications' package to schedule
/// triggers for recurring bills or budget alerts.
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings();

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          // Handle notification tap
        },
      );
    } catch (_) {
      // Gracefully handle environments without native notifications (e.g., desktop/test)
    }
  }

  Future<void> showInstantNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'wallet_channel',
      'Wallet Notifications',
      channelDescription: 'Financial reminders and alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledDate) async {
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'wallet_scheduled_channel',
          'Scheduled Reminders',
          importance: Importance.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleRecurringBillNotification({
    required int id,
    required String name,
    required String frequencyName,
    required DateTime nextDate,
    required bool notifyOneDayBefore,
  }) async {
    const title = 'Bill Due';
    final body = 'Your $frequencyName payment for $name is due';

    DateTime scheduledDate;
    if (notifyOneDayBefore) {
      final dayBefore = nextDate.subtract(const Duration(days: 1));
      scheduledDate =
          DateTime(dayBefore.year, dayBefore.month, dayBefore.day, 9, 0);
    } else {
      scheduledDate =
          DateTime(nextDate.year, nextDate.month, nextDate.day, 9, 0);
    }

    try {
      await cancelNotification(id);
    } catch (_) {}

    final now = DateTime.now();
    if (scheduledDate.isAfter(now)) {
      try {
        await scheduleNotification(id, title, body, scheduledDate);
      } catch (_) {}
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
