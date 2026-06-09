import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_workout_tracking/models/workout_session.dart';
import 'package:gym_workout_tracking/models/workout_set.dart';
import 'package:gym_workout_tracking/repositories/workout_repository.dart';
import 'package:gym_workout_tracking/viewmodels/analytics_viewmodel.dart';

import '../test_db_helper.dart';

void main() {
  late Directory tempDir;
  late AnalyticsViewModel viewModel;
  late WorkoutRepository repository;

  setUp(() async {
    tempDir = await setupTestDatabase();
    repository = WorkoutRepository();
    viewModel = AnalyticsViewModel();
  });

  tearDown(() async {
    await teardownTestDatabase(tempDir);
  });

  Future<void> insertCompletedSet({
    required String date,
    required int exerciseId,
    required double weight,
    required int reps,
  }) async {
    final sessionId = await repository.insertSession(WorkoutSession(
      date: date,
      duration: 0,
      routineName: 'Test',
    ));
    final setId = await repository.insertSet(WorkoutSet(
      sessionId: sessionId,
      exerciseId: exerciseId,
      weight: weight,
      reps: reps,
    ));
    await repository.updateSetCompletion(setId, true);
  }

  test('Epley 1RM estimate', () {
    expect(AnalyticsViewModel.estimate1Rm(100, 1), 100);
    expect(AnalyticsViewModel.estimate1Rm(100, 10), closeTo(133.33, 0.01));
    expect(AnalyticsViewModel.estimate1Rm(60, 30), 120);
  });

  test('load picks an exercise with data and builds progress points', () async {
    await insertCompletedSet(
        date: '2026-05-20T10:00:00.000', exerciseId: 1, weight: 80, reps: 8);
    await insertCompletedSet(
        date: '2026-06-01T10:00:00.000', exerciseId: 1, weight: 85, reps: 6);

    await viewModel.load();

    expect(viewModel.selectedExercise?.id, 1);
    expect(viewModel.progressPoints.length, 2);
    expect(viewModel.progressPoints.first.maxWeight, 80);
    expect(viewModel.progressPoints.last.maxWeight, 85);
    expect(viewModel.progressPoints.last.estimated1Rm,
        closeTo(85 * (1 + 6 / 30.0), 0.01));
  });

  test('weekly volume buckets the current week and stays at 8 buckets', () async {
    final now = DateTime.now();
    await insertCompletedSet(
        date: now.toIso8601String(), exerciseId: 1, weight: 100, reps: 10);
    await insertCompletedSet(
        date: now.toIso8601String(), exerciseId: 2, weight: 50, reps: 10);
    // Older than the 8-week window: ignored.
    await insertCompletedSet(
        date: now.subtract(const Duration(days: 70)).toIso8601String(),
        exerciseId: 1,
        weight: 100,
        reps: 10);

    await viewModel.load();

    expect(viewModel.weeklyVolume.length, 8);
    expect(viewModel.weeklyVolume.last.volume, 1500);
    expect(
      viewModel.weeklyVolume
          .take(7)
          .map((w) => w.volume)
          .reduce((a, b) => a + b),
      0,
    );
  });

  test('personal records list one entry per exercise', () async {
    await insertCompletedSet(
        date: '2026-05-01T10:00:00.000', exerciseId: 1, weight: 80, reps: 8);
    await insertCompletedSet(
        date: '2026-06-01T10:00:00.000', exerciseId: 1, weight: 90, reps: 4);
    await insertCompletedSet(
        date: '2026-06-02T10:00:00.000', exerciseId: 3, weight: 140, reps: 3);

    await viewModel.load();

    expect(viewModel.personalRecords.length, 2);
    final bench =
        viewModel.personalRecords.firstWhere((pr) => pr.exerciseId == 1);
    expect(bench.weight, 90);
    expect(bench.reps, 4);
  });
}
