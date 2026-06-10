import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_workout_tracking/services/notification_service.dart';
import 'package:gym_workout_tracking/viewmodels/settings_viewmodel.dart';

/// Records scheduling calls instead of touching platform channels.
class _FakeNotificationService extends NotificationService {
  int scheduleCount = 0;
  int cancelCount = 0;
  Set<int>? lastDays;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleWeekly({
    required Set<int> weekdays,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    scheduleCount++;
    lastDays = weekdays;
  }

  @override
  Future<void> cancelAll() async {
    cancelCount++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsViewModel themeMode', () {
    test('defaults to system when nothing stored', () async {
      SharedPreferences.setMockInitialValues({});
      final vm = SettingsViewModel();
      await vm.load();
      expect(vm.themeMode, ThemeMode.system);
    });

    test('persists and restores dark mode', () async {
      SharedPreferences.setMockInitialValues({});
      final vm = SettingsViewModel();
      await vm.load();
      await vm.setThemeMode(ThemeMode.dark);
      expect(vm.themeMode, ThemeMode.dark);

      // A fresh viewmodel reads the persisted value.
      final vm2 = SettingsViewModel();
      await vm2.load();
      expect(vm2.themeMode, ThemeMode.dark);
    });

    test('restores light mode from stored string', () async {
      SharedPreferences.setMockInitialValues({'themeMode': 'light'});
      final vm = SettingsViewModel();
      await vm.load();
      expect(vm.themeMode, ThemeMode.light);
    });

    test('falls back to system on unknown stored value', () async {
      SharedPreferences.setMockInitialValues({'themeMode': 'sepia'});
      final vm = SettingsViewModel();
      await vm.load();
      expect(vm.themeMode, ThemeMode.system);
    });
  });

  group('SettingsViewModel reminders', () {
    test('defaults: disabled, Mon/Wed/Fri, 18:00', () async {
      SharedPreferences.setMockInitialValues({});
      final vm = SettingsViewModel();
      await vm.load();
      expect(vm.remindersEnabled, isFalse);
      expect(vm.reminderDays, {1, 3, 5});
      expect(vm.reminderTime, const TimeOfDay(hour: 18, minute: 0));
    });

    test('enabling schedules and persists the settings', () async {
      SharedPreferences.setMockInitialValues({});
      final notifications = _FakeNotificationService();
      final vm = SettingsViewModel(notificationService: notifications);
      await vm.load();

      await vm.setReminders(
        enabled: true,
        days: {2, 4},
        time: const TimeOfDay(hour: 7, minute: 30),
        title: 'x',
        body: 'y',
      );

      expect(notifications.scheduleCount, 1);
      expect(notifications.lastDays, {2, 4});

      // A fresh viewmodel restores the persisted values.
      final vm2 = SettingsViewModel(notificationService: notifications);
      await vm2.load();
      expect(vm2.remindersEnabled, isTrue);
      expect(vm2.reminderDays, {2, 4});
      expect(vm2.reminderTime, const TimeOfDay(hour: 7, minute: 30));
    });

    test('disabling cancels all notifications', () async {
      SharedPreferences.setMockInitialValues({});
      final notifications = _FakeNotificationService();
      final vm = SettingsViewModel(notificationService: notifications);
      await vm.load();

      await vm.setReminders(
        enabled: false,
        days: {1, 3, 5},
        time: const TimeOfDay(hour: 18, minute: 0),
        title: 'x',
        body: 'y',
      );

      expect(notifications.cancelCount, 1);
      expect(notifications.scheduleCount, 0);
    });
  });
}
