import 'package:flutter_test/flutter_test.dart';
import 'package:gym_workout_tracking/core/utils/streak_calculator.dart';

void main() {
  // Wednesday 2026-06-10; its week starts Monday 2026-06-08.
  final now = DateTime(2026, 6, 10, 14);

  DateTime weeksAgo(int weeks, [int dayOffset = 0]) =>
      DateTime(2026, 6, 8).subtract(Duration(days: 7 * weeks - dayOffset));

  group('computeWeeklyStreak', () {
    test('no sessions means no streak', () {
      expect(computeWeeklyStreak([], now), 0);
    });

    test('workout this week counts as 1', () {
      expect(computeWeeklyStreak([DateTime(2026, 6, 9)], now), 1);
    });

    test('three consecutive weeks count as 3', () {
      final dates = [weeksAgo(0), weeksAgo(1, 3), weeksAgo(2, 5)];
      expect(computeWeeklyStreak(dates, now), 3);
    });

    test('a gap week breaks the streak', () {
      // Trained this week and 2 weeks ago, but not last week.
      final dates = [weeksAgo(0), weeksAgo(2)];
      expect(computeWeeklyStreak(dates, now), 1);
    });

    test('empty current week keeps last week\'s streak alive', () {
      // No workout yet this week; trained the previous 2 weeks.
      final dates = [weeksAgo(1), weeksAgo(2)];
      expect(computeWeeklyStreak(dates, now), 2);
    });

    test('two empty weeks end the streak', () {
      final dates = [weeksAgo(2), weeksAgo(3)];
      expect(computeWeeklyStreak(dates, now), 0);
    });

    test('multiple workouts in one week count once', () {
      final dates = [
        DateTime(2026, 6, 8),
        DateTime(2026, 6, 9),
        DateTime(2026, 6, 10),
      ];
      expect(computeWeeklyStreak(dates, now), 1);
    });

    test('streak spans a year boundary', () {
      // Weeks starting 2025-12-22, 2025-12-29, 2026-01-05.
      final yearNow = DateTime(2026, 1, 7);
      final dates = [
        DateTime(2025, 12, 24),
        DateTime(2026, 1, 2),
        DateTime(2026, 1, 6),
      ];
      expect(computeWeeklyStreak(dates, yearNow), 3);
    });
  });
}
