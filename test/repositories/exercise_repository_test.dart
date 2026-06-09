import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_workout_tracking/models/exercise.dart';
import 'package:gym_workout_tracking/models/workout_session.dart';
import 'package:gym_workout_tracking/models/workout_set.dart';
import 'package:gym_workout_tracking/repositories/exercise_repository.dart';
import 'package:gym_workout_tracking/repositories/workout_repository.dart';

import '../test_db_helper.dart';

void main() {
  late Directory tempDir;
  late ExerciseRepository repository;

  setUp(() async {
    tempDir = await setupTestDatabase();
    repository = ExerciseRepository();
  });

  tearDown(() async {
    await teardownTestDatabase(tempDir);
  });

  test('search and muscle group filters apply together', () async {
    final byName = await repository.getExercises(search: 'Bench');
    expect(byName, isNotEmpty);
    expect(byName.every((e) => e.name.contains('Bench')), isTrue);

    final byMuscle = await repository.getExercises(muscleGroup: 'Biceps');
    expect(byMuscle, isNotEmpty);
    expect(byMuscle.every((e) => e.muscleGroup == 'Biceps'), isTrue);

    final both = await repository.getExercises(
        search: 'Hammer', muscleGroup: 'Biceps');
    expect(both.length, 1);
    expect(both.first.name, 'Hammer Curl');
  });

  test('insert, update, and delete a custom exercise', () async {
    final id = await repository.insertExercise(Exercise(
      name: 'Landmine Press',
      category: 'Shoulders',
      muscleGroup: 'Shoulders',
      equipment: 'Barbell',
      isCustom: true,
    ));

    await repository.updateExercise(Exercise(
      id: id,
      name: 'Landmine Press',
      category: 'Chest',
      muscleGroup: 'Chest',
      equipment: 'Barbell',
      isCustom: true,
    ));
    final updated = await repository.getExercises(search: 'Landmine');
    expect(updated.first.category, 'Chest');

    expect(await repository.deleteExercise(id), isTrue);
    expect(await repository.getExercises(search: 'Landmine'), isEmpty);
  });

  test('delete is refused when the exercise has logged sets', () async {
    final id = await repository.insertExercise(Exercise(
      name: 'Zercher Squat',
      category: 'Legs',
      muscleGroup: 'Quads',
      equipment: 'Barbell',
      isCustom: true,
    ));
    final workoutRepository = WorkoutRepository();
    final sessionId = await workoutRepository.insertSession(WorkoutSession(
      date: DateTime.now().toIso8601String(),
      duration: 0,
      routineName: 'Test',
    ));
    await workoutRepository.insertSet(WorkoutSet(
      sessionId: sessionId,
      exerciseId: id,
      weight: 60,
      reps: 8,
    ));

    expect(await repository.deleteExercise(id), isFalse);
    expect(await repository.getExercises(search: 'Zercher'), isNotEmpty);
  });

  test('preset exercises cannot be deleted', () async {
    final bench = (await repository.getExercises(search: 'Bench Press')).first;
    // No sets reference it in a fresh DB, yet isCustom=0 blocks the delete.
    await repository.deleteExercise(bench.id!);
    expect(await repository.getExercises(search: 'Bench Press'), isNotEmpty);
  });
}
