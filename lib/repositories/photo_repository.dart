import '../core/database/db_helper.dart';
import '../models/progress_photo.dart';

class PhotoRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertPhoto(ProgressPhoto photo) async {
    final db = await dbHelper.database;
    return await db.insert('progress_photos', photo.toMap());
  }

  Future<List<ProgressPhoto>> getPhotos() async {
    final db = await dbHelper.database;
    final maps =
        await db.query('progress_photos', orderBy: 'date DESC, id DESC');
    return List.generate(maps.length, (i) => ProgressPhoto.fromMap(maps[i]));
  }

  Future<void> deletePhoto(int id) async {
    final db = await dbHelper.database;
    await db.delete('progress_photos', where: 'id = ?', whereArgs: [id]);
  }
}
