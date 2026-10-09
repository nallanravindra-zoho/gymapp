/// Streak badge thresholds (spec 7.8). Each badge is awarded once.
const streakMilestones = [7, 30, 100];

String streakBadgeKey(String scope, int days) => 'streak_${scope}_$days';

/// Keys to award: every milestone reached by [currentStreak] that is not in
/// [alreadyAwarded]. Pure, so it is easy to test.
List<int> milestonesDue({
  required String scope,
  required int currentStreak,
  required Set<String> alreadyAwarded,
}) => [
  for (final m in streakMilestones)
    if (currentStreak >= m &&
        !alreadyAwarded.contains(streakBadgeKey(scope, m)))
      m,
];

/// Quiet one-line copy (spec 4.5).
String milestoneMessage(int days) => '$days-day streak reached.';
String streakMessage(int days) => '$days-day streak.';
