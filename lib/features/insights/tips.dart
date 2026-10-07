import '../../data/app_database.dart';
import 'insight_rules.dart';

/// Up to this many tips are shown for a week (spec 7.7).
const maxTipsPerWeek = 3;

/// Insights whose tips lead, because they point to something to try. The
/// positive ones follow.
const _tipPriority = [
  'longest_gap',
  'screen_time_late',
  'sleep_consistency',
  'active_days_change',
  'stretch_on_workout_days',
  'water_consistency',
];

class WeeklyTip {
  const WeeklyTip({required this.insightKey, required this.text});
  final String insightKey;
  final String text;
}

/// Picks at most one tip per insight and at most [maxTipsPerWeek] overall.
///
/// The choice is stable for a given week, so the same tips show each time the
/// week is opened, and it rotates from one week to the next.
List<WeeklyTip> selectTips({
  required List<Insight> insights,
  required List<TipsLibraryData> library,
  required String weekStart,
}) {
  final keys = insights.map((i) => i.key).toSet();
  final ordered = [
    for (final k in _tipPriority)
      if (keys.contains(k)) k,
  ];

  final out = <WeeklyTip>[];
  for (final key in ordered) {
    if (out.length >= maxTipsPerWeek) break;
    final candidates = [
      for (final t in library)
        if (t.isActive && t.deletedAt == null && t.triggerKey == key) t,
    ]..sort((a, b) => a.id.compareTo(b.id));
    if (candidates.isEmpty) continue;
    final pick = candidates[_stableIndex('$weekStart|$key', candidates.length)];
    out.add(WeeklyTip(insightKey: key, text: pick.body));
  }
  return out;
}

/// A small deterministic hash, so the choice does not depend on Dart's
/// per-run hash codes.
int _stableIndex(String seed, int length) {
  var h = 17;
  for (final c in seed.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return h % length;
}
