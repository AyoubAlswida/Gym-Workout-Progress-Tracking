import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'viewmodels/workout_viewmodel.dart';
import 'viewmodels/session_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'views/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GymTrackerApp());
}

class GymTrackerApp extends StatelessWidget {
  const GymTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkoutViewModel()..loadSessions()),
        ChangeNotifierProvider(create: (_) => SessionViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()..loadMeasurements()),
      ],
      child: MaterialApp(
        title: 'Gym Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainNavigation(),
      ),
    );
  }
}
