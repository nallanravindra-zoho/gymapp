import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/theme/tokens.dart';

import 'test_helpers.dart';

void main() {
  appTest('shell shows five tabs and switches between them', (
    tester,
    db,
  ) async {
    for (final label in ['Today', 'Week', 'Groups', 'Insights', 'Chat']) {
      expect(find.text(label), findsWidgets);
    }
    await tester.tap(find.byIcon(Icons.group_outlined));
    await tester.pumpAndSettle();
    expect(find.text('No groups yet.'), findsOneWidget);
  });

  appTest('light mode resolves light tokens', (tester, db) async {
    final ctx = tester.element(find.byType(Scaffold).first);
    expect(ctx.tokens.bg, AppTokens.light.bg);
  });

  test('copy contains no exclamation marks', () {
    // Guard for the microcopy rule (spec 4.5); extended as screens land.
    const copy = [
      'No groups yet.',
      'No insights yet.',
      'Not available yet.',
      'Logged. 30 min yoga.',
      'Entry removed.',
      'End time must be after start time.',
    ];
    expect(copy.any((s) => s.contains('!')), isFalse);
  });
}
