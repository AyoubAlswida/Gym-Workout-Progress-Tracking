import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_workout_tracking/models/body_measurement.dart';
import 'package:gym_workout_tracking/repositories/measurement_repository.dart';

import '../test_db_helper.dart';

void main() {
  late Directory tempDir;
  late MeasurementRepository repository;

  setUp(() async {
    tempDir = await setupTestDatabase();
    repository = MeasurementRepository();
  });

  tearDown(() async {
    await teardownTestDatabase(tempDir);
  });

  test('measurement with partial circumferences round-trips', () async {
    await repository.insertMeasurement(BodyMeasurement(
      date: '2026-06-01T10:00:00.000',
      bodyWeight: 75,
      bodyFatPercentage: 15,
      waist: 82.5,
      arms: 38,
      // chest, hips, thighs intentionally omitted.
    ));

    final stored = (await repository.getMeasurements()).single;
    expect(stored.bodyWeight, 75);
    expect(stored.waist, 82.5);
    expect(stored.arms, 38);
    expect(stored.chest, isNull);
    expect(stored.hips, isNull);
    expect(stored.thighs, isNull);
  });

  test('latest measurement ordering is unaffected by new columns', () async {
    await repository.insertMeasurement(BodyMeasurement(
        date: '2026-06-01T10:00:00.000', bodyWeight: 75, bodyFatPercentage: 15));
    await repository.insertMeasurement(BodyMeasurement(
        date: '2026-06-08T10:00:00.000',
        bodyWeight: 74,
        bodyFatPercentage: 14.5,
        waist: 81));

    final latest = await repository.getLatestMeasurement();
    expect(latest!.bodyWeight, 74);
    expect(latest.waist, 81);
  });
}
