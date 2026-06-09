import 'package:flutter/material.dart';
import '../repositories/settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository;

  SettingsViewModel({SettingsRepository? repository})
      : _repository = repository ?? SettingsRepository();

  bool _isMetric = true; // true = KG, false = LBS
  bool get isMetric => _isMetric;

  int _restTimerSeconds = 60;
  int get restTimerSeconds => _restTimerSeconds;

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  Future<void> load() async {
    _isMetric = await _repository.getIsMetric();
    _restTimerSeconds = await _repository.getRestTimerSeconds();
    _locale = Locale(await _repository.getLocaleCode());
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
}
