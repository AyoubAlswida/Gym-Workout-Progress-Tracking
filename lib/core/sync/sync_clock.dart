/// The single clock for sync metadata. ISO-8601 UTC strings sort
/// lexicographically, so last-write-wins comparisons are plain string
/// comparisons.
String nowUtcIso() => DateTime.now().toUtc().toIso8601String();
