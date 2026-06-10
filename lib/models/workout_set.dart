class WorkoutSet {
  final int? id;
  final int sessionId;
  final int exerciseId;
  final double weight;
  final int reps;
  final bool isCompleted;
  // Cardio sets store duration/distance; strength sets leave them null.
  final int? durationSeconds;
  final double? distanceMeters;
  // Sync metadata
  final String? uuid;
  final String? sessionUuid;
  final String? exerciseUuid;
  final String? updatedAt;
  final bool isDirty;
  final bool isDeleted;

  WorkoutSet({
    this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.weight,
    required this.reps,
    this.isCompleted = false,
    this.durationSeconds,
    this.distanceMeters,
    this.uuid,
    this.sessionUuid,
    this.exerciseUuid,
    this.updatedAt,
    this.isDirty = false,
    this.isDeleted = false,
  });

  WorkoutSet copyWith({
    int? id,
    int? sessionId,
    int? exerciseId,
    double? weight,
    int? reps,
    bool? isCompleted,
    int? durationSeconds,
    double? distanceMeters,
    String? uuid,
    String? sessionUuid,
    String? exerciseUuid,
    String? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      uuid: uuid ?? this.uuid,
      sessionUuid: sessionUuid ?? this.sessionUuid,
      exerciseUuid: exerciseUuid ?? this.exerciseUuid,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'exerciseId': exerciseId,
      'weight': weight,
      'reps': reps,
      'isCompleted': isCompleted ? 1 : 0,
      'durationSeconds': durationSeconds,
      'distanceMeters': distanceMeters,
      'uuid': uuid,
      'sessionUuid': sessionUuid,
      'exerciseUuid': exerciseUuid,
      'updatedAt': updatedAt,
      'isDirty': isDirty ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      id: map['id'],
      sessionId: map['sessionId'],
      exerciseId: map['exerciseId'],
      weight: map['weight'],
      reps: map['reps'],
      isCompleted: map['isCompleted'] == 1,
      durationSeconds: map['durationSeconds'],
      distanceMeters: map['distanceMeters'],
      uuid: map['uuid'],
      sessionUuid: map['sessionUuid'],
      exerciseUuid: map['exerciseUuid'],
      updatedAt: map['updatedAt'],
      isDirty: map['isDirty'] == 1,
      isDeleted: map['isDeleted'] == 1,
    );
  }
}
