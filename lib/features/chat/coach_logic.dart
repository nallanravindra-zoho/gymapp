import '../goals/goal_logic.dart';

/// The questions the coach answers. Every answer is worked out on the phone
/// from the person's own goals and logs; no service or key is involved.
enum CoachQuestion { weekProgress, needAttention, sleep, nextStep }

extension CoachQuestionText on CoachQuestion {
  String get label => switch (this) {
    CoachQuestion.weekProgress => 'How am I doing this week?',
    CoachQuestion.needAttention => 'Which goals need attention?',
    CoachQuestion.sleep => 'How consistent was my sleep?',
    CoachQuestion.nextStep => 'Suggest one small next step.',
  };
}

/// What the coach can see.
class CoachData {
  const CoachData({
    required this.weekLabel,
    required this.goals,
    this.sleepOnSchedule,
    this.sleepDays = 0,
  });

  /// `11 – 17 May`, the week the goals are measured over.
  final String weekLabel;

  /// Goal progress for the week so far.
  final List<CategoryGoal> goals;

  /// Nights within tolerance of the bedtime and wake targets, out of
  /// [sleepDays]; null when no sleep is logged.
  final int? sleepOnSchedule;
  final int sleepDays;
}

/// An answer and the data it came from, so nothing is claimed without a source.
class CoachAnswer {
  const CoachAnswer({required this.text, required this.basis});
  final String text;
  final String basis;
}

/// Shown under every answer.
const coachDisclaimer = 'General wellness suggestions, not medical advice.';

String _what(CategoryGoal g) => '${g.met} of ${g.total} ${g.unit}';

String _step(GoalCategory c) => switch (c) {
  GoalCategory.workout => 'A short walk or a few stretches would count.',
  GoalCategory.habits => 'Log one habit you have not done yet today.',
  GoalCategory.sleep => 'Aim to keep tonight’s bedtime close to your target.',
  GoalCategory.screen => 'Try one screen-free break this evening.',
  GoalCategory.nutrition => 'Log your next meal when you have it.',
  GoalCategory.hobbies => 'Ten minutes on a hobby is a start.',
};

CoachAnswer answerFor(CoachQuestion q, CoachData d) {
  final goalsBasis =
      'Based on your goals and logs for ${d.weekLabel}. The week is still '
      'in progress.';
  const noGoals = CoachAnswer(
    text:
        'You have not set any goals yet. Set one under Goals and I can '
        'report on it.',
    basis: 'No goals are set.',
  );

  switch (q) {
    case CoachQuestion.weekProgress:
      if (d.goals.isEmpty) return noGoals;
      final percent = overallPercent(d.goals)!;
      final lines = d.goals.map((g) => '${g.category.label}: ${_what(g)}');
      return CoachAnswer(
        text:
            '$percent% of your goals are met so far this week.\n'
            '${lines.join('\n')}',
        basis: goalsBasis,
      );

    case CoachQuestion.needAttention:
      if (d.goals.isEmpty) return noGoals;
      final open = d.goals.where((g) => g.fraction < 1).toList()
        ..sort((a, b) => a.fraction.compareTo(b.fraction));
      if (open.isEmpty) {
        return CoachAnswer(
          text: 'All of your goals are met so far this week.',
          basis: goalsBasis,
        );
      }
      return CoachAnswer(
        text:
            'Furthest from target:\n'
            '${open.take(3).map((g) => '${g.category.label}: ${_what(g)}').join('\n')}',
        basis: goalsBasis,
      );

    case CoachQuestion.sleep:
      final n = d.sleepOnSchedule;
      if (n == null) {
        return const CoachAnswer(
          text:
              'No sleep is logged in the last 7 days, so there is nothing to '
              'report yet.',
          basis: 'Based on your sleep logs for the last 7 days.',
        );
      }
      return CoachAnswer(
        text: '$n of ${d.sleepDays} days on schedule.',
        basis:
            'Based on your last 7 sleep logs and your bedtime and wake '
            'targets, within 30 minutes.',
      );

    case CoachQuestion.nextStep:
      if (d.goals.isEmpty) return noGoals;
      final open = d.goals.where((g) => g.fraction < 1).toList()
        ..sort((a, b) => a.fraction.compareTo(b.fraction));
      if (open.isEmpty) {
        return CoachAnswer(
          text: 'Your goals are all met for now. Nothing more is needed.',
          basis: goalsBasis,
        );
      }
      final g = open.first;
      return CoachAnswer(
        text:
            '${g.category.label} is furthest from its target. ${_step(g.category)}',
        basis: goalsBasis,
      );
  }
}
