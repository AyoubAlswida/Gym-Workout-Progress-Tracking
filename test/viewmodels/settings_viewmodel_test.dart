import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_workout_tracking/viewmodels/settings_viewmodel.dart';

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
}
