import 'package:flutter_test/flutter_test.dart';
import 'package:gym_workout_tracking/core/sync/sync_ids.dart';

void main() {
  group('preset UUIDs are deterministic', () {
    test('same name yields the same exercise UUID', () {
      expect(presetExerciseUuid('Bench Press'),
          presetExerciseUuid('Bench Press'));
    });

    test('different names yield different UUIDs', () {
      expect(presetExerciseUuid('Bench Press'),
          isNot(presetExerciseUuid('Squat')));
    });

    test('exercise and routine namespaces do not collide', () {
      expect(presetExerciseUuid('Legs'), isNot(presetRoutineUuid('Legs')));
    });

    test('UUID is a well-formed 36-char string', () {
      final id = presetExerciseUuid('Deadlift');
      expect(id.length, 36);
      expect(id.split('-').length, 5);
    });
  });

  group('newUuid', () {
    test('generates unique values', () {
      final a = newUuid();
      final b = newUuid();
      expect(a, isNot(b));
      expect(a.length, 36);
    });
  });
}
