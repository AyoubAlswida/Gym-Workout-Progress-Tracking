import 'package:flutter_test/flutter_test.dart';
import 'package:gym_workout_tracking/core/coach/coach_service.dart';

void main() {
  final coach = CoachService();

  SetSnapshot snap(double weight, int reps, [int dayOffset = 0]) =>
      SetSnapshot(
        weight: weight,
        reps: reps,
        date: DateTime(2026, 6, 1).add(Duration(days: dayOffset)),
      );

  group('suggestNext', () {
    test('no history yields no suggestion', () {
      expect(
        coach.suggestNext([],
            goal: TrainingGoal.hypertrophy, isMetric: true),
        isNull,
      );
    });

    test('below the rep ceiling adds a rep at the same weight', () {
      final s = coach.suggestNext([snap(80, 8)],
          goal: TrainingGoal.hypertrophy, isMetric: true)!;
      expect(s.reason, SuggestionReason.addRep);
      expect(s.weight, 80);
      expect(s.reps, 9);
    });

    test('at the rep ceiling adds weight and resets to the floor (metric)', () {
      final s = coach.suggestNext([snap(80, 12)],
          goal: TrainingGoal.hypertrophy, isMetric: true)!;
      expect(s.reason, SuggestionReason.increaseWeight);
      expect(s.weight, 82.5); // +2.5 kg step
      expect(s.reps, 8); // hypertrophy floor
    });

    test('imperial uses a 5 lb step and rounds to it', () {
      // 82 lbs + 5 = 87, rounded to nearest 5 => 85.
      final s = coach.suggestNext([snap(82, 6)],
          goal: TrainingGoal.strength, isMetric: false)!;
      expect(s.reason, SuggestionReason.increaseWeight);
      expect(s.weight, 85);
      expect(s.reps, 4); // strength floor
    });

    test('metric rounds an off-step weight to the nearest 2.5', () {
      // 81 + 2.5 = 83.5, rounded to nearest 2.5 => 82.5 (83.5/2.5=33.4→33).
      final s = coach.suggestNext([snap(81, 20)],
          goal: TrainingGoal.endurance, isMetric: true)!;
      expect(s.weight, 82.5);
      expect(s.reps, 12); // endurance floor
    });

    test('goal range changes when the ceiling fires', () {
      // 6 reps is the ceiling for strength but mid-range for hypertrophy.
      final strength = coach.suggestNext([snap(100, 6)],
          goal: TrainingGoal.strength, isMetric: true)!;
      expect(strength.reason, SuggestionReason.increaseWeight);

      final hyper = coach.suggestNext([snap(100, 6)],
          goal: TrainingGoal.hypertrophy, isMetric: true)!;
      expect(hyper.reason, SuggestionReason.addRep);
      expect(hyper.reps, 7);
    });
  });

  group('detectPlateau', () {
    test('too little history is never a plateau', () {
      final history = [snap(80, 8, 0), snap(82, 8, 1), snap(84, 8, 2)];
      expect(coach.detectPlateau(history), isFalse);
    });

    test('steady gains are not a plateau', () {
      final history = [
        snap(80, 8, 0),
        snap(82, 8, 1),
        snap(84, 8, 2),
        snap(86, 8, 3),
      ];
      expect(coach.detectPlateau(history), isFalse);
    });

    test('three flat sessions after a peak is a plateau', () {
      final history = [
        snap(80, 8, 0),
        snap(90, 8, 1), // peak e1RM
        snap(88, 8, 2),
        snap(89, 8, 3),
        snap(90, 8, 4), // ties the peak, does not beat it
      ];
      expect(coach.detectPlateau(history), isTrue);
    });

    test('a fresh PR in the window breaks the plateau', () {
      final history = [
        snap(80, 8, 0),
        snap(90, 8, 1),
        snap(88, 8, 2),
        snap(89, 8, 3),
        snap(95, 8, 4), // new best
      ];
      expect(coach.detectPlateau(history), isFalse);
    });
  });
}
