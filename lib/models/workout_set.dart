class WorkoutSet {
  final int? id;
  final int sessionId;
  final int exerciseId;
  final double weight;
  final int reps;
  final bool isCompleted;

  WorkoutSet({
    this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.weight,
    required this.reps,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'exerciseId': exerciseId,
      'weight': weight,
      'reps': reps,
      'isCompleted': isCompleted ? 1 : 0,
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
    );
  }
}
