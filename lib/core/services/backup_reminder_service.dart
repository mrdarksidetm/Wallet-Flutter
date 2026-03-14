/// Phase 50: In-App Backup Reminders & TTL
///
/// Evaluates the time elapsed since the last backup was taken.
/// If more than 14 days have passed, this flags the UI to display a reminder banner.
class BackupReminderService {
  static const int _backupTtlDays = 14;

  static bool shouldShowBackupReminder(int lastBackupTimestampMillis) {
    if (lastBackupTimestampMillis == 0) return true; // Never backed up

    final lastBackupDate = DateTime.fromMillisecondsSinceEpoch(lastBackupTimestampMillis);
    final currentDate = DateTime.now();
    
    final diffInDays = currentDate.difference(lastBackupDate).inDays;
    
    return diffInDays >= _backupTtlDays;
  }
}
