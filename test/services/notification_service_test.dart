import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_workout_tracking/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  late tz.Location location;

  setUpAll(() {
    tz.initializeTimeZones();
    location = tz.getLocation('UTC');
  });

  group('NotificationService.nextInstanceOf', () {
    test('returns later today when the time has not passed', () {
      // Wednesday 2026-06-10 08:00; reminder same weekday at 18:00.
      final now = tz.TZDateTime(location, 2026, 6, 10, 8);
      final next = NotificationService.nextInstanceOf(
          DateTime.wednesday, const TimeOfDay(hour: 18, minute: 0), now);

      expect(next.weekday, DateTime.wednesday);
      expect(next.day, 10);
      expect(next.hour, 18);
    });

    test('rolls to next week when today\'s time already passed', () {
      // Wednesday 20:00; reminder Wednesday 18:00 should be 7 days later.
      final now = tz.TZDateTime(location, 2026, 6, 10, 20);
      final next = NotificationService.nextInstanceOf(
          DateTime.wednesday, const TimeOfDay(hour: 18, minute: 0), now);

      expect(next.weekday, DateTime.wednesday);
      expect(next.day, 17);
    });

    test('finds the upcoming weekday within the same week', () {
      // Wednesday; next Friday reminder is 2 days out.
      final now = tz.TZDateTime(location, 2026, 6, 10, 12);
      final next = NotificationService.nextInstanceOf(
          DateTime.friday, const TimeOfDay(hour: 7, minute: 30), now);

      expect(next.weekday, DateTime.friday);
      expect(next.day, 12);
      expect(next.hour, 7);
      expect(next.minute, 30);
    });

    test('wraps to the following week for an earlier weekday', () {
      // Wednesday; Monday reminder is 5 days out.
      final now = tz.TZDateTime(location, 2026, 6, 10, 12);
      final next = NotificationService.nextInstanceOf(
          DateTime.monday, const TimeOfDay(hour: 9, minute: 0), now);

      expect(next.weekday, DateTime.monday);
      expect(next.day, 15);
    });
  });
}
