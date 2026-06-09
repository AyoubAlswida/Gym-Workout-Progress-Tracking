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

  WorkoutSet({
    this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.weight,
    required this.reps,
    this.isCompleted = false,
    this.durationSeconds,
    this.distanceMeters,
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
    );
  }
}
