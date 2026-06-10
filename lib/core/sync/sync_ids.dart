import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Fixed app namespace (a one-off v4) for deterministic v5 UUIDs. Preset rows
/// derive their UUID from their stable name under this namespace, so the same
/// preset gets a byte-identical UUID on every install — references to presets
/// resolve across devices without ever syncing the preset row itself.
const String kAppNamespace = 'b3f1c2a4-6d4e-4f2a-9c1b-7e8a0d5f3b21';

/// Deterministic UUID for a seeded exercise (stable as long as the seed
/// name never changes).
String presetExerciseUuid(String name) =>
    _uuid.v5(kAppNamespace, 'exercise:$name');

/// Deterministic UUID for a seeded routine.
String presetRoutineUuid(String name) =>
    _uuid.v5(kAppNamespace, 'routine:$name');

/// Random UUID for a freshly created user-owned row.
String newUuid() => _uuid.v4();
