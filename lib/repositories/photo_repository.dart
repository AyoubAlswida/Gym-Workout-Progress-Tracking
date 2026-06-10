import '../core/database/db_helper.dart';
import '../core/sync/sync_clock.dart';
import '../core/sync/sync_ids.dart';
import '../models/progress_photo.dart';

class PhotoRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertPhoto(ProgressPhoto photo) async {
    final db = await dbHelper.database;
    final map = photo.toMap()
      ..['uuid'] = photo.uuid ?? newUuid()
      ..['updatedAt'] = nowUtcIso()
      ..['isDirty'] = 1;
    return await db.insert('progress_photos', map);
  }

  Future<List<ProgressPhoto>> getPhotos() async {
    final db = await dbHelper.database;
    final maps = await db.query('progress_photos',
        where: 'isDeleted = 0', orderBy: 'date DESC, id DESC');
    return List.generate(maps.length, (i) => ProgressPhoto.fromMap(maps[i]));
  }

  /// Soft-deletes so the deletion propagates on sync.
  Future<void> deletePhoto(int id) async {
    final db = await dbHelper.database;
    await db.update(
      'progress_photos',
      {'isDeleted': 1, 'isDirty': 1, 'updatedAt': nowUtcIso()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
