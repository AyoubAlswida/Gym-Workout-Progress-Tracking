import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_workout_tracking/core/database/db_helper.dart';
import 'package:gym_workout_tracking/models/routine.dart';
import 'package:gym_workout_tracking/models/routine_exercise.dart';
import 'package:gym_workout_tracking/repositories/routine_repository.dart';

import '../test_db_helper.dart';

void main() {
  late Directory tempDir;
  late RoutineRepository repository;

  setUp(() async {
    tempDir = await setupTestDatabase();
    repository = RoutineRepository();
  });

  tearDown(() async {
    await teardownTestDatabase(tempDir);
  });

  test('presets are seeded with ordered, named exercises', () async {
    final routines = await repository.getRoutines();
    expect(routines.where((r) => r.isPreset).length, 4);

    final pushDay = routines.firstWhere((r) => r.name == 'Push Day');
    final exercises = await repository.getRoutineExercises(pushDay.id!);
    expect(exercises.length, 5);
    expect(exercises.first.exerciseName, 'Bench Press');
    expect(
      exercises.map((e) => e.orderIndex).toList(),
      [0, 1, 2, 3, 4],
    );
  });

  test('insert, update, and delete a custom routine', () async {
    RoutineExercise item(int exerciseId, int order) => RoutineExercise(
          routineId: 0,
          exerciseId: exerciseId,
          targetSets: 3,
          targetReps: 10,
          orderIndex: order,
        );

    final id = await repository.insertRoutine(
      Routine(name: 'My Split'),
      [item(1, 0), item(2, 1)],
    );

    var exercises = await repository.getRoutineExercises(id);
    expect(exercises.length, 2);

    // Reorder and shrink the list.
    await repository.updateRoutine(
      Routine(id: id, name: 'My Split v2'),
      [item(2, 0)],
    );
    exercises = await repository.getRoutineExercises(id);
    expect(exercises.length, 1);
    expect(exercises.first.exerciseId, 2);
    final routines = await repository.getRoutines();
    expect(routines.any((r) => r.name == 'My Split v2'), isTrue);

    await repository.deleteRoutine(id);
    expect(await repository.getRoutineExercises(id), isEmpty);
    expect((await repository.getRoutines()).any((r) => r.id == id), isFalse);
  });

  test('updateRoutine keeps uuid of retained exercises and tombstones removed',
      () async {
    final db = await DatabaseHelper.instance.database;
    RoutineExercise item(int exerciseId, int order) => RoutineExercise(
          routineId: 0,
          exerciseId: exerciseId,
          targetSets: 3,
          targetReps: 10,
          orderIndex: order,
        );

    final id = await repository.insertRoutine(
      Routine(name: 'Split'),
      [item(1, 0), item(2, 1)],
    );

    // Capture the uuid the kept exercise (id=1) was assigned.
    final before = await db.query('routine_exercises',
        where: 'routineId = ? AND exerciseId = 1', whereArgs: [id]);
    final keptUuid = before.single['uuid'];
    expect(keptUuid, isNotNull);

    // Drop exercise 2, keep exercise 1 (reordered), add exercise 3.
    await repository.updateRoutine(
      Routine(id: id, name: 'Split'),
      [item(1, 0), item(3, 1)],
    );

    // Kept exercise retained its identity (uuid unchanged) → remote updates
    // in place rather than orphaning a row.
    final after = await db.query('routine_exercises',
        where: 'routineId = ? AND exerciseId = 1', whereArgs: [id]);
    expect(after.single['uuid'], keptUuid);

    // Removed exercise 2 is tombstoned, not physically gone, and is dirty so
    // the deletion will push.
    final removed = await db.query('routine_exercises',
        where: 'routineId = ? AND exerciseId = 2', whereArgs: [id]);
    expect(removed.single['isDeleted'], 1);
    expect(removed.single['isDirty'], 1);

    // The visible list reflects the new contents only.
    final visible = await repository.getRoutineExercises(id);
    expect(visible.map((e) => e.exerciseId).toList(), [1, 3]);
  });

  test('exercise counts map covers all routines', () async {
    final counts = await repository.getExerciseCounts();
    final routines = await repository.getRoutines();
    for (final routine in routines) {
      expect(counts[routine.id], 5);
    }
  });
}
