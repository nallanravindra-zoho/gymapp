import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Taps the Today quick-log tile (the first widget labelled [label]; the
/// summary card below repeats some of these names).
Future<void> tapQuickTile(WidgetTester tester, String label) async {
  final tile = find.byKey(ValueKey('quick-$label'));
  await tester.ensureVisible(tile);
  await tester.pumpAndSettle();
  await tester.tap(tile);
  await tester.pumpAndSettle();
}

/// Opens the Log Workout screen from Today's quick-log tile.
Future<void> openLogScreen(WidgetTester tester) =>
    tapQuickTile(tester, 'Workout');

/// Chooses a type and switches the Log Workout screen to manual entry.
Future<void> pickTypeManual(WidgetTester tester, String type) async {
  await tester.tap(find.text(type));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Or enter manually'));
  await tester.pumpAndSettle();
}

/// Scrolls the (lazy) Log Workout list until [target] is built and visible.
Future<void> scrollToLogItem(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

/// Scrolls the Log Workout form to its Save button and taps it.
Future<void> tapSave(WidgetTester tester) async {
  await scrollToLogItem(tester, find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

/// Today: open Log Workout, pick [type], enter manually, Save.
Future<void> logToday(WidgetTester tester, String type) async {
  await openLogScreen(tester);
  await pickTypeManual(tester, type);
  await tapSave(tester);
  // Let the "Logged." snackbar go; it covers the navigation bar.
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

/// Switches to the Week tab.
Future<void> openWeekTab(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Week'),
    ),
  );
  await tester.pumpAndSettle();
}
