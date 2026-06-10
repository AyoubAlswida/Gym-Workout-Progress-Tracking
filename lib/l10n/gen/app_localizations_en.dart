// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Gym Tracker';

  @override
  String get navHome => 'Home';

  @override
  String get navRoutines => 'Routines';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navProfile => 'Profile';

  @override
  String get helloAthlete => 'Hello, Athlete!';

  @override
  String get workoutsThisWeek => 'Workouts This Week';

  @override
  String get latestWeight => 'Latest Weight';

  @override
  String get streak => 'Streak';

  @override
  String weekStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-week streak',
      one: '1-week streak',
      zero: 'No streak yet',
    );
    return '$_temp0';
  }

  @override
  String get startNewWorkout => 'START NEW WORKOUT';

  @override
  String get quickWorkout => 'Quick Workout';

  @override
  String get workout => 'Workout';

  @override
  String restLabel(int seconds) {
    return 'Rest: ${seconds}s';
  }

  @override
  String setNumber(int number) {
    return 'Set $number';
  }

  @override
  String setSummary(String weight, String unit, int reps) {
    return '$weight $unit x $reps reps';
  }

  @override
  String get weight => 'Weight';

  @override
  String get reps => 'Reps';

  @override
  String get addExercise => 'Add Exercise';

  @override
  String get finishWorkout => 'Finish Workout';

  @override
  String get sessionNotes => 'Session Notes';

  @override
  String get sessionNotesHint => 'How did the workout feel?';

  @override
  String lastTime(String weight, String unit, int reps) {
    return 'Last time: $weight $unit x $reps';
  }

  @override
  String newPr(String exercise, String weight, String unit) {
    return 'New PR! $exercise: $weight $unit';
  }

  @override
  String get kg => 'kg';

  @override
  String get lbs => 'lbs';

  @override
  String get kmUnit => 'km';

  @override
  String get miUnit => 'mi';

  @override
  String get durationMinutesField => 'Duration (min)';

  @override
  String distanceField(String unit) {
    return 'Distance ($unit)';
  }

  @override
  String lastTimeGeneric(String value) {
    return 'Last time: $value';
  }

  @override
  String get newRoutine => 'New Routine';

  @override
  String get editRoutine => 'Edit Routine';

  @override
  String get routineName => 'Routine Name';

  @override
  String get deleteRoutine => 'Delete Routine';

  @override
  String deleteRoutineConfirm(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String exercisesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
      zero: 'No exercises',
    );
    return '$_temp0';
  }

  @override
  String targetSetsReps(int sets, int reps) {
    return '$sets x $reps';
  }

  @override
  String get presetBadge => 'Preset';

  @override
  String get noRoutinesYet => 'No routines yet. Tap + to create one.';

  @override
  String get routineNeedsNameAndExercise =>
      'Add a name and at least one exercise.';

  @override
  String get exerciseLibrary => 'Exercise Library';

  @override
  String get searchExercises => 'Search exercises...';

  @override
  String get allMuscleGroups => 'All';

  @override
  String get newExercise => 'New Exercise';

  @override
  String get editExercise => 'Edit Exercise';

  @override
  String get exerciseName => 'Exercise Name';

  @override
  String get category => 'Category';

  @override
  String get muscleGroup => 'Muscle Group';

  @override
  String get equipment => 'Equipment';

  @override
  String get customBadge => 'Custom';

  @override
  String get deleteExercise => 'Delete Exercise';

  @override
  String deleteExerciseConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get exerciseInUse =>
      'This exercise is used in workouts or routines and cannot be deleted.';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get noExercisesFound => 'No exercises found';

  @override
  String get strengthProgress => 'Strength Progress';

  @override
  String get maxWeight => 'Max Weight';

  @override
  String get estimated1Rm => 'Est. 1RM';

  @override
  String get weeklyVolume => 'Weekly Volume';

  @override
  String get bodyWeightChart => 'Body Weight';

  @override
  String get bodyTrends => 'Body Trends';

  @override
  String get personalRecords => 'Personal Records';

  @override
  String get measurementHistory => 'Measurement History';

  @override
  String get noDataYet => 'No data yet';

  @override
  String weightEntry(String weight, String unit) {
    return 'Weight: $weight $unit';
  }

  @override
  String bodyFatEntry(String percent) {
    return 'Body Fat: $percent%';
  }

  @override
  String get settingsProfile => 'Settings & Profile';

  @override
  String get athlete => 'Athlete';

  @override
  String get measurementUnit => 'Measurement Unit';

  @override
  String get metricUnits => 'Metric (KG/CM)';

  @override
  String get imperialUnits => 'Imperial (LBS/IN)';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get restTimerDuration => 'Rest Timer';

  @override
  String secondsValue(int seconds) {
    return '${seconds}s';
  }

  @override
  String get logNewMeasurement => 'Log New Measurement';

  @override
  String get bodyWeightField => 'Body Weight';

  @override
  String get bodyFatField => 'Body Fat %';

  @override
  String get moreMeasurements => 'More measurements';

  @override
  String get waistField => 'Waist';

  @override
  String get chestField => 'Chest';

  @override
  String get armsField => 'Arms';

  @override
  String get hipsField => 'Hips';

  @override
  String get thighsField => 'Thighs';

  @override
  String get cmUnit => 'cm';

  @override
  String get inUnit => 'in';

  @override
  String get measurementLogged => 'Measurement logged!';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get account => 'Account';

  @override
  String get cloudSync => 'Cloud Sync';

  @override
  String get signIn => 'Sign In';

  @override
  String get register => 'Register';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signOut => 'Sign Out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get loginScreenTitle => 'Sign in to sync';

  @override
  String get haveAccountSignIn => 'Already have an account? Sign in';

  @override
  String get noAccountRegister => 'No account? Create one';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncing => 'Syncing…';

  @override
  String lastSynced(String time) {
    return 'Last synced: $time';
  }

  @override
  String get neverSynced => 'Not synced yet';

  @override
  String get syncError => 'Sync failed';

  @override
  String signedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get reminders => 'Workout Reminders';

  @override
  String get remindersEnabled => 'Enable reminders';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get reminderDays => 'Reminder days';

  @override
  String get reminderTitle => 'Time to train!';

  @override
  String get reminderBody => 'Your workout is waiting. Let\'s go!';

  @override
  String get progressPhotos => 'Progress Photos';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get chooseFile => 'Choose File';

  @override
  String get photoNoteHint => 'Note (optional)';

  @override
  String get deletePhoto => 'Delete Photo';

  @override
  String get deletePhotoConfirm => 'Delete this photo?';

  @override
  String get noPhotosYet => 'No progress photos yet. Tap + to add one.';

  @override
  String get dataSection => 'Data';

  @override
  String get exportCsv => 'Export workout history (CSV)';

  @override
  String get exportJson => 'Export full backup (JSON)';

  @override
  String get restoreBackup => 'Restore from backup';

  @override
  String get restoreWarningTitle => 'Replace all data?';

  @override
  String get restoreWarningBody =>
      'Restoring a backup deletes ALL current data and replaces it with the backup contents. Progress photo files are not included in backups. This cannot be undone.';

  @override
  String get restore => 'Restore';

  @override
  String get exportSuccess => 'Exported successfully';

  @override
  String get restoreSuccess => 'Backup restored';

  @override
  String get importInvalidFile => 'This file is not a valid backup';

  @override
  String get importNewerVersion =>
      'This backup was made by a newer app version';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get catChest => 'Chest';

  @override
  String get catBack => 'Back';

  @override
  String get catLegs => 'Legs';

  @override
  String get catShoulders => 'Shoulders';

  @override
  String get catArms => 'Arms';

  @override
  String get catCore => 'Core';

  @override
  String get catCardio => 'Cardio';

  @override
  String get catOther => 'Other';

  @override
  String get muscleChest => 'Chest';

  @override
  String get muscleBack => 'Back';

  @override
  String get muscleQuads => 'Quads';

  @override
  String get muscleHamstrings => 'Hamstrings';

  @override
  String get muscleGlutes => 'Glutes';

  @override
  String get muscleCalves => 'Calves';

  @override
  String get muscleShoulders => 'Shoulders';

  @override
  String get muscleTraps => 'Traps';

  @override
  String get muscleBiceps => 'Biceps';

  @override
  String get muscleTriceps => 'Triceps';

  @override
  String get muscleCore => 'Core';

  @override
  String get muscleOther => 'Other';

  @override
  String get equipBarbell => 'Barbell';

  @override
  String get equipDumbbell => 'Dumbbell';

  @override
  String get equipCable => 'Cable';

  @override
  String get equipMachine => 'Machine';

  @override
  String get equipBodyweight => 'Bodyweight';

  @override
  String get equipOther => 'Other';

  @override
  String get routinePushDay => 'Push Day';

  @override
  String get routinePullDay => 'Pull Day';

  @override
  String get routineLegs => 'Legs';

  @override
  String get routineFullBody => 'Full Body';
}
