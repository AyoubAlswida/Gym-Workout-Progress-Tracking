import '../core/database/db_helper.dart';
import '../models/body_measurement.dart';

class MeasurementRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertMeasurement(BodyMeasurement measurement) async {
    final db = await dbHelper.database;
    return await db.insert('body_measurements', measurement.toMap());
  }

  Future<List<BodyMeasurement>> getMeasurements() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('body_measurements', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => BodyMeasurement.fromMap(maps[i]));
  }

  Future<BodyMeasurement?> getLatestMeasurement() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'body_measurements', 
      orderBy: 'date DESC',
      limit: 1
    );
    if (maps.isNotEmpty) {
      return BodyMeasurement.fromMap(maps.first);
    }
    return null;
  }
}
