class RoutineExercise {
  final int? id;
  final int routineId;
  final int exerciseId;
  final int targetSets;
  final int targetReps;
  final int orderIndex;

  /// Filled by JOIN queries for display; not a column on routine_exercises.
  final String? exerciseName;

  RoutineExercise({
    this.id,
    required this.routineId,
    required this.exerciseId,
    required this.targetSets,
    required this.targetReps,
    required this.orderIndex,
    this.exerciseName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routineId': routineId,
      'exerciseId': exerciseId,
      'targetSets': targetSets,
      'targetReps': targetReps,
      'orderIndex': orderIndex,
    };
  }

  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    return RoutineExercise(
      id: map['id'],
      routineId: map['routineId'],
      exerciseId: map['exerciseId'],
      targetSets: map['targetSets'],
      targetReps: map['targetReps'],
      orderIndex: map['orderIndex'],
      exerciseName: map['exerciseName'],
    );
  }
}
