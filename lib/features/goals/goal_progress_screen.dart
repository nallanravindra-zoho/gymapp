import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/time/local_date.dart';
import '../../core/widgets/app_widgets.dart';
import '../week/day_format.dart';
import '../week/week_providers.dart';
import 'goal_logic.dart';
import 'goal_providers.dart';
import 'set_goal_screen.dart';

const _short = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String _periodLabel(GoalPeriod period, String today) {
  final d = parseLocalDate(today);
  return switch (period) {
    GoalPeriod.day =>
      '${_short[d.weekday - 1]} ${d.day} ${monthNames[d.month - 1]}',
    GoalPeriod.week =>
      'Week of ${parseLocalDate(weekStartOf(today)).day} ${monthNames[parseLocalDate(weekStartOf(today)).month - 1]}',
    GoalPeriod.month => '${monthNames[d.month - 1]} ${d.year}',
  };
}

/// A ring with the share of goals met in the middle.
class GoalRing extends StatelessWidget {
  const GoalRing({super.key, required this.percent, this.size = 120});

  final int? percent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return Semantics(
      label: percent == null ? 'No goals set' : '$percent percent of goals met',
      child: ExcludeSemantics(
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: (percent ?? 0) / 100,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  backgroundColor: t.track,
                  color: t.accent,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    percent == null ? '–' : '$percent%',
                    style: text.headlineSmall,
                  ),
                  Text('Goals met', style: text.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Goal progress for a day, the week or the month, with a breakdown by
/// category and, for the week, by day. Used on its own screen and on
/// Insights.
class GoalProgressView extends ConsumerStatefulWidget {
  const GoalProgressView({super.key});

  @override
  ConsumerState<GoalProgressView> createState() => _GoalProgressViewState();
}

class _GoalProgressViewState extends ConsumerState<GoalProgressView> {
  GoalPeriod _period = GoalPeriod.week;

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayDateProvider).value;
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    if (today == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PillTabs<GoalPeriod>(
          options: const {
            GoalPeriod.day: 'Daily',
            GoalPeriod.week: 'Weekly',
            GoalPeriod.month: 'Monthly',
          },
          selected: _period,
          onChanged: (v) => setState(() => _period = v),
        ),
        const SizedBox(height: 16),
        _Body(period: _period, today: today),
        const SizedBox(height: 16),
        Text(
          'Progress is measured against each goal you set. A weekly goal '
          'shows how far along it is while the week is still going, and '
          'partial progress counts.',
          style: text.bodySmall?.copyWith(color: t.textMuted),
        ),
      ],
    );
  }
}

class GoalProgressScreen extends StatelessWidget {
  const GoalProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goal progress')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: const [GoalProgressView()],
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.period, required this.today});

  final GoalPeriod period;
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(goalSummaryProvider((period, today)));
    final text = Theme.of(context).textTheme;
    final t = context.tokens;

    if (summary.categories.isEmpty) {
      return SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No goals for this view yet', style: text.titleSmall),
            const SizedBox(height: 4),
            Text(
              period == GoalPeriod.day
                  ? 'Daily goals appear here. Weekly goals, such as workout '
                        'sessions, show in the weekly and monthly views.'
                  : 'Set a goal and its progress will appear here.',
              style: text.bodyMedium?.copyWith(color: t.textMuted),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SoftCard(
          child: Row(
            children: [
              GoalRing(percent: summary.percent),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_periodLabel(period, today), style: text.titleSmall),
                    const SizedBox(height: 8),
                    for (final g in summary.categories)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '${g.category.label}: ${g.met} of ${g.total} ${g.unit}',
                          style: text.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (period == GoalPeriod.week) ...[
          _WeekBreakdown(today: today),
          const SizedBox(height: 16),
        ],
        Text('Category progress', style: text.titleMedium),
        const SizedBox(height: 8),
        SoftCard(
          child: Column(
            children: [
              for (final g in summary.categories) ...[
                _CategoryBar(goal: g),
                if (g != summary.categories.last) const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.goal});

  final CategoryGoal goal;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final cat = t.cat(goalCat(goal.category));
    return Semantics(
      label: '${goal.category.label}, ${goal.percent} percent',
      child: ExcludeSemantics(
        child: Row(
          children: [
            Icon(goalIcon(goal.category), size: 20, color: cat.icon),
            const SizedBox(width: 10),
            SizedBox(
              width: 104,
              child: Text(goal.category.label, style: text.bodyMedium),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: goal.fraction,
                  minHeight: 8,
                  backgroundColor: t.track,
                  color: cat.icon,
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(
                '${goal.percent}%',
                textAlign: TextAlign.end,
                style: text.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekBreakdown extends ConsumerWidget {
  const _WeekBreakdown({required this.today});

  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(weekBreakdownProvider(today));
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    final status = {
      for (final e in days.entries)
        e.key: dayStatus(date: e.key, today: today, fraction: e.value),
    };
    int count(DayStatus s) => status.values.where((v) => v == s).length;

    Widget legend(String label, int n) => Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Text('$label $n', style: text.bodySmall),
    );

    if (days.values.every((v) => v == null)) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daily breakdown', style: text.titleMedium),
        const SizedBox(height: 8),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final e in days.entries)
                    _DayRing(
                      date: e.key,
                      fraction: e.value,
                      status: status[e.key]!,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                children: [
                  legend('Met', count(DayStatus.met)),
                  legend('Partly', count(DayStatus.partial)),
                  legend('Not met', count(DayStatus.missed)),
                ],
              ),
              Text(
                'Daily goals only.',
                style: text.bodySmall?.copyWith(color: t.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayRing extends StatelessWidget {
  const _DayRing({
    required this.date,
    required this.fraction,
    required this.status,
  });

  final String date;
  final double? fraction;
  final DayStatus status;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final upcoming = status == DayStatus.upcoming;
    final pct = ((fraction ?? 0) * 100).round();
    final weekday = _short[parseLocalDate(date).weekday - 1];
    return Semantics(
      label: upcoming ? '$weekday, upcoming' : '$weekday, $pct percent',
      child: ExcludeSemantics(
        child: Column(
          children: [
            Text(weekday, style: text.bodySmall),
            const SizedBox(height: 6),
            SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                value: upcoming ? 0 : (fraction ?? 0),
                strokeWidth: 5,
                backgroundColor: t.track,
                color: status == DayStatus.met ? t.accent : t.accentSoft,
              ),
            ),
            const SizedBox(height: 4),
            Text(upcoming ? '–' : '$pct%', style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}
