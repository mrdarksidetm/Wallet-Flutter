import 'package:flutter_riverpod/flutter_riverpod.dart';

final greetingServiceProvider = Provider<GreetingService>((ref) {
  return GreetingService();
});

class GreetingService {
  String getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    final day = now.weekday; // 1 = Monday, 7 = Sunday
    final dayOfMonth = now.day;
    final month = now.month;

    // 1. Festivals & Holidays (Fixed Dates for simplicity, can be dynamic later)
    if (month == 1 && dayOfMonth == 1)
      return "Happy New Year! 🎉 Start strong.";
    if (month == 1 && dayOfMonth == 26) return "Happy Republic Day! 🇮🇳";
    if (month == 8 && dayOfMonth == 15) return "Happy Independence Day! 🇮🇳";
    if (month == 10 && dayOfMonth == 2) return "Gandhi Jayanti 🙏";
    if (month == 12 && dayOfMonth == 25) return "Merry Christmas! 🎄";

    // 2. Month End / Start
    if (dayOfMonth == 1) return "New month, new goals. 🚀";
    if (dayOfMonth >= 28) return "Month end is here. Time to review? 🧐";

    // 3. Time of Day
    if (hour < 12) {
      if (day == 1) return "Good morning ☀️ Let's start the week right!";
      if (day >= 6) return "Happy Weekend! ☕ Relax and track.";
      return "Good morning ☀️ Smart choices today.";
    } else if (hour < 17) {
      return "Good afternoon 🌤️ How's your spending?";
    } else if (hour < 21) {
      if (day == 5) return "Friday night! 🥂 Enjoy responsibly.";
      return "Good evening 🌙 Track your day's expenses.";
    } else {
      return "Late night hustle? 🦉 Rest well.";
    }
  }
}
