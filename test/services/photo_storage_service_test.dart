import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:gym_workout_tracking/services/photo_storage_service.dart';

void main() {
  late Directory tempDir;
  late PhotoStorageService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('photo_test_');
    service = PhotoStorageService(baseDirProvider: () async => tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('persistPhoto copies the source into managed storage', () async {
    final source = File(p.join(tempDir.path, 'source.jpg'));
    await source.writeAsBytes([1, 2, 3]);

    final stored = await service.persistPhoto(source.path);

    expect(stored, isNot(source.path));
    expect(p.dirname(stored), endsWith('progress_photos'));
    expect(await File(stored).readAsBytes(), [1, 2, 3]);
  });

  test('deletePhotoFile removes an existing file', () async {
    final source = File(p.join(tempDir.path, 'source.jpg'));
    await source.writeAsBytes([1]);
    final stored = await service.persistPhoto(source.path);
    expect(await File(stored).exists(), isTrue);

    await service.deletePhotoFile(stored);
    expect(await File(stored).exists(), isFalse);
  });

  test('deletePhotoFile on a missing path does not throw', () async {
    await service.deletePhotoFile(p.join(tempDir.path, 'nope.jpg'));
  });
}
