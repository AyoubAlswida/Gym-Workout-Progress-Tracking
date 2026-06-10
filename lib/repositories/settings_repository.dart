import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _keyIsMetric = 'isMetric';
  static const _keyRestTimerSeconds = 'restTimerSeconds';
  static const _keyLocaleCode = 'localeCode';
  static const _keyThemeMode = 'themeMode';
  static const _keyRemindersEnabled = 'remindersEnabled';
  static const _keyReminderDays = 'reminderDays';
  static const _keyReminderTime = 'reminderTime';
  static const _keyTrainingGoal = 'trainingGoal';

  Future<bool> getIsMetric() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsMetric) ?? true;
  }

  Future<void> setIsMetric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsMetric, value);
  }

  Future<int> getRestTimerSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyRestTimerSeconds) ?? 60;
  }

  Future<void> setRestTimerSeconds(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRestTimerSeconds, value);
  }

  Future<String> getLocaleCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLocaleCode) ?? 'en';
  }

  Future<void> setLocaleCode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocaleCode, value);
  }

  /// One of 'system', 'light', 'dark'.
  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode) ?? 'system';
  }

  Future<void> setThemeMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, value);
  }

  Future<bool> getRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRemindersEnabled) ?? false;
  }

  Future<void> setRemindersEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRemindersEnabled, value);
  }

  /// ISO weekday numbers (1=Mon..7=Sun) as a comma-separated string.
  Future<String> getReminderDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyReminderDays) ?? '1,3,5';
  }

  Future<void> setReminderDays(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyReminderDays, value);
  }

  /// Time of day as 'HH:mm' (24-hour).
  Future<String> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyReminderTime) ?? '18:00';
  }

  Future<void> setReminderTime(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyReminderTime, value);
  }

  /// One of 'strength', 'hypertrophy', 'endurance'.
  Future<String> getTrainingGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTrainingGoal) ?? 'hypertrophy';
  }

  Future<void> setTrainingGoal(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTrainingGoal, value);
  }
}
