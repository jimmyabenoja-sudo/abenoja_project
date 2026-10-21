import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abenoja_project/app.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SmartTrackApp());
  }

  testWidgets('Login first, Sign In opens the home dashboard', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Sign in to SmartTrack'), findsOneWidget);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Jimmy D. Abenoja!'), findsOneWidget);
  });

  testWidgets('Home Quick Action opens the Report Form with EMPTY state', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('File a Report'));
    await tester.tap(find.text('File a Report'));
    await tester.pumpAndSettle();

    expect(find.text('Travel Report Form'), findsOneWidget);
    expect(find.text('No reports yet'), findsOneWidget);
  });

  testWidgets('Sidebar Reports menu opens the Report Form',
      (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Reports'));
    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();

    expect(find.text('Travel Report Form'), findsOneWidget);
    expect(find.text('No reports yet'), findsOneWidget);
  });

  testWidgets('Empty form shows field-level validation errors', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('File a Report'));
    await tester.tap(find.text('File a Report'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Submit Report'));
    await tester.tap(find.text('Submit Report'));
    await tester.pumpAndSettle();

    expect(find.text('Report title is required.'), findsOneWidget);
    expect(find.text('Please select a category.'), findsOneWidget);
    expect(find.text('Destination is required.'), findsOneWidget);
    expect(find.text('Description is required.'), findsOneWidget);
  });

  testWidgets('Valid submit shows LOADING then SUCCESS', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('File a Report'));
    await tester.tap(find.text('File a Report'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Report Title'));
    await tester.enterText(find.byType(TextFormField).at(0), 'Delayed flight');
    await tester.tap(find.text('Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Travel Record'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Narita Airport, Japan',
    );
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Flight was delayed for more than six hours.',
    );

    await tester.ensureVisible(find.text('Submit Report'));
    await tester.tap(find.text('Submit Report'));
    await tester.pump(); // state -> loading
    expect(find.text('Submitting...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    await tester.pump(const Duration(seconds: 4)); // finish the delay
    await tester.pumpAndSettle();

    expect(find.text('Report Submitted Successfully'), findsOneWidget);
    expect(find.text('1 record(s)'), findsOneWidget);
  });

  testWidgets('Simulated failure shows ERROR with a Retry action', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('File a Report'));
    await tester.tap(find.text('File a Report'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Simulate failure (demo)'));
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Report Title'));
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Lost baggage claim',
    );
    await tester.tap(find.text('Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Travel Record'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Bangkok, Thailand',
    );
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Baggage was not released upon arrival at the airport.',
    );

    await tester.ensureVisible(find.text('Submit Report'));
    await tester.tap(find.text('Submit Report'));
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('Submission Failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
