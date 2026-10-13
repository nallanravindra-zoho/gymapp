import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opens Profile & Settings from the avatar button on the current screen.
Future<void> openAccountHub(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Profile and settings').first);
  await tester.pumpAndSettle();
}

/// Opens a row of the Profile & Settings hub, e.g. 'Privacy & data'.
Future<void> openAccountRow(WidgetTester tester, String label) async {
  await openAccountHub(tester);
  const profileRows = {'My profile', 'Personal metrics', 'Body measurements'};
  if (label == 'Profile Management' || label == 'App Management') {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
    return;
  }
  // The hub has two entries; rows live one level down (R10).
  final target = label == 'Notifications' ? 'Reminders' : label;
  await tester.tap(
    find.text(
      profileRows.contains(target) ? 'Profile Management' : 'App Management',
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(target));
  await tester.pumpAndSettle();
}

/// Opens a settings section screen (title equals [label]) from Today.
Future<void> openSettingsSection(WidgetTester tester, String label) =>
    openAccountRow(tester, label);

/// Opens a full screen from the Today quick-log tiles ('Healthy Habits',
/// 'Sleep', 'Screen Time').
Future<void> openQuickTile(WidgetTester tester, String label) async {
  final tile = find.byKey(ValueKey('quick-$label'));
  await tester.ensureVisible(tile);
  await tester.pumpAndSettle();
  await tester.tap(tile);
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
