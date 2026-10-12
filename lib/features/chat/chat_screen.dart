import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../streaks/streak_providers.dart';
import 'chat_reports.dart';

/// The Chat tab: a friendly summary of the week as quick report cards. Free
/// questions come in a later release (spec 3), so the message box is shown
/// switched off rather than pretending to work.
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      'Questions are coming in a later update',
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
