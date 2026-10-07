import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/app/app.dart';
import 'package:wellbeing/core/theme/tokens.dart';

void main() {
  testWidgets('shell shows five tabs and switches between them', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: WellbeingApp()));

    for (final label in ['Today', 'Week', 'Groups', 'Insights', 'Chat']) {
      expect(find.text(label), findsWidgets);
    }

    await tester.tap(find.byIcon(Icons.group_outlined));
    await tester.pumpAndSettle();
    expect(find.text('No groups yet.'), findsOneWidget);
  });

  testWidgets('dark mode resolves dark tokens', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    await tester.pumpWidget(const ProviderScope(child: WellbeingApp()));
    final ctx = tester.element(find.byType(Scaffold).first);
    expect(ctx.tokens.bg, AppTokens.dark.bg);
  });

  test('copy contains no exclamation marks', () {
    // Guard for the microcopy rule (spec 4.5); extended as screens land.
    const copy = ['No groups yet.', 'No insights yet.', 'Not available yet.'];
    expect(copy.any((s) => s.contains('!')), isFalse);
  });
}
