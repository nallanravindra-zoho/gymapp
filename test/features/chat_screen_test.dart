import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  appTest('the Chat tab shows the quick reports and a switched-off box', (
    tester,
    db,
  ) async {
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.text('Here are your quick reports:'), findsOneWidget);
    expect(find.text("This week's summary"), findsOneWidget);
    expect(find.text('Longest streak'), findsOneWidget);
    expect(find.text('Sleep consistency'), findsOneWidget);
    expect(find.text('Screen time trend'), findsOneWidget);

    // With no data, each card says so plainly.
    expect(find.textContaining('0 workouts'), findsOneWidget);
    expect(find.text('No streak yet'), findsOneWidget);
    expect(find.text('No sleep logged yet'), findsOneWidget);
    expect(find.text('Not enough data yet'), findsOneWidget);

    // Free questions are not available yet, and the box does not pretend.
    expect(find.text('Questions are coming in a later update'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
