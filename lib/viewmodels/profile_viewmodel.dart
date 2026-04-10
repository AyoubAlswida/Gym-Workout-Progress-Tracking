import 'package:flutter/foundation.dart';
import '../models/body_measurement.dart';
import '../repositories/measurement_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final MeasurementRepository _repository = MeasurementRepository();

  BodyMeasurement? _latestMeasurement;
  BodyMeasurement? get latestMeasurement => _latestMeasurement;

  List<BodyMeasurement> _measurements = [];
  List<BodyMeasurement> get measurements => _measurements;

  bool _isMetric = true; // true = KG, false = LBS
  bool get isMetric => _isMetric;

  Future<void> loadMeasurements() async {
    _measurements = await _repository.getMeasurements();
    _latestMeasurement = await _repository.getLatestMeasurement();
    notifyListeners();
  }

  Future<void> addMeasurement(double weight, double bodyFat) async {
    final newMeasurement = BodyMeasurement(
      date: DateTime.now().toIso8601String(),
      bodyWeight: weight,
      bodyFatPercentage: bodyFat,
    );
    await _repository.insertMeasurement(newMeasurement);
    await loadMeasurements();
  }

  void toggleUnits() {
    _isMetric = !_isMetric;
    notifyListeners();
  }
}
