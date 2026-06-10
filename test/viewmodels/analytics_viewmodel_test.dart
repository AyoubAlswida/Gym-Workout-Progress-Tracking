import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_workout_tracking/core/coach/coach_service.dart';
import 'package:gym_workout_tracking/models/workout_session.dart';
import 'package:gym_workout_tracking/models/workout_set.dart';
import 'package:gym_workout_tracking/repositories/workout_repository.dart';
import 'package:gym_workout_tracking/viewmodels/analytics_viewmodel.dart';

import '../test_db_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AnalyticsViewModel viewModel;
  late WorkoutRepository repository;

  setUp(() async {
    tempDir = await setupTestDatabase();
    SharedPreferences.setMockInitialValues({});
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

  test('coach suggestion is built from the selected exercise history', () async {
    // Last session hit the hypertrophy ceiling (12 reps) at 80 kg.
    await insertCompletedSet(
        date: '2026-05-20T10:00:00.000', exerciseId: 1, weight: 80, reps: 8);
    await insertCompletedSet(
        date: '2026-06-01T10:00:00.000', exerciseId: 1, weight: 80, reps: 12);

    await viewModel.load();

    final s = viewModel.coachSuggestion;
    expect(s, isNotNull);
    expect(s!.reason, SuggestionReason.increaseWeight);
    expect(s.weight, 82.5);
    expect(s.reps, 8);
    expect(viewModel.isPlateau, isFalse);
  });

  test('flat estimated 1RM across recent sessions is a plateau', () async {
    // Peak then three sessions that never beat it.
    await insertCompletedSet(
        date: '2026-04-01T10:00:00.000', exerciseId: 1, weight: 80, reps: 8);
    await insertCompletedSet(
        date: '2026-04-08T10:00:00.000', exerciseId: 1, weight: 90, reps: 8);
    await insertCompletedSet(
        date: '2026-04-15T10:00:00.000', exerciseId: 1, weight: 88, reps: 8);
    await insertCompletedSet(
        date: '2026-04-22T10:00:00.000', exerciseId: 1, weight: 89, reps: 8);
    await insertCompletedSet(
        date: '2026-04-29T10:00:00.000', exerciseId: 1, weight: 90, reps: 8);

    await viewModel.load();

    expect(viewModel.isPlateau, isTrue);
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
