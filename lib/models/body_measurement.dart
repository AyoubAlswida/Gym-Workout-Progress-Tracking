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
  // Sync metadata
  final String? uuid;
  final String? updatedAt;
  final bool isDirty;
  final bool isDeleted;

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
    this.uuid,
    this.updatedAt,
    this.isDirty = false,
    this.isDeleted = false,
  });

  BodyMeasurement copyWith({
    int? id,
    String? date,
    double? bodyWeight,
    double? bodyFatPercentage,
    double? waist,
    double? chest,
    double? arms,
    double? hips,
    double? thighs,
    String? uuid,
    String? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return BodyMeasurement(
      id: id ?? this.id,
      date: date ?? this.date,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      waist: waist ?? this.waist,
      chest: chest ?? this.chest,
      arms: arms ?? this.arms,
      hips: hips ?? this.hips,
      thighs: thighs ?? this.thighs,
      uuid: uuid ?? this.uuid,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

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
      'uuid': uuid,
      'updatedAt': updatedAt,
      'isDirty': isDirty ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
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
      uuid: map['uuid'],
      updatedAt: map['updatedAt'],
      isDirty: map['isDirty'] == 1,
      isDeleted: map['isDeleted'] == 1,
    );
  }
}
