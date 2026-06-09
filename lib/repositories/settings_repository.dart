import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _keyIsMetric = 'isMetric';
  static const _keyRestTimerSeconds = 'restTimerSeconds';
  static const _keyLocaleCode = 'localeCode';

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
}
