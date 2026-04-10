class WorkoutSession {
  final int? id;
  final String date;
  final int duration; // in seconds
  final String routineName;

  WorkoutSession({
    this.id,
    required this.date,
    required this.duration,
    required this.routineName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'duration': duration,
      'routineName': routineName,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'],
      date: map['date'],
      duration: map['duration'],
      routineName: map['routineName'],
    );
  }
}
