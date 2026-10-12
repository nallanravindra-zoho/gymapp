import 'package:flutter_test/flutter_test.dart';

/// Opens Profile & Settings from the avatar button on the current screen.
Future<void> openAccountHub(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Profile and settings').first);
  await tester.pumpAndSettle();
}

/// Opens a row of the Profile & Settings hub, e.g. 'Privacy & data'.
Future<void> openAccountRow(WidgetTester tester, String label) async {
  await openAccountHub(tester);
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// Opens a settings section screen (title equals [label]) from Today.
Future<void> openSettingsSection(WidgetTester tester, String label) =>
    openAccountRow(tester, label);

/// Opens a full screen from the Today quick-log tiles ('Healthy Habits',
/// 'Sleep', 'Screen Time').
Future<void> openQuickTile(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).first);
  await tester.pumpAndSettle();
}

/// Opens the Healthy Habits screen from Today.
Future<void> openHabits(WidgetTester tester) =>
    openQuickTile(tester, 'Healthy Habits');

/// Opens the Screen Time screen from Today.
Future<void> openScreenTime(WidgetTester tester) =>
    openQuickTile(tester, 'Screen Time');

/// Opens Account & sync from the hub.
Future<void> openSyncAccount(WidgetTester tester) =>
    openAccountRow(tester, 'Account & sync');

/// Goes back one screen with the app bar's back button.
Future<void> goBack(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
}
