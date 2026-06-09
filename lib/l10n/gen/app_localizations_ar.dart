// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'متتبع الجيم';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navRoutines => 'الروتينات';

  @override
  String get navAnalytics => 'التحليلات';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get helloAthlete => 'أهلاً أيها البطل!';

  @override
  String get workoutsThisWeek => 'تمارين هذا الأسبوع';

  @override
  String get latestWeight => 'آخر وزن';

  @override
  String get streak => 'سلسلة الالتزام';

  @override
  String weekStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سلسلة $count أسبوعاً',
      few: 'سلسلة $count أسابيع',
      two: 'سلسلة أسبوعين',
      one: 'سلسلة أسبوع واحد',
      zero: 'لا توجد سلسلة بعد',
    );
    return '$_temp0';
  }

  @override
  String get startNewWorkout => 'ابدأ تمريناً جديداً';

  @override
  String get quickWorkout => 'تمرين سريع';

  @override
  String get workout => 'تمرين';

  @override
  String restLabel(int seconds) {
    return 'راحة: $seconds ث';
  }

  @override
  String setNumber(int number) {
    return 'طقم $number';
  }

  @override
  String setSummary(String weight, String unit, int reps) {
    return '$weight $unit × $reps تكرار';
  }

  @override
  String get weight => 'الوزن';

  @override
  String get reps => 'التكرارات';

  @override
  String get addExercise => 'إضافة تمرين';

  @override
  String get finishWorkout => 'إنهاء التمرين';

  @override
  String get sessionNotes => 'ملاحظات الجلسة';

  @override
  String get sessionNotesHint => 'كيف كان التمرين؟';

  @override
  String lastTime(String weight, String unit, int reps) {
    return 'آخر مرة: $weight $unit × $reps';
  }

  @override
  String newPr(String exercise, String weight, String unit) {
    return 'رقم قياسي جديد! $exercise: $weight $unit';
  }

  @override
  String get kg => 'كجم';

  @override
  String get lbs => 'رطل';

  @override
  String get kmUnit => 'كم';

  @override
  String get miUnit => 'ميل';

  @override
  String get durationMinutesField => 'المدة (دقيقة)';

  @override
  String distanceField(String unit) {
    return 'المسافة ($unit)';
  }

  @override
  String lastTimeGeneric(String value) {
    return 'آخر مرة: $value';
  }

  @override
  String get newRoutine => 'روتين جديد';

  @override
  String get editRoutine => 'تعديل الروتين';

  @override
  String get routineName => 'اسم الروتين';

  @override
  String get deleteRoutine => 'حذف الروتين';

  @override
  String deleteRoutineConfirm(String name) {
    return 'حذف \"$name\"؟ لا يمكن التراجع عن هذا.';
  }

  @override
  String exercisesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تمريناً',
      few: '$count تمارين',
      two: 'تمرينان',
      one: 'تمرين واحد',
      zero: 'بدون تمارين',
    );
    return '$_temp0';
  }

  @override
  String targetSetsReps(int sets, int reps) {
    return '$sets × $reps';
  }

  @override
  String get presetBadge => 'جاهز';

  @override
  String get noRoutinesYet => 'لا توجد روتينات بعد. اضغط + لإنشاء واحد.';

  @override
  String get routineNeedsNameAndExercise =>
      'أضف اسماً وتمريناً واحداً على الأقل.';

  @override
  String get exerciseLibrary => 'مكتبة التمارين';

  @override
  String get searchExercises => 'ابحث عن تمرين...';

  @override
  String get allMuscleGroups => 'الكل';

  @override
  String get newExercise => 'تمرين جديد';

  @override
  String get editExercise => 'تعديل التمرين';

  @override
  String get exerciseName => 'اسم التمرين';

  @override
  String get category => 'الفئة';

  @override
  String get muscleGroup => 'العضلة المستهدفة';

  @override
  String get equipment => 'الأداة';

  @override
  String get customBadge => 'مخصص';

  @override
  String get deleteExercise => 'حذف التمرين';

  @override
  String deleteExerciseConfirm(String name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String get exerciseInUse =>
      'هذا التمرين مستخدم في تمارين أو روتينات ولا يمكن حذفه.';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get noExercisesFound => 'لا توجد تمارين مطابقة';

  @override
  String get strengthProgress => 'تقدم القوة';

  @override
  String get maxWeight => 'أقصى وزن';

  @override
  String get estimated1Rm => '1RM تقديري';

  @override
  String get weeklyVolume => 'الحجم الأسبوعي';

  @override
  String get bodyWeightChart => 'وزن الجسم';

  @override
  String get bodyTrends => 'مؤشرات الجسم';

  @override
  String get personalRecords => 'الأرقام القياسية';

  @override
  String get measurementHistory => 'سجل القياسات';

  @override
  String get noDataYet => 'لا توجد بيانات بعد';

  @override
  String weightEntry(String weight, String unit) {
    return 'الوزن: $weight $unit';
  }

  @override
  String bodyFatEntry(String percent) {
    return 'دهون الجسم: $percent%';
  }

  @override
  String get settingsProfile => 'الإعدادات والملف الشخصي';

  @override
  String get athlete => 'رياضي';

  @override
  String get measurementUnit => 'وحدة القياس';

  @override
  String get metricUnits => 'متري (كجم/سم)';

  @override
  String get imperialUnits => 'إمبراطوري (رطل/إنش)';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get restTimerDuration => 'مؤقت الراحة';

  @override
  String secondsValue(int seconds) {
    return '$seconds ث';
  }

  @override
  String get logNewMeasurement => 'تسجيل قياس جديد';

  @override
  String get bodyWeightField => 'وزن الجسم';

  @override
  String get bodyFatField => 'نسبة الدهون %';

  @override
  String get moreMeasurements => 'قياسات إضافية';

  @override
  String get waistField => 'الخصر';

  @override
  String get chestField => 'الصدر';

  @override
  String get armsField => 'الذراع';

  @override
  String get hipsField => 'الورك';

  @override
  String get thighsField => 'الفخذ';

  @override
  String get cmUnit => 'سم';

  @override
  String get inUnit => 'إنش';

  @override
  String get measurementLogged => 'تم تسجيل القياس!';

  @override
  String get invalidNumber => 'أدخل رقماً صحيحاً';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get catChest => 'صدر';

  @override
  String get catBack => 'ظهر';

  @override
  String get catLegs => 'أرجل';

  @override
  String get catShoulders => 'أكتاف';

  @override
  String get catArms => 'ذراعان';

  @override
  String get catCore => 'بطن وجذع';

  @override
  String get catCardio => 'كارديو';

  @override
  String get catOther => 'أخرى';

  @override
  String get muscleChest => 'الصدر';

  @override
  String get muscleBack => 'الظهر';

  @override
  String get muscleQuads => 'الفخذ الأمامي';

  @override
  String get muscleHamstrings => 'الفخذ الخلفي';

  @override
  String get muscleGlutes => 'المؤخرة';

  @override
  String get muscleCalves => 'السمانة';

  @override
  String get muscleShoulders => 'الأكتاف';

  @override
  String get muscleTraps => 'الترابيس';

  @override
  String get muscleBiceps => 'البايسبس';

  @override
  String get muscleTriceps => 'الترايسبس';

  @override
  String get muscleCore => 'البطن والجذع';

  @override
  String get muscleOther => 'أخرى';

  @override
  String get equipBarbell => 'بار';

  @override
  String get equipDumbbell => 'دمبل';

  @override
  String get equipCable => 'كيبل';

  @override
  String get equipMachine => 'جهاز';

  @override
  String get equipBodyweight => 'وزن الجسم';

  @override
  String get equipOther => 'أخرى';

  @override
  String get routinePushDay => 'يوم الدفع';

  @override
  String get routinePullDay => 'يوم السحب';

  @override
  String get routineLegs => 'الأرجل';

  @override
  String get routineFullBody => 'الجسم كامل';
}
