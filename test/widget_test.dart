import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gym_workout_tracking/main.dart';
import 'package:gym_workout_tracking/views/main_navigation.dart';

import 'test_db_helper.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await setupTestDatabase();
  });

  tearDown(() async {
    await teardownTestDatabase(tempDir);
  });

  testWidgets('app boots with bottom navigation in English', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const GymTrackerApp());
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Routines'), findsOneWidget);

    final context = tester.element(find.byType(MainNavigation));
    expect(Directionality.of(context), TextDirection.ltr);
  });

  testWidgets('Arabic locale renders RTL with translated labels', (tester) async {
    SharedPreferences.setMockInitialValues({'localeCode': 'ar'});
    await tester.pumpWidget(const GymTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('الروتينات'), findsOneWidget);

    final context = tester.element(find.byType(MainNavigation));
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
