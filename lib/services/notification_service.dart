import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Schedules weekly workout reminders. Android-only in this phase; on every
/// other platform [isSupported] is false and all methods are no-ops, so the
/// app still builds and the reminder UI is simply hidden.
class NotificationService {
  static const int _firstId = 1;
  static const String _channelId = 'workout_reminders';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  Future<void> init() async {
    if (!isSupported || _initialized) return;
    tz.initializeTimeZones();
    final localName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localName));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  /// Replaces any existing reminders with one per selected ISO weekday
  /// (1=Mon..7=Sun) at [time]. Inexact scheduling avoids the Android 12+
  /// exact-alarm permission — minute precision isn't needed here.
  Future<void> scheduleWeekly({
    required Set<int> weekdays,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    if (!isSupported) return;
    await init();
    await cancelAll();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Workout Reminders',
        channelDescription: 'Weekly workout reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    for (final weekday in weekdays) {
      await _plugin.zonedSchedule(
        _firstId + weekday,
        title,
        body,
        nextInstanceOf(weekday, time, tz.TZDateTime.now(tz.local)),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancelAll() async {
    if (!isSupported) return;
    await _plugin.cancelAll();
  }

  /// Next occurrence of [weekday] (1=Mon..7=Sun) at [time], at or after [now].
  /// Pure and [now]-injected so it can be unit-tested without a device.
  static tz.TZDateTime nextInstanceOf(
      int weekday, TimeOfDay time, tz.TZDateTime now) {
    var scheduled = tz.TZDateTime(
        now.location, now.year, now.month, now.day, time.hour, time.minute);
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
