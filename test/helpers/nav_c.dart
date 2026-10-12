import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/features/groups/groups_ui.dart';

/// Opens the "+" action on the Groups screen and picks [label]
/// ('Create group' or 'Join with a code'). In the empty state those are plain
/// buttons, so use a direct tap there instead.
Future<void> addGroupAction(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Add group'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// Rows of the first leaderboard card as "rank name", top to bottom. Reads
/// the semantic label each row carries ("1, Ben, 5 days").
List<String> leaderboardRowsOf(WidgetTester tester) {
  final card = find.byType(LeaderboardCard).first;
  final labels = find.descendant(of: card, matching: find.byType(Semantics));
  final out = <String>[];
  for (final e in labels.evaluate()) {
    final label = (e.widget as Semantics).properties.label;
    if (label == null) continue;
    final m = RegExp(r'^(\d+), (.*), [^,]+$').firstMatch(label);
    if (m != null) out.add('${m.group(1)} ${m.group(2)}');
  }
  return out;
}
