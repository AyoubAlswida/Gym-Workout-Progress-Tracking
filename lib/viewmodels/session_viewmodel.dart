import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/exercise.dart';
import '../models/routine.dart';
import '../models/routine_exercise.dart';
import '../models/workout_set.dart';
import '../models/workout_session.dart';
import '../repositories/settings_repository.dart';
import '../repositories/workout_repository.dart';

/// One exercise within the active session and the sets logged for it.
class SessionExerciseGroup {
  final Exercise exercise;
  final List<WorkoutSet> sets;
  final int? targetSets;
  final int? targetReps;

  SessionExerciseGroup({
    required this.exercise,
    List<WorkoutSet>? sets,
    this.targetSets,
    this.targetReps,
  }) : sets = sets ?? [];
}

/// A personal record achieved during this session, surfaced once to the UI.
class PrEvent {
  final String exerciseName;
  final double weight;

  PrEvent({required this.exerciseName, required this.weight});
}

class SessionViewModel extends ChangeNotifier {
  final WorkoutRepository _repository;
  final SettingsRepository _settingsRepository;

  SessionViewModel({
    WorkoutRepository? repository,
    SettingsRepository? settingsRepository,
  })  : _repository = repository ?? WorkoutRepository(),
        _settingsRepository = settingsRepository ?? SettingsRepository();

  // Active session data
  WorkoutSession? _activeSession;
  WorkoutSession? get activeSession => _activeSession;

  final List<SessionExerciseGroup> _exerciseGroups = [];
  List<SessionExerciseGroup> get exerciseGroups =>
      List.unmodifiable(_exerciseGroups);

  List<Exercise> _allExercises = [];
  List<Exercise> get allExercises => _allExercises;

  /// Most recent completed set per exercise from previous sessions.
  final Map<int, WorkoutSet?> _lastPerformance = {};
  WorkoutSet? lastPerformanceFor(int exerciseId) =>
      _lastPerformance[exerciseId];

  /// All-time max weight per exercise (pre-session baseline, updated as
  /// PRs land mid-session so a second heavier set is a PR again).
  final Map<int, double> _maxWeights = {};

  PrEvent? _latestPr;

  /// One-shot: returns the latest PR and clears it.
  PrEvent? consumeLatestPr() {
    final pr = _latestPr;
    _latestPr = null;
    return pr;
  }

  // Elapsed time
  DateTime? _startTime;
  Timer? _elapsedTimer;
  int get elapsedSeconds => _startTime == null
      ? 0
      : DateTime.now().difference(_startTime!).inSeconds;

  // Rest timer
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  int get restSecondsRemaining => _restSecondsRemaining;
  bool get isResting => _restSecondsRemaining > 0;

