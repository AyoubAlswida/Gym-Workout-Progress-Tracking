import 'package:flutter/foundation.dart';
import '../models/workout_session.dart';
import '../repositories/workout_repository.dart';

class WorkoutViewModel extends ChangeNotifier {
  final WorkoutRepository _repository = WorkoutRepository();

  List<WorkoutSession> _sessions = [];
  List<WorkoutSession> get sessions => _sessions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();

    _sessions = await _repository.getSessions();
    
    _isLoading = false;
    notifyListeners();
  }

  // Used for the bar chart showing completed workouts this week
  int get workoutsCompletedThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return _sessions.where((s) {
      final sessionDate = DateTime.parse(s.date);
      return sessionDate.isAfter(startOfWeek) || sessionDate.isAtSameMomentAs(startOfWeek);
    }).length;
  }
}
