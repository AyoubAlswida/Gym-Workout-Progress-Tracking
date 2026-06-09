import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_workout_tracking/models/exercise.dart';
import 'package:gym_workout_tracking/models/workout_session.dart';
import 'package:gym_workout_tracking/models/workout_set.dart';
import 'package:gym_workout_tracking/repositories/workout_repository.dart';
import 'package:gym_workout_tracking/viewmodels/session_viewmodel.dart';

import '../test_db_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late SessionViewModel viewModel;
  late WorkoutRepository repository;

  setUp(() async {
    tempDir = await setupTestDatabase();
    SharedPreferences.setMockInitialValues({'restTimerSeconds': 90});
    repository = WorkoutRepository();
    viewModel = SessionViewModel();
  });

  tearDown(() async {
    viewModel.dispose();
    await teardownTestDatabase(tempDir);
  });

  Future<Exercise> benchPress() async =>
      (await repository.getExercises()).firstWhere((e) => e.name == 'Bench Press');

  test('sets are grouped per exercise in add order', () async {
    await viewModel.initSession('Quick Workout');
    final bench = await benchPress();
    final squat = (await repository.getExercises())
        .firstWhere((e) => e.name == 'Squat');

    await viewModel.addExercise(bench);
    await viewModel.addExercise(squat);
    await viewModel.addSet(bench.id!, 80, 8);
    await viewModel.addSet(squat.id!, 100, 5);
    await viewModel.addSet(bench.id!, 82.5, 6);

    expect(viewModel.exerciseGroups.length, 2);
    expect(viewModel.exerciseGroups[0].exercise.name, 'Bench Press');
    expect(viewModel.exerciseGroups[0].sets.length, 2);
    expect(viewModel.exerciseGroups[1].sets.length, 1);
  });

  test('rest timer uses the persisted preference', () async {
    await viewModel.initSession('Quick Workout');
    final bench = await benchPress();
    await viewModel.addExercise(bench);
    await viewModel.addSet(bench.id!, 80, 8);

    await viewModel.toggleSetCompletion(viewModel.exerciseGroups[0].sets[0]);

    expect(viewModel.isResting, isTrue);
    expect(viewModel.restSecondsRemaining, 90);
    viewModel.stopRestTimer();
  });

  test('PR fires only above a previous max, first set is silent baseline', () async {
    final bench = await benchPress();
    // Historic session: max 80 kg.
    final oldId = await repository.insertSession(WorkoutSession(
      date: '2026-05-01T10:00:00.000', duration: 0, routineName: 'Old'));
    final oldSet = await repository.insertSet(WorkoutSet(
        sessionId: oldId, exerciseId: bench.id!, weight: 80, reps: 8));
    await repository.updateSetCompletion(oldSet, true);

    await viewModel.initSession('Quick Workout');
    await viewModel.addExercise(bench);

    // Below the max: no PR.
    await viewModel.addSet(bench.id!, 75, 8);
    await viewModel.toggleSetCompletion(viewModel.exerciseGroups[0].sets[0]);
    expect(viewModel.consumeLatestPr(), isNull);

    // Above the max: PR, consumed once.
    await viewModel.addSet(bench.id!, 85, 5);
    await viewModel.toggleSetCompletion(viewModel.exerciseGroups[0].sets[1]);
    final pr = viewModel.consumeLatestPr();
    expect(pr, isNotNull);
    expect(pr!.weight, 85);
    expect(viewModel.consumeLatestPr(), isNull);

    // Beating the mid-session max again is another PR.
    await viewModel.addSet(bench.id!, 90, 3);
    await viewModel.toggleSetCompletion(viewModel.exerciseGroups[0].sets[2]);
    expect(viewModel.consumeLatestPr()!.weight, 90);
    viewModel.stopRestTimer();
  });

  test('exercise with no history never fires a PR for its first set', () async {
    await viewModel.initSession('Quick Workout');
    final bench = await benchPress();
    await viewModel.addExercise(bench);
    await viewModel.addSet(bench.id!, 60, 10);
    await viewModel.toggleSetCompletion(viewModel.exerciseGroups[0].sets[0]);
    expect(viewModel.consumeLatestPr(), isNull);
    viewModel.stopRestTimer();
  });

  test('finishSession saves duration and notes', () async {
    await viewModel.initSession('Push Day');
    final sessionId = viewModel.activeSession!.id!;
    final bench = await benchPress();
    await viewModel.addExercise(bench);
    await viewModel.addSet(bench.id!, 80, 8);

    await viewModel.finishSession(notes: '  good pump  ');

    expect(viewModel.activeSession, isNull);
    final session =
        (await repository.getSessions()).firstWhere((s) => s.id == sessionId);
    expect(session.duration, greaterThanOrEqualTo(0));
    expect(session.notes, 'good pump');
  });

  test('abandoning an empty session deletes its row', () async {
    await viewModel.initSession('Quick Workout');
    final sessionId = viewModel.activeSession!.id!;

    await viewModel.finishSession();

    expect(
      (await repository.getSessions()).where((s) => s.id == sessionId),
      isEmpty,
    );
  });

  test('lastPerformance hint loads previous completed set', () async {
    final bench = await benchPress();
    final oldId = await repository.insertSession(WorkoutSession(
        date: '2026-05-01T10:00:00.000', duration: 0, routineName: 'Old'));
    final oldSet = await repository.insertSet(WorkoutSet(
        sessionId: oldId, exerciseId: bench.id!, weight: 77.5, reps: 6));
    await repository.updateSetCompletion(oldSet, true);

    await viewModel.initSession('Quick Workout');
    await viewModel.addExercise(bench);

    final hint = viewModel.lastPerformanceFor(bench.id!);
    expect(hint, isNotNull);
    expect(hint!.weight, 77.5);
    expect(hint.reps, 6);
  });
}
