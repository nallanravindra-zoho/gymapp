import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/time/local_date.dart';
import '../../core/widgets/avatar_button.dart';
import '../../data/app_database.dart';
import '../../data/seed_tips.dart';
import '../week/day_sheet.dart' show monthNames;
import '../workouts/workout_providers.dart';
import 'insight_builder.dart';
import 'insight_rules.dart';
import 'insights_providers.dart';

String _range(String weekStart) {
  final a = parseLocalDate(weekStart);
  final b = parseLocalDate(shiftLocalDate(weekStart, 6));
  return a.month == b.month
      ? '${a.day} – ${b.day} ${monthNames[b.month - 1]}'
      : '${a.day} ${monthNames[a.month - 1]} – ${b.day} ${monthNames[b.month - 1]}';
}

String _minutes(int m) {
  final h = m ~/ 60;
  final r = m % 60;
  if (h == 0) return '$r min';
  return r == 0 ? '$h h' : '$h h $r min';
}

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(insightsViewProvider);
    final mode = ref.watch(insightWeekProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: const [AvatarButton()],
      ),
      body: view == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                SegmentedButton<InsightWeek>(
                  segments: const [
                    ButtonSegment(
                      value: InsightWeek.last,
                      label: Text('Last week'),
                    ),
                    ButtonSegment(
                      value: InsightWeek.current,
                      label: Text('This week'),
                    ),
                  ],
                  selected: {mode},
                  onSelectionChanged: (s) =>
                      ref.read(insightWeekProvider.notifier).set(s.first),
                ),
                const SizedBox(height: 12),
                _RecapCard(recap: view.recap),
                const SizedBox(height: 20),
                Text('Your patterns', style: text.titleLarge),
                const SizedBox(height: 8),
                if (view.insights.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Text(
                      'No insights for this week yet.',
                      style: text.bodySmall,
                    ),
                  )
                else
                  for (final i in view.insights) _InsightCard(insight: i),
                if (view.tips.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('Tips', style: text.titleLarge),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var n = 0; n < view.tips.length; n++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    child: Text(
                                      '${n + 1}.',
                                      style: text.bodySmall,
                                    ),
                                  ),
                                  Expanded(child: Text(view.tips[n].text)),
                                ],
                              ),
                            ),
                          Text(tipFooter, style: text.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});
  final Insight insight;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(insightIcon(insight.key), color: t.accent),
              const SizedBox(width: 12),
              Expanded(child: Text(insightText(insight))),
            ],
          ),
        ),
      ),
    );
  }
}

/// `Week summary`: the week in five numbers (spec 7.9).
class _RecapCard extends ConsumerWidget {
  const _RecapCard({required this.recap});
  final WeekRecap recap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final types = {
      for (final t
          in ref.watch(workoutTypesProvider).value ?? const <WorkoutType>[])
        t.id: t,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Week summary', style: text.titleLarge),
            Text(_range(recap.weekStart), style: text.bodySmall),
            const SizedBox(height: 12),
            if (recap.isEmpty)
              Text('No workouts logged this week.', style: text.bodyMedium)
            else
              Wrap(
                spacing: 24,
                runSpacing: 12,
                children: [
                  _Stat(value: '${recap.activeDays}', label: 'Active days'),
                  _Stat(
                    value: _minutes(recap.totalMinutes),
                    label: 'Total minutes',
                  ),
                  _Stat(
                    value: types[recap.topTypeId]?.name ?? 'None',
                    label: 'Top workout',
                  ),
                  _Stat(
                    value: '${recap.longestStreak} days',
                    label: 'Longest streak',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: text.titleLarge),
        Text(label, style: text.bodySmall),
      ],
    );
  }
}
