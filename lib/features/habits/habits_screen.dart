import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/app_database.dart';
import '../reminders/reminders_screen.dart';
import 'habit_actions.dart';
import 'habit_defaults.dart';
import 'habit_detail_screen.dart';
import 'habit_providers.dart';
import 'habit_setup_screen.dart';
import 'reminder_config.dart';

enum _HabitsTab { today, setup }

/// Healthy Habits: today's list with a tick when a target is met, and a
/// Setup tab to manage habits and their reminders.
class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  _HabitsTab _tab = _HabitsTab.today;

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(activeHabitsProvider).value ?? const <Habit>[];
    final counts = ref.watch(todayHabitCountsProvider).value ?? const {};
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthy Habits'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Reminders',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const RemindersScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          PillTabs<_HabitsTab>(
            options: const {
              _HabitsTab.today: 'Today',
              _HabitsTab.setup: 'Setup',
            },
            selected: _tab,
            onChanged: (v) => setState(() => _tab = v),
          ),
          const SizedBox(height: 10),
          if (habits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
              child: Text(
                'No habits yet. Add one to get started.',
                style: text.bodyMedium?.copyWith(color: t.textMuted),
              ),
            )
          else if (_tab == _HabitsTab.today)
            for (var i = 0; i < habits.length; i++) ...[
              if (i > 0) const RowDivider(indent: 72),
              _TodayRow(habit: habits[i], count: counts[habits[i].id] ?? 0),
            ]
          else
            for (final h in habits) ...[
              _SetupRow(habit: h),
              const SizedBox(height: 10),
            ],
          if (_tab == _HabitsTab.setup) ...[
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const HabitSetupScreen(),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add habit'),
            ),
          ],
          const SizedBox(height: 26),
          const _HabitsBanner(),
        ],
      ),
    );
  }
}

String _interval(Habit h) {
  if (!h.remindersEnabled) return '${h.dailyTarget} per day';
  final c = ReminderConfig.fromJson(h.reminderConfig);
  return c.mode == ReminderMode.interval
      ? describeInterval(c.everyMinutes)
      : '${c.times.length} reminder${c.times.length == 1 ? '' : 's'}';
}

class _TodayRow extends ConsumerWidget {
  const _TodayRow({required this.habit, required this.count});

  final Habit habit;
  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final met = count >= habit.dailyTarget;
    return Semantics(
      button: true,
      label: 'Log ${habit.name}, $count of ${habit.dailyTarget} today',
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => logHabitOnce(context, ref, habit),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 88),
          child: ExcludeSemantics(
            child: Row(
              children: [
                TintedIcon(
                  icon: habitIcon(habit.kind),
                  cat: habitCat(habit.kind),
                  size: 56,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.name, style: text.titleMedium),
                      const SizedBox(height: 3),
                      Text(
                        '${_interval(habit)}  •  $count/${habit.dailyTarget}',
                        style: text.bodyMedium?.copyWith(color: t.textMuted),
                      ),
                    ],
                  ),
                ),
                DoneMark(done: met, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupRow extends StatelessWidget {
  const _SetupRow({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return SoftCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HabitDetailScreen(habitId: habit.id),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Row(
        children: [
          TintedIcon(
            icon: habitIcon(habit.kind),
            cat: habitCat(habit.kind),
            size: 50,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.name, style: text.titleMedium),
                const SizedBox(height: 2),
                Text(
                  habit.remindersEnabled
                      ? '${habit.dailyTarget} per day, ${_interval(habit).toLowerCase()}'
                      : '${habit.dailyTarget} per day, reminders off',
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: t.textMuted),
        ],
      ),
    );
  }
}

class _HabitsBanner extends StatelessWidget {
  const _HabitsBanner();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 16, 18),
      decoration: BoxDecoration(
        color: t.mint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Healthy habits\npower your day',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SproutIcon(size: 78),
        ],
      ),
    );
  }
}
