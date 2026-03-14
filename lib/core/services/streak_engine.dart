/// Phase 19: Gamification & Financial Streaks
///
/// CRITICAL: Efficient Streak Calculation
/// Instead of querying thousands of transactions every app launch,
/// this engine evaluates the last X dates from a simplified projection.
class StreakEngine {
  /// Takes a list of raw transaction timestamps (ordered descending)
  /// and calculates consecutive active days.
  static int calculateActiveStreak(List<int> sortedTimestampsMillis) {
    if (sortedTimestampsMillis.isEmpty) return 0;

    int currentStreak = 0;
    
    final now = DateTime.now();
    // Normalize current day to midnight
    var targetDay = DateTime(now.year, now.month, now.day);

    for (final timestamp in sortedTimestampsMillis) {
      final txDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      // Normalize transaction day to midnight
      final normalizedTxDay = DateTime(txDate.year, txDate.month, txDate.day);

      if (normalizedTxDay.isAtSameMomentAs(targetDay)) {
        // Match found for this target day
        currentStreak++;
        targetDay = targetDay.subtract(const Duration(days: 1)); // Move target back 1 day
      } else if (normalizedTxDay.isBefore(targetDay)) {
        // Missed a day
        break;
      }
    }
    
    return currentStreak;
  }
}
