import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import 'config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'l10n/gen/app_localizations.dart';
import 'services/auth_api.dart';
import 'services/notification_service.dart';
import 'services/prefs_watermark_store.dart';
import 'services/supabase_auth_service.dart';
import 'services/supabase_remote_data_source.dart';
import 'services/sync_service.dart';
import 'viewmodels/analytics_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/exercise_viewmodel.dart';
import 'viewmodels/photo_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/routine_viewmodel.dart';
import 'viewmodels/session_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/sync_viewmodel.dart';
import 'viewmodels/workout_viewmodel.dart';
import 'views/main_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // sqflite has no native implementation on desktop; route through FFI.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // No-op on unsupported platforms; safe to await unconditionally.
  await NotificationService().init();
  // Cloud sync is optional: only initialize when configured.
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      // The anon key is Supabase's current publishable key.
      publishableKey: SupabaseConfig.anonKey,
    );
  }
  runApp(const GymTrackerApp());
}

class GymTrackerApp extends StatefulWidget {
  const GymTrackerApp({super.key});

  @override
  State<GymTrackerApp> createState() => _GymTrackerAppState();
}

class _GymTrackerAppState extends State<GymTrackerApp>
    with WidgetsBindingObserver {
  late final AuthViewModel _authVM;
  late final SyncViewModel _syncVM;

  @override
  void initState() {
    super.initState();
    final authApi =
        SupabaseConfig.isConfigured ? SupabaseAuthService() : OfflineAuthApi();
    _syncVM = SyncViewModel(runSync: _runSync, canSync: _canSync);
    _authVM = AuthViewModel(auth: authApi, onSignedIn: _syncVM.syncNow);
    WidgetsBinding.instance.addObserver(this);
  }

  bool _canSync() => SupabaseConfig.isConfigured && _authVM.isSignedIn;

  Future<void> _runSync() async {
    final user = _authVM.user;
    if (user == null) return;
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;
    final sync = SyncService(
      userId: user.id,
      remote: SupabaseRemoteDataSource(userId: user.id),
      watermarks: PrefsWatermarkStore(),
    );
    await sync.sync();
    // Refresh viewmodels so pulled data shows immediately.
    if (!mounted) return;
    await context.read<WorkoutViewModel>().loadSessions();
    if (!mounted) return;
    await context.read<ExerciseViewModel>().loadExercises();
    if (!mounted) return;
    await context.read<RoutineViewModel>().loadRoutines();
    if (!mounted) return;
    await context.read<ProfileViewModel>().loadMeasurements();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncVM.syncNow();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authVM.dispose();
    super.dispose();
  }

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
        ChangeNotifierProvider(create: (_) => PhotoViewModel()),
        ChangeNotifierProvider<AuthViewModel>.value(value: _authVM),
        ChangeNotifierProvider<SyncViewModel>.value(value: _syncVM),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, _) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
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
