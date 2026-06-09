import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:gym_workout_tracking/core/database/db_helper.dart';

/// Points sqflite at an isolated temp directory and resets the singleton so
/// each test file starts from a fresh database.
Future<Directory> setupTestDatabase() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final dir = await Directory.systemTemp.createTemp('gym_test_');
  await databaseFactory.setDatabasesPath(dir.path);
  await DatabaseHelper.resetForTest();
  return dir;
}

Future<void> teardownTestDatabase(Directory dir) async {
  await DatabaseHelper.resetForTest();
  try {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  } on FileSystemException {
    // Windows can keep the db file locked briefly after close; the OS
    // temp cleaner reclaims it.
  }
}
