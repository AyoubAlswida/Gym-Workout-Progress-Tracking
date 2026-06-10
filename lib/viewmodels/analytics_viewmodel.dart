import 'package:flutter/foundation.dart';
import '../core/coach/coach_service.dart';
import '../core/fitness/one_rep_max.dart' as fitness;
import '../models/body_measurement.dart';
import '../models/exercise.dart';
import '../repositories/measurement_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/workout_repository.dart';

class ExerciseProgressPoint {
  final DateTime date;
  final double maxWeight;
  final double estimated1Rm;

  ExerciseProgressPoint({
    required this.date,
    required this.maxWeight,
    required this.estimated1Rm,
  });
}

class WeeklyVolumePoint {
  final DateTime weekStart;
  final double volume;

  WeeklyVolumePoint({required this.weekStart, required this.volume});
}

class PersonalRecord {
  final int exerciseId;
  final String exerciseName;
  final double weight;
  final int reps;
  final DateTime date;

  PersonalRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.date,
  });
}

class AnalyticsViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;
  final MeasurementRepository _measurementRepository;
  final SettingsRepository _settingsRepository;
  final CoachService _coachService;

  AnalyticsViewModel({
    WorkoutRepository? workoutRepository,
    MeasurementRepository? measurementRepository,
    SettingsRepository? settingsRepository,
    CoachService? coachService,
  })  : _workoutRepository = workoutRepository ?? WorkoutRepository(),
        _measurementRepository =
            measurementRepository ?? MeasurementRepository(),
        _settingsRepository = settingsRepository ?? SettingsRepository(),
        _coachService = coachService ?? CoachService();

  List<Exercise> _exercisesWithData = [];
  List<Exercise> get exercisesWithData => _exercisesWithData;

  Exercise? _selectedExercise;
  Exercise? get selectedExercise => _selectedExercise;

  List<ExerciseProgressPoint> _progressPoints = [];
  List<ExerciseProgressPoint> get progressPoints => _progressPoints;

  CoachSuggestion? _coachSuggestion;
  CoachSuggestion? get coachSuggestion => _coachSuggestion;

  bool _isPlateau = false;
  bool get isPlateau => _isPlateau;

  List<WeeklyVolumePoint> _weeklyVolume = [];
  List<WeeklyVolumePoint> get weeklyVolume => _weeklyVolume;

  List<PersonalRecord> _personalRecords = [];
  List<PersonalRecord> get personalRecords => _personalRecords;

  List<BodyMeasurement> _measurements = [];
  List<BodyMeasurement> get measurements => _measurements;

  /// Epley formula; a 1-rep set is already its own max.
  static double estimate1Rm(double weight, int reps) =>
      fitness.estimate1Rm(weight, reps);

  Future<void> load() async {
    _exercisesWithData = await _workoutRepository.getExercisesWithData();
    if (_selectedExercise == null ||
        !_exercisesWithData.any((e) => e.id == _selectedExercise!.id)) {
      _selectedExercise = _exercisesWithData.firstOrNull;
    }
    await _loadProgress();
    await _loadWeeklyVolume();
    await _loadPersonalRecords();
    _measurements = await _measurementRepository.getMeasurements();
    notifyListeners();
  }

  Future<void> selectExercise(Exercise exercise) async {
    _selectedExercise = exercise;
    await _loadProgress();
    notifyListeners();
  }

  Future<void> _loadProgress() async {
    final exercise = _selectedExercise;
    if (exercise == null) {
      _progressPoints = [];
      _coachSuggestion = null;
      _isPlateau = false;
      return;
    }
    final rows = await _workoutRepository.getExerciseProgress(exercise.id!);
    final snapshots = <SetSnapshot>[];
    _progressPoints = rows.map((row) {
      final weight = (row['maxWeight'] as num).toDouble();
      final reps = row['reps'] as int;
      final date = DateTime.parse(row['date'] as String);
      snapshots.add(SetSnapshot(weight: weight, reps: reps, date: date));
      return ExerciseProgressPoint(
        date: date,
        maxWeight: weight,
        estimated1Rm: estimate1Rm(weight, reps),
      );
    }).toList();

    final goal = _parseGoal(await _settingsRepository.getTrainingGoal());
    _coachSuggestion = _coachService.suggestNext(
      snapshots,
      goal: goal,
      isMetric: await _settingsRepository.getIsMetric(),
    );
    _isPlateau = _coachService.detectPlateau(snapshots);
  }

  static TrainingGoal _parseGoal(String value) => TrainingGoal.values
      .firstWhere((g) => g.name == value,
          orElse: () => TrainingGoal.hypertrophy);

  Future<void> _loadWeeklyVolume({int weeks = 8}) async {
    final rows = await _workoutRepository.getCompletedSetVolumes();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentWeekStart =
        today.subtract(Duration(days: today.weekday - 1));

    final buckets = <DateTime, double>{
      for (var i = weeks - 1; i >= 0; i--)
        currentWeekStart.subtract(Duration(days: 7 * i)): 0.0,
    };
    for (final row in rows) {
      final date = DateTime.parse(row['date'] as String);
      final day = DateTime(date.year, date.month, date.day);
      final weekStart = day.subtract(Duration(days: day.weekday - 1));
      if (buckets.containsKey(weekStart)) {
        buckets[weekStart] =
            buckets[weekStart]! + (row['volume'] as num).toDouble();
      }
    }
    _weeklyVolume = buckets.entries
        .map((e) => WeeklyVolumePoint(weekStart: e.key, volume: e.value))
        .toList()
      ..sort((a, b) => a.weekStart.compareTo(b.weekStart));
  }

  Future<void> _loadPersonalRecords() async {
    final rows = await _workoutRepository.getPersonalRecords();
    _personalRecords = rows
        .map((row) => PersonalRecord(
              exerciseId: row['exerciseId'] as int,
              exerciseName: row['exerciseName'] as String,
              weight: (row['weight'] as num).toDouble(),
              reps: row['reps'] as int,
              date: DateTime.parse(row['date'] as String),
            ))
        .toList();
  }
}
