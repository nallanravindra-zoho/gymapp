import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/time/local_date.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/app_database.dart';
import '../../data/seed_tips.dart';
import '../week/day_format.dart' show monthNames;
import '../metrics/metrics_charts.dart';
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

Cat _insightCat(String key) => switch (key) {
  'stretch_on_workout_days' => Cat.trophy,
  'active_days_change' => Cat.workout,
  'longest_gap' => Cat.neutral,
  'water_consistency' => Cat.water,
  'sleep_consistency' => Cat.sleep,
  'screen_time_late' => Cat.screen,
  _ => Cat.neutral,
};

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(insightsViewProvider);
    final mode = ref.watch(insightWeekProvider);
    final text = Theme.of(context).textTheme;
    final t = context.tokens;

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text('Insights'),
        ),
      ),
      body: view == null
          ? const SizedBox.shrink()
          : ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              children: [
                PillTabs<InsightWeek>(
                  outlined: true,
                  options: const {
                    InsightWeek.last: 'Last week',
                    InsightWeek.current: 'This week',
                  },
                  selected: mode,
                  onChanged: (m) =>
                      ref.read(insightWeekProvider.notifier).set(m),
                ),
                const SizedBox(height: 16),
                _RecapCard(recap: view.recap),
                const SizedBox(height: 14),
                const _MetricsLink(),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, color: t.text),
                    const SizedBox(width: 12),
                    Text('Your patterns', style: text.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                if (view.insights.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Text(
                      'No insights for this week yet.',
                      style: text.bodyMedium?.copyWith(color: t.textMuted),
                    ),
                  )
                else
                  for (final i in view.insights) _InsightCard(insight: i),
                if (view.tips.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text("This week's tips", style: text.titleMedium),
                  const SizedBox(height: 12),
                  for (var n = 0; n < view.tips.length; n++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SoftCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: t.cat(Cat.habit).tint,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${n + 1}',
                                style: text.titleSmall?.copyWith(
                                  color: t.cat(Cat.habit).icon,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  view.tips[n].text,
                                  style: text.bodyMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2, left: 4),
                    child: Text(tipFooter, style: text.bodySmall),
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
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TintedIcon(
              icon: insightIcon(insight.key),
              cat: _insightCat(insight.key),
              size: 46,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  insightText(insight),
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
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

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Week summary', style: text.titleMedium),
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

/// A link to the weight, BMI and body measurement charts (private metrics).
class _MetricsLink extends StatelessWidget {
  const _MetricsLink();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    return Semantics(
      button: true,
      label: 'Metrics, weight, BMI and body measurement charts',
      child: ExcludeSemantics(
        child: SoftCard(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const MetricsChartsScreen(),
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                const TintedIcon(
                  icon: Icons.show_chart_rounded,
                  cat: Cat.leaf,
                  size: 44,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Metrics', style: text.titleMedium),
                      Text(
                        'Weight, BMI and body measurements over time. '
                        'Private to you.',
                        style: text.bodySmall?.copyWith(color: t.textMuted),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: t.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
