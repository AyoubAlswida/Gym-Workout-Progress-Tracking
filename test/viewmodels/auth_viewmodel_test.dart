import 'package:flutter_test/flutter_test.dart';
import 'package:gym_workout_tracking/viewmodels/auth_viewmodel.dart';

import '../fakes/fake_auth_api.dart';

void main() {
  late FakeAuthApi auth;

  setUp(() => auth = FakeAuthApi());
  tearDown(() => auth.dispose());

  test('starts signed out', () {
    final vm = AuthViewModel(auth: auth);
    expect(vm.isSignedIn, isFalse);
    expect(vm.user, isNull);
  });

  test('successful sign-in sets the user and triggers initial sync', () async {
    var syncCalls = 0;
    final vm = AuthViewModel(auth: auth, onSignedIn: () async => syncCalls++);

    final ok = await vm.signIn('a@b.com', 'pw');
    // Let the authState stream deliver the change.
    await Future.delayed(Duration.zero);

    expect(ok, isTrue);
    expect(vm.isSignedIn, isTrue);
    expect(vm.user!.email, 'a@b.com');
    expect(syncCalls, 1, reason: 'sign-in should kick off a first sync');
  });

  test('failed sign-in surfaces an error and stays signed out', () async {
    auth.failNext = true;
    final vm = AuthViewModel(auth: auth);

    final ok = await vm.signIn('a@b.com', 'pw');

    expect(ok, isFalse);
    expect(vm.error, isNotNull);
    expect(vm.isSignedIn, isFalse);
    expect(vm.isLoading, isFalse);
  });

  test('sign-out clears the user', () async {
    final vm = AuthViewModel(auth: auth);
    await vm.signIn('a@b.com', 'pw');
    await Future.delayed(Duration.zero);
    expect(vm.isSignedIn, isTrue);

    await vm.signOut();
    await Future.delayed(Duration.zero);
    expect(vm.isSignedIn, isFalse);
  });
}
