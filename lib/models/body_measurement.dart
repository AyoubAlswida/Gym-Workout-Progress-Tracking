class BodyMeasurement {
  final int? id;
  final String date;
  final double bodyWeight;
  final double bodyFatPercentage;
  // Optional circumferences, stored in centimeters.
  final double? waist;
  final double? chest;
  final double? arms;
  final double? hips;
  final double? thighs;

  BodyMeasurement({
    this.id,
    required this.date,
    required this.bodyWeight,
    required this.bodyFatPercentage,
    this.waist,
    this.chest,
    this.arms,
    this.hips,
    this.thighs,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'bodyWeight': bodyWeight,
      'bodyFatPercentage': bodyFatPercentage,
      'waist': waist,
      'chest': chest,
      'arms': arms,
      'hips': hips,
      'thighs': thighs,
    };
  }

  factory BodyMeasurement.fromMap(Map<String, dynamic> map) {
    return BodyMeasurement(
      id: map['id'],
      date: map['date'],
      bodyWeight: map['bodyWeight'],
      bodyFatPercentage: map['bodyFatPercentage'],
      waist: map['waist'],
      chest: map['chest'],
      arms: map['arms'],
      hips: map['hips'],
      thighs: map['thighs'],
    );
  }
}
