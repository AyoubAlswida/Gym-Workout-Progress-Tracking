import 'package:flutter/material.dart';
import '../repositories/settings_repository.dart';
import '../services/notification_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository;
  final NotificationService _notificationService;

  SettingsViewModel({
    SettingsRepository? repository,
    NotificationService? notificationService,
  })  : _repository = repository ?? SettingsRepository(),
        _notificationService =
            notificationService ?? NotificationService();

  bool _isMetric = true; // true = KG, false = LBS
  bool get isMetric => _isMetric;

  int _restTimerSeconds = 60;
  int get restTimerSeconds => _restTimerSeconds;

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool _remindersEnabled = false;
  bool get remindersEnabled => _remindersEnabled;

  /// ISO weekday numbers (1=Mon..7=Sun).
  Set<int> _reminderDays = {1, 3, 5};
  Set<int> get reminderDays => _reminderDays;

  TimeOfDay _reminderTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay get reminderTime => _reminderTime;

  bool get remindersSupported => NotificationService.isSupported;

  Future<void> load() async {
    _isMetric = await _repository.getIsMetric();
    _restTimerSeconds = await _repository.getRestTimerSeconds();
    _locale = Locale(await _repository.getLocaleCode());
    _themeMode = _themeModeFromString(await _repository.getThemeMode());
    _remindersEnabled = await _repository.getRemindersEnabled();
    _reminderDays = _parseDays(await _repository.getReminderDays());
    _reminderTime = _parseTime(await _repository.getReminderTime());
    notifyListeners();
  }

  Future<void> toggleUnits() async {
    _isMetric = !_isMetric;
    notifyListeners();
    await _repository.setIsMetric(_isMetric);
  }

  Future<void> setRestTimerSeconds(int seconds) async {
    _restTimerSeconds = seconds;
    notifyListeners();
    await _repository.setRestTimerSeconds(seconds);
  }

  Future<void> setLocale(String code) async {
    _locale = Locale(code);
    notifyListeners();
    await _repository.setLocaleCode(code);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _repository.setThemeMode(_themeModeToString(mode));
  }

  /// Persists reminder settings, then (re)schedules or cancels notifications.
  Future<void> setReminders({
    required bool enabled,
    required Set<int> days,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    _remindersEnabled = enabled;
    _reminderDays = days;
    _reminderTime = time;
    notifyListeners();

    await _repository.setRemindersEnabled(enabled);
    await _repository.setReminderDays(_formatDays(days));
    await _repository.setReminderTime(_formatTime(time));

    if (enabled && days.isNotEmpty) {
      await _notificationService.requestPermission();
      await _notificationService.scheduleWeekly(
        weekdays: days,
        time: time,
        title: title,
        body: body,
      );
    } else {
      await _notificationService.cancelAll();
    }
  }

  static Set<int> _parseDays(String value) {
    if (value.trim().isEmpty) return {};
    return value
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .where((d) => d >= 1 && d <= 7)
        .toSet();
  }

  static String _formatDays(Set<int> days) {
    final sorted = days.toList()..sort();
    return sorted.join(',');
  }

  static TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.first) ?? 18;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
