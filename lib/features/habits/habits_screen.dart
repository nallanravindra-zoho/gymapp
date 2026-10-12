import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/app_database.dart';
import '../../data/seed_tips.dart';
import '../insights/tips.dart';
import '../reminders/notification_permission_banner.dart';
import '../reminders/reminders_screen.dart';
import 'habit_actions.dart';
import 'habit_defaults.dart';
import 'habit_manage_screen.dart';
import 'habit_providers.dart';
import 'habit_setup_screen.dart';
import 'reminder_config.dart';

/// Healthy Habits: today's list with a tick when a target is met, a Manage
/// link for adding, editing and archiving habits, and general suggestions.
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(activeHabitsProvider).value ?? const <Habit>[];
    final counts = ref.watch(todayHabitCountsProvider).value ?? const {};
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final cards = recommendationsFor([for (final h in habits) h.kind.name]);

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
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const HabitManageScreen(),
              ),
            ),
            child: const Text('Manage'),
          ),
          const SizedBox(width: 8),
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
          NotificationPermissionBanner(
            remindersOn: habits.any((h) => h.remindersEnabled),
          ),
          if (habits.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
              child: Text(
                'No habits yet. Add one to get started.',
                style: text.bodyMedium?.copyWith(color: t.textMuted),
              ),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(kMinTapTarget),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const HabitSetupScreen(),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add habit'),
            ),
          ] else
            for (var i = 0; i < habits.length; i++) ...[
              if (i > 0) const RowDivider(indent: 72),
              _TodayRow(habit: habits[i], count: counts[habits[i].id] ?? 0),
            ],
          const SizedBox(height: 20),
          for (final r in cards) ...[
            _RecommendationCard(rec: r),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 16),
          const _HabitsBanner(),
        ],
      ),
    );
  }
}

/// A general, non-prescriptive suggestion. Its text ends with the
/// disclaimer, and its source is named underneath.
class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.rec});

  final HabitRecommendation rec;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: 'Suggestion: ${rec.title}',
      child: SoftCard(
        key: Key('recommendation-${rec.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rec.title, style: text.titleMedium),
            const SizedBox(height: 6),
            Text(rec.text, style: text.bodyMedium),
            const SizedBox(height: 8),
            Text(
              'Source: ${rec.sourceLabel}',
              style: text.bodySmall?.copyWith(color: t.textMuted),
            ),
          ],
        ),
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
