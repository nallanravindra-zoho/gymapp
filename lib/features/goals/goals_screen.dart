import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../habits/habit_providers.dart';
import '../hobbies/hobby_providers.dart';
import '../screen_time/screen_time_providers.dart';
import '../week/week_marks.dart' show sleepTargetMinutesProvider;
import '../week/week_providers.dart';
import '../week/week_screen.dart';
import 'goal_logic.dart';
import 'goal_progress_screen.dart';
import 'goal_providers.dart';
import 'set_goal_screen.dart';

enum _GoalsTab { goals, week }

/// Goals (overview) and the Week calendar, as two tabs of one destination.
class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  _GoalsTab _tab = _GoalsTab.goals;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text('Goals'),
        ),
        actions: [
          IconButton.filledTonal(
            tooltip: 'Set a goal',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SetGoalScreen()),
            ),
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your goals. Your progress.',
                  style: text.bodyMedium?.copyWith(color: t.textMuted),
                ),
                const SizedBox(height: 12),
                PillTabs<_GoalsTab>(
                  options: const {
                    _GoalsTab.goals: 'Goals',
                    _GoalsTab.week: 'Week',
                  },
                  selected: _tab,
                  onChanged: (v) => setState(() => _tab = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: _tab == _GoalsTab.goals
                ? const _GoalsOverview()
                : const WeekScreen(embedded: true),
          ),
        ],
      ),
    );
  }
}

String _hours(int minutes) {
  if (minutes < 60) return '$minutes min';
  final h = minutes / 60;
  final label = h == h.roundToDouble() ? '${h.round()}' : h.toStringAsFixed(1);
  return '$label ${h == 1 ? 'hour' : 'hours'}';
}

class _GoalsOverview extends ConsumerWidget {
  const _GoalsOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayDateProvider).value;
    if (today == null) return const SizedBox.shrink();
    final summary = ref.watch(goalSummaryProvider((GoalPeriod.week, today)));
    final byCategory = {for (final g in summary.categories) g.category: g};

    final workoutTarget = ref.watch(workoutGoalProvider).value;
    final habits = ref.watch(activeHabitsProvider).value ?? const [];
    final screenLimit = ref.watch(screenTimeGoalProvider).value;
    final nutritionTarget = ref.watch(nutritionGoalProvider).value;
    final hobbyGoals = ref.watch(hobbyGoalsProvider);
    final sleepMinutes = ref.watch(sleepTargetMinutesProvider);

    String? detail(GoalCategory c) => switch (c) {
      GoalCategory.workout =>
        workoutTarget == null
            ? null
            : '$workoutTarget ${workoutTarget == 1 ? 'session' : 'sessions'}'
                  ' per week',
      GoalCategory.habits =>
        habits.isEmpty
            ? null
            : habits.length == 1
            ? habits.first.name
            : 'Multiple goals',
      GoalCategory.sleep =>
        sleepMinutes > 0 ? '${_hours(sleepMinutes)} per night' : null,
      GoalCategory.screen =>
        screenLimit == null ? null : 'Under ${_hours(screenLimit)} daily',
      GoalCategory.nutrition =>
        nutritionTarget == null
            ? null
            : '$nutritionTarget ${nutritionTarget == 1 ? 'serving' : 'servings'} daily',
      GoalCategory.hobbies =>
        hobbyGoals.isEmpty
            ? null
            : '${hobbyGoals.length} ${hobbyGoals.length == 1 ? 'goal' : 'goals'}',
    };

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        for (final c in GoalCategory.values) ...[
          _GoalRow(
            category: c,
            detail: detail(c),
            progress: byCategory[c],
            onTap: () => openGoalEditor(context, c),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const GoalProgressScreen()),
          ),
          icon: const Icon(Icons.insights_rounded),
          label: const Text('See goal progress'),
        ),
      ],
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.category,
    required this.detail,
    required this.progress,
    required this.onTap,
  });

  final GoalCategory category;
  final String? detail;
  final CategoryGoal? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final cat = t.cat(goalCat(category));
    final p = progress;
    final count = p == null ? '' : '${p.met}/${p.total}';
    return Semantics(
      button: true,
      label: [
        category.label,
        detail ?? 'No goal yet',
        if (p != null) '${p.met} of ${p.total} ${p.unit} this week',
      ].join('. '),
      child: SoftCard(
        onTap: onTap,
        child: ExcludeSemantics(
          child: Row(
            children: [
              TintedIcon(icon: goalIcon(category), cat: goalCat(category)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.label, style: text.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      detail ?? 'Set a goal',
                      style: text.bodySmall?.copyWith(color: t.textMuted),
                    ),
                    if (p != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: p.fraction,
                          minHeight: 6,
                          backgroundColor: t.track,
                          color: cat.icon,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(count, style: text.titleSmall),
            ],
          ),
        ),
      ),
    );
  }
}
