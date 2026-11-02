import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../habits/habit_manage_screen.dart';
import '../hobbies/hobby_manage_screen.dart';
import '../screen_time/screen_time_screen.dart';
import '../sleep/sleep_screen.dart';
import 'goal_logic.dart';
import 'goal_providers.dart';

IconData goalIcon(GoalCategory c) => switch (c) {
  GoalCategory.workout => Icons.directions_run_rounded,
  GoalCategory.habits => Icons.water_drop_outlined,
  GoalCategory.sleep => Icons.bedtime_outlined,
  GoalCategory.screen => Icons.smartphone_rounded,
  GoalCategory.hobbies => Icons.menu_book_outlined,
};

Cat goalCat(GoalCategory c) => switch (c) {
  GoalCategory.workout => Cat.workout,
  GoalCategory.habits => Cat.habit,
  GoalCategory.sleep => Cat.sleep,
  GoalCategory.screen => Cat.screen,
  GoalCategory.hobbies => Cat.hobby,
};

/// One line saying what the category is for, as on the Set a Goal screen.
String goalTagline(GoalCategory c) => switch (c) {
  GoalCategory.workout => 'Build strength and stay active',
  GoalCategory.habits => 'Small habits, steady change',
  GoalCategory.sleep => 'Rest well, on your schedule',
  GoalCategory.screen => 'More presence, less scrolling',
  GoalCategory.hobbies => 'Make time for what you love',
};

/// Opens the place where the goal for [category] is set. Workout is a small
/// sheet; the rest reuse their existing screens so there is one editor each.
Future<void> openGoalEditor(BuildContext context, GoalCategory category) {
  Future<void> push(Widget screen) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => screen));
  return switch (category) {
    GoalCategory.workout => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const WorkoutGoalSheet(),
    ),
    GoalCategory.habits => push(const HabitManageScreen()),
    GoalCategory.sleep => push(const SleepScreen()),
    GoalCategory.screen => push(const ScreenTimeScreen()),
    GoalCategory.hobbies => push(const HobbyManageScreen()),
  };
}

/// "What would you like to focus on?": pick a category, then set its goal.
class SetGoalScreen extends StatelessWidget {
  const SetGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    return Scaffold(
      appBar: AppBar(title: const Text('Set a goal')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text('What would you like to focus on?', style: text.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Choose a category and set your goal.',
            style: text.bodyMedium?.copyWith(color: t.textMuted),
          ),
          const SizedBox(height: 16),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 176,
            ),
            children: [
              for (final c in GoalCategory.values)
                _CategoryTile(
                  category: c,
                  onTap: () => openGoalEditor(context, c),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SoftCard(
            color: t.cat(Cat.hobby).tint.withValues(alpha: 0.5),
            shadow: false,
            child: Text(
              'You can set several goals across categories. Progress is '
              'measured against each goal, so no single category outweighs '
              'the rest.',
              style: text.bodyMedium?.copyWith(color: t.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final GoalCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cat = context.tokens.cat(goalCat(category));
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: '${category.label}. ${goalTagline(category)}',
      child: SoftCard(
        color: cat.tint,
        shadow: false,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(goalIcon(category), size: 34, color: cat.icon),
              const SizedBox(height: 8),
              Text(
                category.label,
                style: text.titleSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                goalTagline(category),
                style: text.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sessions per week for the workout goal.
class WorkoutGoalSheet extends ConsumerStatefulWidget {
  const WorkoutGoalSheet({super.key});

  @override
  ConsumerState<WorkoutGoalSheet> createState() => _WorkoutGoalSheetState();
}

class _WorkoutGoalSheetState extends ConsumerState<WorkoutGoalSheet> {
  int? _sessions;

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(workoutGoalProvider).value;
    final sessions = _sessions ?? saved ?? 3;
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Workout goal', style: text.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Every saved workout counts toward your week.',
            style: text.bodyMedium?.copyWith(color: t.textMuted),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                tooltip: 'Fewer sessions',
                onPressed: sessions > 1
                    ? () => setState(() => _sessions = sessions - 1)
                    : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 150,
                child: Column(
                  children: [
                    Text('$sessions', style: text.displaySmall),
                    Text(
                      sessions == 1 ? 'session per week' : 'sessions per week',
                      style: text.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'More sessions',
                onPressed: sessions < 7
                    ? () => setState(() => _sessions = sessions + 1)
                    : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () async {
              await ref.read(workoutGoalProvider.notifier).set(sessions);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
          if (saved != null)
            TextButton(
              onPressed: () async {
                await ref.read(workoutGoalProvider.notifier).set(null);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Remove goal'),
            ),
        ],
      ),
    );
  }
}
