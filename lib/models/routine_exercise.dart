class RoutineExercise {
  final int? id;
  final int routineId;
  final int exerciseId;
  final int targetSets;
  final int targetReps;
  final int orderIndex;

  /// Filled by JOIN queries for display; not a column on routine_exercises.
  final String? exerciseName;

  // Sync metadata
  final String? uuid;
  final String? routineUuid;
  final String? exerciseUuid;
  final String? updatedAt;
  final bool isDirty;
  final bool isDeleted;

  RoutineExercise({
    this.id,
    required this.routineId,
    required this.exerciseId,
    required this.targetSets,
    required this.targetReps,
    required this.orderIndex,
    this.exerciseName,
    this.uuid,
    this.routineUuid,
    this.exerciseUuid,
    this.updatedAt,
    this.isDirty = false,
    this.isDeleted = false,
  });

  RoutineExercise copyWith({
    int? id,
    int? routineId,
    int? exerciseId,
    int? targetSets,
    int? targetReps,
    int? orderIndex,
    String? exerciseName,
    String? uuid,
    String? routineUuid,
    String? exerciseUuid,
    String? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return RoutineExercise(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      exerciseId: exerciseId ?? this.exerciseId,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      orderIndex: orderIndex ?? this.orderIndex,
      exerciseName: exerciseName ?? this.exerciseName,
      uuid: uuid ?? this.uuid,
      routineUuid: routineUuid ?? this.routineUuid,
      exerciseUuid: exerciseUuid ?? this.exerciseUuid,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routineId': routineId,
      'exerciseId': exerciseId,
      'targetSets': targetSets,
      'targetReps': targetReps,
      'orderIndex': orderIndex,
      'uuid': uuid,
      'routineUuid': routineUuid,
      'exerciseUuid': exerciseUuid,
      'updatedAt': updatedAt,
      'isDirty': isDirty ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
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
      uuid: map['uuid'],
      routineUuid: map['routineUuid'],
      exerciseUuid: map['exerciseUuid'],
      updatedAt: map['updatedAt'],
      isDirty: map['isDirty'] == 1,
      isDeleted: map['isDeleted'] == 1,
    );
  }
}
