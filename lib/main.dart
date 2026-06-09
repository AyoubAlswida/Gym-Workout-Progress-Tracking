import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/theme/app_theme.dart';
import 'l10n/gen/app_localizations.dart';
import 'viewmodels/analytics_viewmodel.dart';
import 'viewmodels/exercise_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/routine_viewmodel.dart';
import 'viewmodels/session_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/workout_viewmodel.dart';
import 'views/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // sqflite has no native implementation on desktop; route through FFI.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const GymTrackerApp());
}

class GymTrackerApp extends StatelessWidget {
  const GymTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsViewModel()..load()),
        ChangeNotifierProvider(create: (_) => WorkoutViewModel()..loadSessions()),
        ChangeNotifierProvider(create: (_) => SessionViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()..loadMeasurements()),
        ChangeNotifierProvider(create: (_) => ExerciseViewModel()..loadExercises()),
        ChangeNotifierProvider(create: (_) => RoutineViewModel()..loadRoutines()),
        ChangeNotifierProvider(create: (_) => AnalyticsViewModel()),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, _) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: settings.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MainNavigation(),
          );
        },
      ),
    );
  }
}
