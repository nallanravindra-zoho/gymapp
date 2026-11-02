import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../week/week_providers.dart';
import 'goal_logic.dart';
import 'goal_progress_screen.dart';
import 'goal_providers.dart';
import 'set_goal_screen.dart';

/// Home: today's progress against goals, the goals themselves, and at most
/// one rule-based suggestion.
class HomeGoalsCard extends ConsumerWidget {
  const HomeGoalsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayDateProvider).value;
    if (today == null) return const SizedBox.shrink();
    final day = ref.watch(goalSummaryProvider((GoalPeriod.day, today)));
    final week = ref.watch(goalSummaryProvider((GoalPeriod.week, today)));
    final text = Theme.of(context).textTheme;
    final t = context.tokens;

    // Daily goals show today. Weekly goals (workout sessions, weekly
    // hobbies) only exist in the week view, so they show their week so far.
    final dayByCat = {for (final g in day.categories) g.category: g};
    final rows = <(CategoryGoal, bool)>[
      for (final w in week.categories)
        if (dayByCat[w.category] != null)
          (dayByCat[w.category]!, true)
        else
          (w, false),
    ];

    final metCount = rows.where((r) => r.$1.fraction >= 1).length;

    void openProgress() => Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const GoalProgressScreen()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SoftCard(
          onTap: openProgress,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Today’s goal progress',
                      style: text.titleSmall,
                    ),
                  ),
                  if (rows.isNotEmpty)
                    Text('$metCount of ${rows.length}', style: text.titleSmall),
                ],
              ),
              const SizedBox(height: 10),
              if (rows.isEmpty)
                Text(
                  'Set a goal to see your progress here.',
                  style: text.bodyMedium?.copyWith(color: t.textMuted),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: metCount / rows.length,
                    minHeight: 8,
                    backgroundColor: t.track,
                    color: t.accent,
                  ),
                ),
            ],
          ),
        ),
        if (rows.isNotEmpty) ...[
          const SizedBox(height: 16),
          const SectionTitle('Your goals for today'),
          SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  _Row(goal: rows[i].$1, daily: rows[i].$2),
                  if (i < rows.length - 1) const RowDivider(indent: 52),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          SoftCard(
            shadow: false,
            color: t.cat(Cat.hobby).tint.withValues(alpha: 0.5),
            child: Row(
              children: [
                Icon(
                  Icons.tips_and_updates_outlined,
                  color: t.cat(Cat.hobby).icon,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    goalSuggestion([for (final r in rows) r.$1]),
                    style: text.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.goal, required this.daily});

  final CategoryGoal goal;
  final bool daily;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    final when = daily ? 'today' : 'this week';
    final detail = daily && goal.unit == 'days'
        ? (goal.fraction >= 1 ? 'Met today' : 'In progress today')
        : '${goal.met} of ${goal.total} ${goal.unit} $when';
    return Semantics(
      label: '${goal.category.label}, $detail, ${goal.percent} percent',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              TintedIcon(
                icon: goalIcon(goal.category),
                cat: goalCat(goal.category),
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.category.label, style: text.titleSmall),
                    Text(
                      detail,
                      style: text.bodySmall?.copyWith(color: t.textMuted),
                    ),
                  ],
                ),
              ),
              Text('${goal.percent}%', style: text.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
