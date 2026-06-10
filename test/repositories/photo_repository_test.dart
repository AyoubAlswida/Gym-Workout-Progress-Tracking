import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_workout_tracking/models/progress_photo.dart';
import 'package:gym_workout_tracking/repositories/photo_repository.dart';

import '../test_db_helper.dart';

void main() {
  late Directory tempDir;
  late PhotoRepository repository;

  setUp(() async {
    tempDir = await setupTestDatabase();
    repository = PhotoRepository();
  });

  tearDown(() async {
    await teardownTestDatabase(tempDir);
  });

  test('insert, order newest-first, and delete', () async {
    await repository.insertPhoto(ProgressPhoto(
        date: '2026-06-01T08:00:00.000', filePath: '/a.jpg', note: 'front'));
    final id = await repository.insertPhoto(ProgressPhoto(
        date: '2026-06-08T08:00:00.000', filePath: '/b.jpg'));

    final photos = await repository.getPhotos();
    expect(photos.length, 2);
    expect(photos.first.filePath, '/b.jpg', reason: 'newest first');
    expect(photos.last.note, 'front');

    await repository.deletePhoto(id);
    final after = await repository.getPhotos();
    expect(after.length, 1);
    expect(after.single.filePath, '/a.jpg');
  });
}
