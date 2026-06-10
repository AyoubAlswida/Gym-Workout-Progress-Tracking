import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Gym Tracker'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRoutines.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get navRoutines;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @helloAthlete.
  ///
  /// In en, this message translates to:
  /// **'Hello, Athlete!'**
  String get helloAthlete;

  /// No description provided for @workoutsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Workouts This Week'**
  String get workoutsThisWeek;

  /// No description provided for @latestWeight.
  ///
  /// In en, this message translates to:
  /// **'Latest Weight'**
  String get latestWeight;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @weekStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No streak yet} =1{1-week streak} other{{count}-week streak}}'**
  String weekStreak(int count);

  /// No description provided for @startNewWorkout.
  ///
  /// In en, this message translates to:
  /// **'START NEW WORKOUT'**
  String get startNewWorkout;

  /// No description provided for @quickWorkout.
  ///
  /// In en, this message translates to:
  /// **'Quick Workout'**
  String get quickWorkout;

  /// No description provided for @workout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// No description provided for @restLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest: {seconds}s'**
  String restLabel(int seconds);

  /// No description provided for @setNumber.
  ///
  /// In en, this message translates to:
  /// **'Set {number}'**
  String setNumber(int number);

  /// No description provided for @setSummary.
  ///
  /// In en, this message translates to:
  /// **'{weight} {unit} x {reps} reps'**
  String setSummary(String weight, String unit, int reps);

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExercise;

  /// No description provided for @finishWorkout.
  ///
  /// In en, this message translates to:
  /// **'Finish Workout'**
  String get finishWorkout;

  /// No description provided for @sessionNotes.
  ///
  /// In en, this message translates to:
  /// **'Session Notes'**
  String get sessionNotes;

  /// No description provided for @sessionNotesHint.
  ///
  /// In en, this message translates to:
  /// **'How did the workout feel?'**
  String get sessionNotesHint;

  /// No description provided for @lastTime.
  ///
  /// In en, this message translates to:
  /// **'Last time: {weight} {unit} x {reps}'**
  String lastTime(String weight, String unit, int reps);

  /// No description provided for @newPr.
  ///
  /// In en, this message translates to:
  /// **'New PR! {exercise}: {weight} {unit}'**
  String newPr(String exercise, String weight, String unit);

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @lbs.
  ///
  /// In en, this message translates to:
  /// **'lbs'**
  String get lbs;

  /// No description provided for @kmUnit.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get kmUnit;

  /// No description provided for @miUnit.
  ///
  /// In en, this message translates to:
  /// **'mi'**
  String get miUnit;

  /// No description provided for @durationMinutesField.
  ///
  /// In en, this message translates to:
  /// **'Duration (min)'**
  String get durationMinutesField;

  /// No description provided for @distanceField.
  ///
  /// In en, this message translates to:
  /// **'Distance ({unit})'**
  String distanceField(String unit);

  /// No description provided for @lastTimeGeneric.
  ///
  /// In en, this message translates to:
  /// **'Last time: {value}'**
  String lastTimeGeneric(String value);

  /// No description provided for @newRoutine.
  ///
  /// In en, this message translates to:
  /// **'New Routine'**
  String get newRoutine;

  /// No description provided for @editRoutine.
  ///
  /// In en, this message translates to:
  /// **'Edit Routine'**
  String get editRoutine;

  /// No description provided for @routineName.
  ///
  /// In en, this message translates to:
  /// **'Routine Name'**
  String get routineName;

  /// No description provided for @deleteRoutine.
  ///
  /// In en, this message translates to:
  /// **'Delete Routine'**
  String get deleteRoutine;

  /// No description provided for @deleteRoutineConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String deleteRoutineConfirm(String name);

  /// No description provided for @exercisesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No exercises} =1{1 exercise} other{{count} exercises}}'**
  String exercisesCount(int count);

  /// No description provided for @targetSetsReps.
  ///
  /// In en, this message translates to:
  /// **'{sets} x {reps}'**
  String targetSetsReps(int sets, int reps);

  /// No description provided for @presetBadge.
  ///
  /// In en, this message translates to:
  /// **'Preset'**
  String get presetBadge;

  /// No description provided for @noRoutinesYet.
  ///
  /// In en, this message translates to:
  /// **'No routines yet. Tap + to create one.'**
  String get noRoutinesYet;

  /// No description provided for @routineNeedsNameAndExercise.
  ///
  /// In en, this message translates to:
  /// **'Add a name and at least one exercise.'**
  String get routineNeedsNameAndExercise;

  /// No description provided for @exerciseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Exercise Library'**
  String get exerciseLibrary;

  /// No description provided for @searchExercises.
  ///
  /// In en, this message translates to:
  /// **'Search exercises...'**
  String get searchExercises;

  /// No description provided for @allMuscleGroups.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allMuscleGroups;

  /// No description provided for @newExercise.
  ///
  /// In en, this message translates to:
  /// **'New Exercise'**
  String get newExercise;

  /// No description provided for @editExercise.
  ///
  /// In en, this message translates to:
  /// **'Edit Exercise'**
  String get editExercise;

  /// No description provided for @exerciseName.
  ///
  /// In en, this message translates to:
  /// **'Exercise Name'**
  String get exerciseName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @muscleGroup.
  ///
  /// In en, this message translates to:
  /// **'Muscle Group'**
  String get muscleGroup;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// No description provided for @customBadge.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customBadge;

  /// No description provided for @deleteExercise.
  ///
  /// In en, this message translates to:
  /// **'Delete Exercise'**
  String get deleteExercise;

  /// No description provided for @deleteExerciseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteExerciseConfirm(String name);

  /// No description provided for @exerciseInUse.
  ///
  /// In en, this message translates to:
  /// **'This exercise is used in workouts or routines and cannot be deleted.'**
  String get exerciseInUse;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @noExercisesFound.
  ///
  /// In en, this message translates to:
  /// **'No exercises found'**
  String get noExercisesFound;

  /// No description provided for @strengthProgress.
  ///
  /// In en, this message translates to:
  /// **'Strength Progress'**
  String get strengthProgress;

  /// No description provided for @maxWeight.
  ///
  /// In en, this message translates to:
  /// **'Max Weight'**
  String get maxWeight;

  /// No description provided for @estimated1Rm.
  ///
  /// In en, this message translates to:
  /// **'Est. 1RM'**
  String get estimated1Rm;

  /// No description provided for @weeklyVolume.
  ///
  /// In en, this message translates to:
  /// **'Weekly Volume'**
  String get weeklyVolume;

  /// No description provided for @bodyWeightChart.
  ///
  /// In en, this message translates to:
  /// **'Body Weight'**
  String get bodyWeightChart;

  /// No description provided for @bodyTrends.
  ///
  /// In en, this message translates to:
  /// **'Body Trends'**
  String get bodyTrends;

  /// No description provided for @personalRecords.
  ///
  /// In en, this message translates to:
  /// **'Personal Records'**
  String get personalRecords;

  /// No description provided for @measurementHistory.
  ///
  /// In en, this message translates to:
  /// **'Measurement History'**
  String get measurementHistory;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @weightEntry.
  ///
  /// In en, this message translates to:
  /// **'Weight: {weight} {unit}'**
  String weightEntry(String weight, String unit);

  /// No description provided for @bodyFatEntry.
  ///
  /// In en, this message translates to:
  /// **'Body Fat: {percent}%'**
  String bodyFatEntry(String percent);

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Settings & Profile'**
  String get settingsProfile;

  /// No description provided for @athlete.
  ///
  /// In en, this message translates to:
  /// **'Athlete'**
  String get athlete;

  /// No description provided for @measurementUnit.
  ///
  /// In en, this message translates to:
  /// **'Measurement Unit'**
  String get measurementUnit;

  /// No description provided for @metricUnits.
  ///
  /// In en, this message translates to:
  /// **'Metric (KG/CM)'**
  String get metricUnits;

  /// No description provided for @imperialUnits.
  ///
  /// In en, this message translates to:
  /// **'Imperial (LBS/IN)'**
  String get imperialUnits;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @restTimerDuration.
  ///
  /// In en, this message translates to:
  /// **'Rest Timer'**
  String get restTimerDuration;

  /// No description provided for @secondsValue.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String secondsValue(int seconds);

  /// No description provided for @logNewMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Log New Measurement'**
  String get logNewMeasurement;

  /// No description provided for @bodyWeightField.
  ///
  /// In en, this message translates to:
  /// **'Body Weight'**
  String get bodyWeightField;

  /// No description provided for @bodyFatField.
  ///
  /// In en, this message translates to:
  /// **'Body Fat %'**
  String get bodyFatField;

  /// No description provided for @moreMeasurements.
  ///
  /// In en, this message translates to:
  /// **'More measurements'**
  String get moreMeasurements;

  /// No description provided for @waistField.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get waistField;

  /// No description provided for @chestField.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get chestField;

  /// No description provided for @armsField.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get armsField;

  /// No description provided for @hipsField.
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get hipsField;

  /// No description provided for @thighsField.
  ///
  /// In en, this message translates to:
  /// **'Thighs'**
  String get thighsField;

  /// No description provided for @cmUnit.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cmUnit;

  /// No description provided for @inUnit.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get inUnit;

  /// No description provided for @measurementLogged.
  ///
  /// In en, this message translates to:
  /// **'Measurement logged!'**
  String get measurementLogged;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get invalidNumber;

  /// No description provided for @progressPhotos.
  ///
  /// In en, this message translates to:
  /// **'Progress Photos'**
  String get progressPhotos;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose File'**
  String get chooseFile;

  /// No description provided for @photoNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get photoNoteHint;

  /// No description provided for @deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get deletePhoto;

  /// No description provided for @deletePhotoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this photo?'**
  String get deletePhotoConfirm;

  /// No description provided for @noPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No progress photos yet. Tap + to add one.'**
  String get noPhotosYet;

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataSection;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export workout history (CSV)'**
  String get exportCsv;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'Export full backup (JSON)'**
  String get exportJson;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get restoreBackup;

  /// No description provided for @restoreWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace all data?'**
  String get restoreWarningTitle;

  /// No description provided for @restoreWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Restoring a backup deletes ALL current data and replaces it with the backup contents. Progress photo files are not included in backups. This cannot be undone.'**
  String get restoreWarningBody;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Exported successfully'**
  String get exportSuccess;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get restoreSuccess;

  /// No description provided for @importInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'This file is not a valid backup'**
  String get importInvalidFile;

  /// No description provided for @importNewerVersion.
  ///
  /// In en, this message translates to:
  /// **'This backup was made by a newer app version'**
  String get importNewerVersion;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @catChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get catChest;

  /// No description provided for @catBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get catBack;

  /// No description provided for @catLegs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get catLegs;

  /// No description provided for @catShoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get catShoulders;

  /// No description provided for @catArms.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get catArms;

  /// No description provided for @catCore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get catCore;

  /// No description provided for @catCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get catCardio;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @muscleChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get muscleChest;

  /// No description provided for @muscleBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get muscleBack;

  /// No description provided for @muscleQuads.
  ///
  /// In en, this message translates to:
  /// **'Quads'**
  String get muscleQuads;

  /// No description provided for @muscleHamstrings.
  ///
  /// In en, this message translates to:
  /// **'Hamstrings'**
  String get muscleHamstrings;

  /// No description provided for @muscleGlutes.
  ///
  /// In en, this message translates to:
  /// **'Glutes'**
  String get muscleGlutes;

  /// No description provided for @muscleCalves.
  ///
  /// In en, this message translates to:
  /// **'Calves'**
  String get muscleCalves;

  /// No description provided for @muscleShoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get muscleShoulders;

  /// No description provided for @muscleTraps.
  ///
  /// In en, this message translates to:
  /// **'Traps'**
  String get muscleTraps;

  /// No description provided for @muscleBiceps.
  ///
  /// In en, this message translates to:
  /// **'Biceps'**
  String get muscleBiceps;

  /// No description provided for @muscleTriceps.
  ///
  /// In en, this message translates to:
  /// **'Triceps'**
  String get muscleTriceps;

  /// No description provided for @muscleCore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get muscleCore;

  /// No description provided for @muscleOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get muscleOther;

  /// No description provided for @equipBarbell.
  ///
  /// In en, this message translates to:
  /// **'Barbell'**
  String get equipBarbell;

  /// No description provided for @equipDumbbell.
  ///
  /// In en, this message translates to:
  /// **'Dumbbell'**
  String get equipDumbbell;

  /// No description provided for @equipCable.
  ///
  /// In en, this message translates to:
  /// **'Cable'**
  String get equipCable;

  /// No description provided for @equipMachine.
  ///
  /// In en, this message translates to:
  /// **'Machine'**
  String get equipMachine;

  /// No description provided for @equipBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get equipBodyweight;

  /// No description provided for @equipOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get equipOther;

  /// No description provided for @routinePushDay.
  ///
  /// In en, this message translates to:
  /// **'Push Day'**
  String get routinePushDay;

  /// No description provided for @routinePullDay.
  ///
  /// In en, this message translates to:
  /// **'Pull Day'**
  String get routinePullDay;

  /// No description provided for @routineLegs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get routineLegs;

  /// No description provided for @routineFullBody.
  ///
  /// In en, this message translates to:
  /// **'Full Body'**
  String get routineFullBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
