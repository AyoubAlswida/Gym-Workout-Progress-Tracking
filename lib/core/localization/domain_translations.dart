import '../../l10n/gen/app_localizations.dart';

/// Canonical key sets used by filters and form dropdowns.
const List<String> kCategories = [
  'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core', 'Cardio', 'Other',
];

const List<String> kMuscleGroups = [
  'Chest', 'Back', 'Quads', 'Hamstrings', 'Glutes', 'Calves',
  'Shoulders', 'Traps', 'Biceps', 'Triceps', 'Core', 'Other',
];

const List<String> kEquipment = [
  'Barbell', 'Dumbbell', 'Cable', 'Machine', 'Bodyweight', 'Other',
];

/// The database stores categories, muscle groups, equipment, and preset
/// routine names as stable English keys; these helpers map them to the
/// active locale. Unknown values (user-created) are shown as stored.
String localizedCategory(AppLocalizations l10n, String key) {
  switch (key) {
    case 'Chest':
      return l10n.catChest;
    case 'Back':
      return l10n.catBack;
    case 'Legs':
      return l10n.catLegs;
    case 'Shoulders':
      return l10n.catShoulders;
    case 'Arms':
      return l10n.catArms;
    case 'Core':
      return l10n.catCore;
    case 'Cardio':
      return l10n.catCardio;
    case 'Other':
      return l10n.catOther;
    default:
      return key;
  }
}

String localizedMuscleGroup(AppLocalizations l10n, String key) {
  switch (key) {
    case 'Chest':
      return l10n.muscleChest;
    case 'Back':
      return l10n.muscleBack;
    case 'Quads':
      return l10n.muscleQuads;
    case 'Hamstrings':
      return l10n.muscleHamstrings;
    case 'Glutes':
      return l10n.muscleGlutes;
    case 'Calves':
      return l10n.muscleCalves;
    case 'Shoulders':
      return l10n.muscleShoulders;
    case 'Traps':
      return l10n.muscleTraps;
    case 'Biceps':
      return l10n.muscleBiceps;
    case 'Triceps':
      return l10n.muscleTriceps;
    case 'Core':
      return l10n.muscleCore;
    case 'Other':
      return l10n.muscleOther;
    default:
      return key;
  }
}

String localizedEquipment(AppLocalizations l10n, String key) {
  switch (key) {
    case 'Barbell':
      return l10n.equipBarbell;
    case 'Dumbbell':
      return l10n.equipDumbbell;
    case 'Cable':
      return l10n.equipCable;
    case 'Machine':
      return l10n.equipMachine;
    case 'Bodyweight':
      return l10n.equipBodyweight;
    case 'Other':
      return l10n.equipOther;
    default:
      return key;
  }
}

String localizedRoutineName(AppLocalizations l10n, String name, bool isPreset) {
  if (!isPreset) return name;
  switch (name) {
    case 'Push Day':
      return l10n.routinePushDay;
    case 'Pull Day':
      return l10n.routinePullDay;
    case 'Legs':
      return l10n.routineLegs;
    case 'Full Body':
      return l10n.routineFullBody;
    default:
      return name;
  }
}
