class BodyMeasurement {
  final int? id;
  final String date;
  final double bodyWeight;
  final double bodyFatPercentage;

  BodyMeasurement({
    this.id,
    required this.date,
    required this.bodyWeight,
    required this.bodyFatPercentage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'bodyWeight': bodyWeight,
      'bodyFatPercentage': bodyFatPercentage,
    };
  }

  factory BodyMeasurement.fromMap(Map<String, dynamic> map) {
    return BodyMeasurement(
      id: map['id'],
      date: map['date'],
      bodyWeight: map['bodyWeight'],
      bodyFatPercentage: map['bodyFatPercentage'],
    );
  }
}
