class WorkoutSession {
  final int? id;
  final String date;
  final int duration; // in seconds
  final String routineName;
  final String? notes;
  // Sync metadata
  final String? uuid;
  final String? updatedAt;
  final bool isDirty;
  final bool isDeleted;

  WorkoutSession({
    this.id,
    required this.date,
    required this.duration,
    required this.routineName,
    this.notes,
    this.uuid,
    this.updatedAt,
    this.isDirty = false,
    this.isDeleted = false,
  });

  WorkoutSession copyWith({
    int? id,
    String? date,
    int? duration,
    String? routineName,
    String? notes,
    String? uuid,
    String? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      routineName: routineName ?? this.routineName,
      notes: notes ?? this.notes,
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
      'duration': duration,
      'routineName': routineName,
      'notes': notes,
      'uuid': uuid,
      'updatedAt': updatedAt,
      'isDirty': isDirty ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'],
      date: map['date'],
      duration: map['duration'],
      routineName: map['routineName'],
      notes: map['notes'],
      uuid: map['uuid'],
      updatedAt: map['updatedAt'],
      isDirty: map['isDirty'] == 1,
      isDeleted: map['isDeleted'] == 1,
    );
  }
}
