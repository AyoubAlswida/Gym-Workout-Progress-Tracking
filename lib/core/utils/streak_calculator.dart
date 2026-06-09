/// Number of consecutive calendar weeks (Mon–Sun), ending at the current
/// week, that each contain at least one workout.
///
/// Grace rule: a current week with no workout yet does not break the streak —
/// it only breaks once a full week passes with zero workouts.
int computeWeeklyStreak(List<DateTime> sessionDates, DateTime now) {
  if (sessionDates.isEmpty) return 0;

  DateTime weekStartOf(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  final trainedWeeks = sessionDates.map(weekStartOf).toSet();
  final currentWeek = weekStartOf(now);

  // Start counting from this week if trained, otherwise from last week
  // (the grace week). A gap of two or more weeks means no active streak.
  var week = trainedWeeks.contains(currentWeek)
      ? currentWeek
      : currentWeek.subtract(const Duration(days: 7));

  var streak = 0;
  while (trainedWeeks.contains(week)) {
    streak++;
    week = week.subtract(const Duration(days: 7));
  }
  return streak;
}
