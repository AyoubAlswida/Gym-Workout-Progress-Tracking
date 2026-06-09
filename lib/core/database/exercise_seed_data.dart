/// Built-in exercise catalog seeded into the database.
/// Names are stable English keys: user data references them by id, and the UI
/// localizes categories/muscle groups via lookup — never rename entries here.
const List<Map<String, String>> exerciseSeedData = [
  // Chest
  {'name': 'Bench Press', 'category': 'Chest', 'muscleGroup': 'Chest', 'equipment': 'Barbell'},
  {'name': 'Incline Bench Press', 'category': 'Chest', 'muscleGroup': 'Chest', 'equipment': 'Barbell'},
  {'name': 'Dumbbell Bench Press', 'category': 'Chest', 'muscleGroup': 'Chest', 'equipment': 'Dumbbell'},
  {'name': 'Incline Dumbbell Press', 'category': 'Chest', 'muscleGroup': 'Chest', 'equipment': 'Dumbbell'},
  {'name': 'Dumbbell Fly', 'category': 'Chest', 'muscleGroup': 'Chest', 'equipment': 'Dumbbell'},
  {'name': 'Cable Crossover', 'category': 'Chest', 'muscleGroup': 'Chest', 'equipment': 'Cable'},
  {'name': 'Chest Press Machine', 'category': 'Chest', 'muscleGroup': 'Chest', 'equipment': 'Machine'},
  {'name': 'Push Up', 'category': 'Chest', 'muscleGroup': 'Chest', 'equipment': 'Bodyweight'},
  {'name': 'Dips', 'category': 'Chest', 'muscleGroup': 'Chest', 'equipment': 'Bodyweight'},

  // Back
  {'name': 'Deadlift', 'category': 'Back', 'muscleGroup': 'Back', 'equipment': 'Barbell'},
  {'name': 'Pull Up', 'category': 'Back', 'muscleGroup': 'Back', 'equipment': 'Bodyweight'},
  {'name': 'Chin Up', 'category': 'Back', 'muscleGroup': 'Back', 'equipment': 'Bodyweight'},
  {'name': 'Barbell Row', 'category': 'Back', 'muscleGroup': 'Back', 'equipment': 'Barbell'},
  {'name': 'Dumbbell Row', 'category': 'Back', 'muscleGroup': 'Back', 'equipment': 'Dumbbell'},
  {'name': 'Lat Pulldown', 'category': 'Back', 'muscleGroup': 'Back', 'equipment': 'Cable'},
  {'name': 'Seated Cable Row', 'category': 'Back', 'muscleGroup': 'Back', 'equipment': 'Cable'},
  {'name': 'T-Bar Row', 'category': 'Back', 'muscleGroup': 'Back', 'equipment': 'Barbell'},
  {'name': 'Face Pull', 'category': 'Back', 'muscleGroup': 'Back', 'equipment': 'Cable'},

  // Legs
  {'name': 'Squat', 'category': 'Legs', 'muscleGroup': 'Quads', 'equipment': 'Barbell'},
  {'name': 'Front Squat', 'category': 'Legs', 'muscleGroup': 'Quads', 'equipment': 'Barbell'},
  {'name': 'Leg Press', 'category': 'Legs', 'muscleGroup': 'Quads', 'equipment': 'Machine'},
  {'name': 'Leg Extension', 'category': 'Legs', 'muscleGroup': 'Quads', 'equipment': 'Machine'},
  {'name': 'Romanian Deadlift', 'category': 'Legs', 'muscleGroup': 'Hamstrings', 'equipment': 'Barbell'},
  {'name': 'Leg Curl', 'category': 'Legs', 'muscleGroup': 'Hamstrings', 'equipment': 'Machine'},
  {'name': 'Walking Lunge', 'category': 'Legs', 'muscleGroup': 'Quads', 'equipment': 'Dumbbell'},
  {'name': 'Bulgarian Split Squat', 'category': 'Legs', 'muscleGroup': 'Quads', 'equipment': 'Dumbbell'},
  {'name': 'Hip Thrust', 'category': 'Legs', 'muscleGroup': 'Glutes', 'equipment': 'Barbell'},
  {'name': 'Calf Raise', 'category': 'Legs', 'muscleGroup': 'Calves', 'equipment': 'Machine'},
  {'name': 'Goblet Squat', 'category': 'Legs', 'muscleGroup': 'Quads', 'equipment': 'Dumbbell'},

  // Shoulders
  {'name': 'Overhead Press', 'category': 'Shoulders', 'muscleGroup': 'Shoulders', 'equipment': 'Barbell'},
  {'name': 'Dumbbell Shoulder Press', 'category': 'Shoulders', 'muscleGroup': 'Shoulders', 'equipment': 'Dumbbell'},
  {'name': 'Lateral Raise', 'category': 'Shoulders', 'muscleGroup': 'Shoulders', 'equipment': 'Dumbbell'},
  {'name': 'Front Raise', 'category': 'Shoulders', 'muscleGroup': 'Shoulders', 'equipment': 'Dumbbell'},
  {'name': 'Rear Delt Fly', 'category': 'Shoulders', 'muscleGroup': 'Shoulders', 'equipment': 'Dumbbell'},
  {'name': 'Arnold Press', 'category': 'Shoulders', 'muscleGroup': 'Shoulders', 'equipment': 'Dumbbell'},
  {'name': 'Upright Row', 'category': 'Shoulders', 'muscleGroup': 'Shoulders', 'equipment': 'Barbell'},
  {'name': 'Shrug', 'category': 'Shoulders', 'muscleGroup': 'Traps', 'equipment': 'Dumbbell'},

  // Arms
  {'name': 'Barbell Curl', 'category': 'Arms', 'muscleGroup': 'Biceps', 'equipment': 'Barbell'},
  {'name': 'Dumbbell Curl', 'category': 'Arms', 'muscleGroup': 'Biceps', 'equipment': 'Dumbbell'},
  {'name': 'Hammer Curl', 'category': 'Arms', 'muscleGroup': 'Biceps', 'equipment': 'Dumbbell'},
  {'name': 'Preacher Curl', 'category': 'Arms', 'muscleGroup': 'Biceps', 'equipment': 'Barbell'},
  {'name': 'Cable Curl', 'category': 'Arms', 'muscleGroup': 'Biceps', 'equipment': 'Cable'},
  {'name': 'Triceps Pushdown', 'category': 'Arms', 'muscleGroup': 'Triceps', 'equipment': 'Cable'},
  {'name': 'Skull Crusher', 'category': 'Arms', 'muscleGroup': 'Triceps', 'equipment': 'Barbell'},
  {'name': 'Overhead Triceps Extension', 'category': 'Arms', 'muscleGroup': 'Triceps', 'equipment': 'Dumbbell'},
  {'name': 'Close Grip Bench Press', 'category': 'Arms', 'muscleGroup': 'Triceps', 'equipment': 'Barbell'},

  // Core
  {'name': 'Plank', 'category': 'Core', 'muscleGroup': 'Core', 'equipment': 'Bodyweight'},
  {'name': 'Crunch', 'category': 'Core', 'muscleGroup': 'Core', 'equipment': 'Bodyweight'},
  {'name': 'Hanging Leg Raise', 'category': 'Core', 'muscleGroup': 'Core', 'equipment': 'Bodyweight'},
  {'name': 'Russian Twist', 'category': 'Core', 'muscleGroup': 'Core', 'equipment': 'Bodyweight'},
  {'name': 'Cable Crunch', 'category': 'Core', 'muscleGroup': 'Core', 'equipment': 'Cable'},
  {'name': 'Ab Wheel Rollout', 'category': 'Core', 'muscleGroup': 'Core', 'equipment': 'Other'},
];

