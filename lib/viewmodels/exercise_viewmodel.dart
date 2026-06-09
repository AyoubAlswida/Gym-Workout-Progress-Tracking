import 'package:flutter/foundation.dart';
import '../models/exercise.dart';
import '../repositories/exercise_repository.dart';

class ExerciseViewModel extends ChangeNotifier {
  final ExerciseRepository _repository;

  ExerciseViewModel({ExerciseRepository? repository})
      : _repository = repository ?? ExerciseRepository();

  List<Exercise> _exercises = [];
  List<Exercise> get exercises => _exercises;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _muscleGroupFilter;
  String? get muscleGroupFilter => _muscleGroupFilter;

  Future<void> loadExercises() async {
    _exercises = await _repository.getExercises(
      search: _searchQuery,
      muscleGroup: _muscleGroupFilter,
    );
    notifyListeners();
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    await loadExercises();
  }

  Future<void> setMuscleGroupFilter(String? muscleGroup) async {
    _muscleGroupFilter = muscleGroup;
    await loadExercises();
  }

  Future<void> addExercise(Exercise exercise) async {
    await _repository.insertExercise(exercise);
    await loadExercises();
  }

  Future<void> updateExercise(Exercise exercise) async {
    await _repository.updateExercise(exercise);
    await loadExercises();
  }

  /// Returns false when the exercise is referenced by sets or routines.
  Future<bool> deleteExercise(int id) async {
    final deleted = await _repository.deleteExercise(id);
    if (deleted) await loadExercises();
    return deleted;
  }
}
