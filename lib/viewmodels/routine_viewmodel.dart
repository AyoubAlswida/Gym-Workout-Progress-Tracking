import 'package:flutter/foundation.dart';
import '../models/routine.dart';
import '../models/routine_exercise.dart';
import '../repositories/routine_repository.dart';

class RoutineViewModel extends ChangeNotifier {
  final RoutineRepository _repository;

  RoutineViewModel({RoutineRepository? repository})
      : _repository = repository ?? RoutineRepository();

  List<Routine> _routines = [];
  List<Routine> get routines => _routines;

  Map<int, int> _exerciseCounts = {};
  int exerciseCountFor(int routineId) => _exerciseCounts[routineId] ?? 0;

  Future<void> loadRoutines() async {
    _routines = await _repository.getRoutines();
    _exerciseCounts = await _repository.getExerciseCounts();
    notifyListeners();
  }

  Future<List<RoutineExercise>> getRoutineExercises(int routineId) {
    return _repository.getRoutineExercises(routineId);
  }

  Future<void> saveRoutine(Routine routine, List<RoutineExercise> items) async {
    if (routine.id == null) {
      await _repository.insertRoutine(routine, items);
    } else {
      await _repository.updateRoutine(routine, items);
    }
    await loadRoutines();
  }

  Future<void> deleteRoutine(int routineId) async {
    await _repository.deleteRoutine(routineId);
    await loadRoutines();
  }
}