/// Preset routines seeded on first run / upgrade.
/// Exercise references are by name and resolved to ids at seed time.
const List<Map<String, dynamic>> routineSeedData = [
  {
    'name': 'Push Day',
    'exercises': [
      {'name': 'Bench Press', 'sets': 4, 'reps': 8},
      {'name': 'Incline Dumbbell Press', 'sets': 3, 'reps': 10},
      {'name': 'Overhead Press', 'sets': 3, 'reps': 8},
      {'name': 'Lateral Raise', 'sets': 3, 'reps': 12},
      {'name': 'Triceps Pushdown', 'sets': 3, 'reps': 12},
    ],
  },
  {
    'name': 'Pull Day',
    'exercises': [
      {'name': 'Deadlift', 'sets': 3, 'reps': 5},
      {'name': 'Pull Up', 'sets': 4, 'reps': 8},
      {'name': 'Barbell Row', 'sets': 3, 'reps': 10},
      {'name': 'Face Pull', 'sets': 3, 'reps': 15},
      {'name': 'Barbell Curl', 'sets': 3, 'reps': 10},
    ],
  },
  {
    'name': 'Legs',
    'exercises': [
      {'name': 'Squat', 'sets': 4, 'reps': 6},
      {'name': 'Romanian Deadlift', 'sets': 3, 'reps': 10},
      {'name': 'Leg Press', 'sets': 3, 'reps': 12},
      {'name': 'Leg Curl', 'sets': 3, 'reps': 12},
      {'name': 'Calf Raise', 'sets': 4, 'reps': 15},
    ],
  },
  {
    'name': 'Full Body',
    'exercises': [
      {'name': 'Squat', 'sets': 3, 'reps': 8},
      {'name': 'Bench Press', 'sets': 3, 'reps': 8},
      {'name': 'Barbell Row', 'sets': 3, 'reps': 10},
      {'name': 'Overhead Press', 'sets': 2, 'reps': 10},
      {'name': 'Plank', 'sets': 3, 'reps': 1},
    ],
  },
];