  Future<void> initSession(String routineName) async {
    _allExercises = await _repository.getExercises();

    final newSession = WorkoutSession(
      date: DateTime.now().toIso8601String(),
      duration: 0,
      routineName: routineName,
    );
    int sessionId = await _repository.insertSession(newSession);
    _activeSession = WorkoutSession(
      id: sessionId,
      date: newSession.date,
      duration: newSession.duration,
      routineName: newSession.routineName,
    );
    _exerciseGroups.clear();
    _lastPerformance.clear();
    _maxWeights.clear();
    _latestPr = null;
    _startTime = DateTime.now();
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> initSessionFromRoutine(
      Routine routine, List<RoutineExercise> routineExercises) async {
    await initSession(routine.name);
    for (final item in routineExercises) {
      final exercise = _allExercises
          .where((e) => e.id == item.exerciseId)
          .firstOrNull;
      if (exercise == null) continue;
      await addExercise(exercise,
          targetSets: item.targetSets, targetReps: item.targetReps);
    }
  }

  Future<void> addExercise(Exercise exercise,
      {int? targetSets, int? targetReps}) async {
    if (_activeSession == null) return;
    if (_exerciseGroups.any((g) => g.exercise.id == exercise.id)) return;

    _exerciseGroups.add(SessionExerciseGroup(
      exercise: exercise,
      targetSets: targetSets,
      targetReps: targetReps,
    ));

    final exerciseId = exercise.id!;
    _lastPerformance[exerciseId] = await _repository.getLastSetForExercise(
      exerciseId,
      excludeSessionId: _activeSession!.id,
    );
    final maxWeight = await _repository.getMaxWeightForExercise(
      exerciseId,
      excludeSessionId: _activeSession!.id,
    );
    if (maxWeight != null) _maxWeights[exerciseId] = maxWeight;
    notifyListeners();
  }

  Future<void> addSet(int exerciseId, double weight, int reps) async {
    if (_activeSession == null) return;
    final group = _exerciseGroups
        .where((g) => g.exercise.id == exerciseId)
        .firstOrNull;
    if (group == null) return;

    final newSet = WorkoutSet(
      sessionId: _activeSession!.id!,
      exerciseId: exerciseId,
      weight: weight,
      reps: reps,
    );
    int setId = await _repository.insertSet(newSet);

    group.sets.add(WorkoutSet(
      id: setId,
      sessionId: newSet.sessionId,
      exerciseId: newSet.exerciseId,
      weight: newSet.weight,
      reps: newSet.reps,
      isCompleted: newSet.isCompleted,
    ));
    notifyListeners();
  }

  Future<void> toggleSetCompletion(WorkoutSet targetSet) async {
    final group = _exerciseGroups
        .where((g) => g.exercise.id == targetSet.exerciseId)
        .firstOrNull;
    if (group == null) return;
    final index = group.sets.indexWhere((s) => s.id == targetSet.id);
    if (index == -1) return;

    final newStatus = !targetSet.isCompleted;
    await _repository.updateSetCompletion(targetSet.id!, newStatus);

    group.sets[index] = WorkoutSet(
      id: targetSet.id,
      sessionId: targetSet.sessionId,
      exerciseId: targetSet.exerciseId,
      weight: targetSet.weight,
      reps: targetSet.reps,
      isCompleted: newStatus,
    );

    if (newStatus) {
      final previousMax = _maxWeights[targetSet.exerciseId];
      if (previousMax != null && targetSet.weight > previousMax) {
        _latestPr = PrEvent(
          exerciseName: group.exercise.name,
          weight: targetSet.weight,
        );
      }
      // First-ever set becomes the silent baseline; heavier sets later in
      // this same session can still trigger a PR.
      if (previousMax == null || targetSet.weight > previousMax) {
        _maxWeights[targetSet.exerciseId] = targetSet.weight;
      }
      startRestTimer(await _settingsRepository.getRestTimerSeconds());
    } else {
      stopRestTimer();
    }

    notifyListeners();
  }

  void startRestTimer(int seconds) {
    stopRestTimer();
    _restSecondsRemaining = seconds;
    notifyListeners();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining > 0) {
        _restSecondsRemaining--;
        notifyListeners();
      } else {
        stopRestTimer();
      }
    });
  }

  void stopRestTimer() {
    _restTimer?.cancel();
    _restSecondsRemaining = 0;
    notifyListeners();
  }

  /// Persists duration and notes, or deletes the session entirely when no
  /// sets were logged (an abandoned session shouldn't count as a workout).
  Future<void> finishSession({String? notes}) async {
    stopRestTimer();
    _elapsedTimer?.cancel();
    _elapsedTimer = null;

    final session = _activeSession;
    if (session != null) {
      final hasSets = _exerciseGroups.any((g) => g.sets.isNotEmpty);
      if (hasSets) {
        await _repository.updateSessionOnFinish(
          session.id!,
          elapsedSeconds,
          (notes == null || notes.trim().isEmpty) ? null : notes.trim(),
        );
      } else {
        await _repository.deleteSession(session.id!);
      }
    }

    _startTime = null;
    _activeSession = null;
    _exerciseGroups.clear();
    _lastPerformance.clear();
    _maxWeights.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }
}
