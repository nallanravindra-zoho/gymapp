import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/features/hobbies/chant_controller.dart';
import 'package:wellbeing/features/hobbies/chant_platform.dart';

import '../features/chant_test.dart' show FakeChantPlatform;

/// Opens the Hobbies screen from Today's quick tile.
Future<void> openHobbies(WidgetTester tester) async {
  // The entry may sit below the fold on Today.
  await tester.ensureVisible(find.text('Hobbies').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Hobbies').first);
  await tester.pumpAndSettle();
}

/// Opens Manage from the Hobbies screen.
Future<void> openManageHobbies(WidgetTester tester) async {
  await tester.tap(find.text('Manage'));
  await tester.pumpAndSettle();
}

/// Scrolls the current screen's list until [target] is visible.
Future<void> scrollTo(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

/// The one chant platform used by the current widget test.
late FakeChantPlatform testChant;

/// Gives the chant screen a fake microphone/sound platform (the real one
/// needs a phone). Use as `wrapApp:` of `appTest`.
Widget Function(Widget) withFakeChant() {
  testChant = FakeChantPlatform();
  return (app) => ProviderScope(
    overrides: [
      chantPlatformProvider.overrideWithValue(testChant as ChantPlatform),
      chantControllerProvider.overrideWith(ChantController.new),
    ],
    child: app,
  );
}
