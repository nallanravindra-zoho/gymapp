import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/time/local_date.dart';
import '../../core/widgets/app_widgets.dart';
import '../goals/goal_logic.dart';
import '../goals/goal_providers.dart';
import '../sleep/sleep_providers.dart';
import '../streaks/streak_providers.dart';
import '../week/week_providers.dart';
import '../week/week_screen.dart' show formatWeekRange;
import 'chat_reports.dart';
import 'coach_logic.dart';

/// What the coach reads: this week's goal progress and sleep consistency.
final coachDataProvider = Provider<CoachData?>((ref) {
  final today = ref.watch(todayDateProvider).value;
  if (today == null) return null;
  final week = ref.watch(goalSummaryProvider((GoalPeriod.week, today)));
  final sleep = ref.watch(sleepConsistencyProvider);
  final hasSleep =
      sleep != null && !sleep.byDate.values.every((v) => v == null);
  return CoachData(
    weekLabel: formatWeekRange(weekStartOf(today)),
    goals: week.categories,
    sleepOnSchedule: hasSleep ? sleep.onSchedule : null,
    sleepDays: sleep?.days ?? 0,
  );
});

/// The Chat tab: quick report cards and a small set of questions the coach
/// answers from the person's own goals and logs. Free text needs a language
/// model, which this release does not use, so the message box stays off.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _asked = <CoachQuestion>[];
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Adds a question and brings its answer into view.
  void _ask(CoachQuestion q) {
    setState(() => _asked.add(q));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = ref.watch(chatReportsProvider);
    final name = ref.watch(userStreamProvider).value?.displayName.trim() ?? '';
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    String plural(int n, String one, String many) =>
        '$n ${n == 1 ? one : many}';

    final cards = <Widget>[
      if (r != null) ...[
        _ReportCard(
          icon: Icons.spa_rounded,
          cat: Cat.leaf,
          title: "This week's summary",
          detail:
              '${plural(r.workouts, 'workout', 'workouts')}  •  '
              '${plural(r.activeDays, 'active day', 'active days')}',
        ),
        _ReportCard(
          icon: Icons.emoji_events_rounded,
          cat: Cat.trophy,
          title: 'Longest streak',
          detail: r.longestStreakDays > 0
              ? '${r.longestStreakName ?? 'Workout'} – ${plural(r.longestStreakDays, 'day', 'days')}'
              : 'No streak yet',
        ),
        _ReportCard(
          icon: Icons.nightlight_round,
          cat: Cat.sleep,
          title: 'Sleep consistency',
          detail: r.sleepOnSchedule == null
              ? 'No sleep logged yet'
              : '${r.sleepOnSchedule} of ${r.sleepDays} days on schedule',
        ),
        _ReportCard(
          icon: Icons.smartphone_rounded,
          cat: Cat.screen,
          title: 'Screen time trend',
          detail: screenTimeTrendText(r.screenTimePercent),
        ),
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text('Chat'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                Row(
                  children: [
                    const TintedIcon(
                      icon: Icons.smart_toy_rounded,
                      cat: Cat.screen,
                      size: 64,
                      iconSize: 34,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: t.cat(Cat.screen).tint.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isEmpty ? 'Hi.' : 'Hi $name.',
                              style: text.titleSmall,
                            ),
                            Text(
                              'Here are your quick reports:',
                              style: text.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                for (final c in cards) ...[c, const SizedBox(height: 12)],
                const SizedBox(height: 6),
                Text('Ask the coach', style: text.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final q in CoachQuestion.values)
                      ActionChip(
                        label: Text(q.label),
                        onPressed: () => _ask(q),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final q in _asked) ...[
                  _Bubble(text: q.label, fromUser: true),
                  const SizedBox(height: 8),
                  _Bubble(
                    text: ref.watch(coachDataProvider) == null
                        ? ''
                        : answerFor(q, ref.watch(coachDataProvider)!).text,
                    basis: ref.watch(coachDataProvider) == null
                        ? null
                        : answerFor(q, ref.watch(coachDataProvider)!).basis,
                  ),
                  const SizedBox(height: 12),
                ],
                if (_asked.isNotEmpty)
                  Text(
                    coachDisclaimer,
                    style: text.bodySmall?.copyWith(color: t.textMuted),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              4,
              16,
              12 + MediaQuery.paddingOf(context).bottom * 0,
            ),
            child: Container(
              height: 58,
              padding: const EdgeInsets.only(left: 22, right: 8),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: t.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Choose a question above',
                      style: text.bodyMedium?.copyWith(color: t.textMuted),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: t.track,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      color: t.textMuted,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.icon,
    required this.cat,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final Cat cat;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        children: [
          TintedIcon(icon: icon, cat: cat, size: 52),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: text.bodyMedium?.copyWith(
                    color: context.tokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, this.fromUser = false, this.basis});

  final String text;
  final bool fromUser;
  final String? basis;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final style = Theme.of(context).textTheme;
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: fromUser ? t.accentSoft : t.cat(Cat.screen).tint,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: style.bodyMedium),
              if (basis != null) ...[
                const SizedBox(height: 6),
                Text(
                  basis!,
                  style: style.bodySmall?.copyWith(color: t.textMuted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
