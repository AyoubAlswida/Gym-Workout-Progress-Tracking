import '../fitness/one_rep_max.dart';

/// A single performance data point fed to the coach: the best set of a session.
/// History lists are expected oldest-first (the order analytics already uses).
class SetSnapshot {
  final double weight;
  final int reps;
  final DateTime date;

  SetSnapshot({required this.weight, required this.reps, required this.date});
}

/// Rep range that defines a training intent. Bounds are inclusive.
enum TrainingGoal {
  strength(4, 6),
  hypertrophy(8, 12),
  endurance(12, 20);

  const TrainingGoal(this.minReps, this.maxReps);

  final int minReps;
  final int maxReps;
}

/// Why the coach suggested what it did — drives the localized explanation.
enum SuggestionReason { addRep, increaseWeight, maintain }

class CoachSuggestion {
  final double weight;
  final int reps;
  final SuggestionReason reason;

  CoachSuggestion({
    required this.weight,
    required this.reps,
    required this.reason,
  });
}

/// Deterministic, rule-based progression coach (double-progression +
/// Epley 1RM). No external dependency — pure and fully unit-testable.
class CoachService {
  /// Weight increment per step: 2.5 kg or 5 lbs (the smallest plate jump most
  /// gyms support).
  static double stepFor(bool isMetric) => isMetric ? 2.5 : 5.0;

  static double _roundToStep(double value, double step) =>
      (value / step).round() * step;

  /// Suggests the next set using double progression: add a rep until the top
  /// of the goal's range is reached, then add weight and reset to the bottom.
  /// Returns null when there is no history to build on.
  CoachSuggestion? suggestNext(
    List<SetSnapshot> history, {
    required TrainingGoal goal,
    required bool isMetric,
  }) {
    if (history.isEmpty) return null;
    final last = history.last;

    if (last.reps >= goal.maxReps) {
      final step = stepFor(isMetric);
      return CoachSuggestion(
        weight: _roundToStep(last.weight + step, step),
        reps: goal.minReps,
        reason: SuggestionReason.increaseWeight,
      );
    }

    return CoachSuggestion(
      weight: last.weight,
      reps: last.reps + 1,
      reason: SuggestionReason.addRep,
    );
  }

  /// True when none of the last [window] sessions beat the best estimated 1RM
  /// achieved before it — i.e. strength has stalled. Needs at least
  /// [window] + 1 sessions to judge.
  bool detectPlateau(List<SetSnapshot> history, {int window = 3}) {
    if (history.length < window + 1) return false;
    const tolerance = 0.01;
    final e1rms =
        history.map((s) => estimate1Rm(s.weight, s.reps)).toList();

    for (var i = history.length - window; i < history.length; i++) {
      final bestBefore =
          e1rms.sublist(0, i).reduce((a, b) => a > b ? a : b);
      if (e1rms[i] > bestBefore + tolerance) return false;
    }
    return true;
  }
}
