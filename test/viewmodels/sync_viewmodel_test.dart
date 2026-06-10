import 'package:flutter_test/flutter_test.dart';
import 'package:gym_workout_tracking/viewmodels/sync_viewmodel.dart';

void main() {
  test('syncNow runs when allowed and records a timestamp', () async {
    var runs = 0;
    final vm = SyncViewModel(
      runSync: () async => runs++,
      canSync: () => true,
    );

    await vm.syncNow();

    expect(runs, 1);
    expect(vm.lastSyncedAt, isNotNull);
    expect(vm.lastError, isNull);
    expect(vm.isSyncing, isFalse);
  });

  test('syncNow is a no-op when gated off', () async {
    var runs = 0;
    final vm = SyncViewModel(
      runSync: () async => runs++,
      canSync: () => false,
    );

    await vm.syncNow();

    expect(runs, 0);
    expect(vm.lastSyncedAt, isNull);
  });

  test('a sync error is captured and clears the syncing flag', () async {
    final vm = SyncViewModel(
      runSync: () async => throw Exception('network down'),
      canSync: () => true,
    );

    await vm.syncNow();

    expect(vm.lastError, contains('network down'));
    expect(vm.isSyncing, isFalse);
    expect(vm.lastSyncedAt, isNull);
  });

  test('overlapping syncNow calls do not double-run', () async {
    var runs = 0;
    late SyncViewModel vm;
    vm = SyncViewModel(
      runSync: () async {
        runs++;
        // Re-enter while the first run is in flight.
        await vm.syncNow();
      },
      canSync: () => true,
    );

    await vm.syncNow();
    expect(runs, 1);
  });
}
