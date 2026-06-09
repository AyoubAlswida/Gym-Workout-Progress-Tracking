class WorkoutSession {
  final int? id;
  final String date;
  final int duration; // in seconds
  final String routineName;
  final String? notes;

  WorkoutSession({
    this.id,
    required this.date,
    required this.duration,
    required this.routineName,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'duration': duration,
      'routineName': routineName,
      'notes': notes,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'],
      date: map['date'],
      duration: map['duration'],
      routineName: map['routineName'],
      notes: map['notes'],
    );
  }
}
