import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/exercise.dart';
import '../models/workout_set.dart';
import '../models/workout_session.dart';
import '../repositories/workout_repository.dart';

class SessionViewModel extends ChangeNotifier {
  final WorkoutRepository _repository = WorkoutRepository();

  // Active session data
  WorkoutSession? _activeSession;
  WorkoutSession? get activeSession => _activeSession;

  List<WorkoutSet> _activeSets = [];
  List<WorkoutSet> get activeSets => _activeSets;
  
  List<Exercise> _allExercises = [];
  List<Exercise> get allExercises => _allExercises;

  // Timer logic
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
    _activeSets = [];
    notifyListeners();
  }

  Future<void> addSet(int exerciseId, double weight, int reps) async {
    if (_activeSession == null) return;
    
    final newSet = WorkoutSet(
      sessionId: _activeSession!.id!,
      exerciseId: exerciseId,
      weight: weight,
      reps: reps,
    );
    int setId = await _repository.insertSet(newSet);
    
    _activeSets.add(WorkoutSet(
      id: setId,
      sessionId: newSet.sessionId,
      exerciseId: newSet.exerciseId,
      weight: newSet.weight,
      reps: newSet.reps,
      isCompleted: newSet.isCompleted,
    ));
    notifyListeners();
  }

  Future<void> toggleSetCompletion(int index) async {
    final targetSet = _activeSets[index];
    final newStatus = !targetSet.isCompleted;
    
    await _repository.updateSetCompletion(targetSet.id!, newStatus);
    
    _activeSets[index] = WorkoutSet(
      id: targetSet.id,
      sessionId: targetSet.sessionId,
      exerciseId: targetSet.exerciseId,
      weight: targetSet.weight,
      reps: targetSet.reps,
      isCompleted: newStatus,
    );
    
    // Trigger rest timer if completed
    if (newStatus) {
      startRestTimer(60); // 60 seconds default rest
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

  void finishSession() {
    stopRestTimer();
    _activeSession = null;
    _activeSets.clear();
    notifyListeners();
  }
}
