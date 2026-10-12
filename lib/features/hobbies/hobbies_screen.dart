import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/durations.dart';
import '../../core/theme/tokens.dart';
import '../../core/time/local_date.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/app_database.dart';
import '../week/week_providers.dart';
import 'chant_screen.dart';
import 'hobby_detail_screen.dart';
import 'hobby_logic.dart';
import 'hobby_manage_screen.dart';
import 'hobby_providers.dart';
import 'hobby_widgets.dart';

/// Hobbies: a list of what you do for yourself, with goal progress, a goal
/// streak and a gentle weekly balance. Manage adds, edits and archives.
class HobbiesScreen extends ConsumerWidget {
  const HobbiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    final hobbies = ref.watch(activeHobbiesProvider).value ?? const <Hobby>[];
    final today = ref.watch(todayDateProvider).value;
    final acts = ref.watch(hobbyActivitiesProvider);
    final streaks = ref.watch(hobbyStreaksByHobbyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hobbies'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          const _StreakCard(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: Text('Your hobbies', style: text.titleLarge)),
              TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HobbyManageScreen(),
                  ),
                ),
                child: const Text('Manage'),
              ),
            ],
          ),
          if (hobbies.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'No hobbies yet. Use Manage to add one.',
                style: text.bodyMedium?.copyWith(color: t.textMuted),
              ),
            )
          else
            for (var i = 0; i < hobbies.length; i++) ...[
              if (i > 0) const RowDivider(indent: 72),
              _HobbyRow(
                hobby: hobbies[i],
                today: today,
                acts: acts,
                streak: streaks[hobbies[i].id],
              ),
            ],
          const SizedBox(height: 18),
          _BalanceCard(today: today, acts: acts, hobbies: hobbies),
          const SizedBox(height: 18),
          SoftCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ChantScreen()),
            ),
            child: Row(
              children: [
                const TintedIcon(
                  icon: Icons.self_improvement_rounded,
                  cat: Cat.hobby,
                  size: 48,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Om chanting', style: text.titleMedium),
                      Text(
                        'A timer and a counter for each chant',
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: t.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends ConsumerWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final s = ref.watch(hobbyStreakProvider);
    final goals = ref.watch(hobbyGoalsProvider);
    final today = ref.watch(todayDateProvider).value;
    final acts = ref.watch(hobbyActivitiesProvider);

    String headline;
    String? detail;
    if (!s.hasGoal) {
      headline = 'Set a goal to start a streak';
      detail = 'Open Manage and give a hobby a daily or weekly goal.';
    } else if (s.current == 0) {
      headline = 'No goal streak yet';
      detail = s.longest > 0 ? 'Best so far: ${s.longestLabel}' : null;
    } else {
      headline = s.label;
      detail = s.longest > s.current ? 'Best so far: ${s.longestLabel}' : null;
    }

    var summary = '';
    if (today != null && goals.isNotEmpty) {
      final dailyMet = dailyGoalsMetOn(
        goals: goals,
        activities: acts,
        date: today,
      );
      final weeklyMet = weeklyGoalsMetIn(
        goals: goals,
        activities: acts,
        weekStart: weekStartOf(today),
      );
      final daily = goals.values.where((g) => g.period.name == 'daily').length;
      final weekly = goals.length - daily;
      final parts = <String>[
        if (weekly > 0) 'Weekly goals met: ${weeklyMet.length} of $weekly',
        if (daily > 0) 'Daily goals met today: ${dailyMet.length} of $daily',
      ];
      summary = parts.join('. ');
    }

    return SoftCard(
      child: Row(
        children: [
          const TintedIcon(
            icon: Icons.local_fire_department_rounded,
            cat: Cat.streak,
            size: 52,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(headline, style: text.titleMedium),
                if (detail != null) Text(detail, style: text.bodySmall),
                if (summary.isNotEmpty) Text(summary, style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HobbyRow extends StatelessWidget {
  const _HobbyRow({
    required this.hobby,
    required this.today,
    required this.acts,
    required this.streak,
  });

  final Hobby hobby;
  final String? today;
  final List<HobbyActivity> acts;
  final HobbyStreakInfo? streak;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final goal = HobbyGoal.of(hobby);
    HobbyProgress? p;
    String subtitle;
    if (goal != null && today != null) {
      p = hobbyProgress(
        goal: goal,
        activities: acts,
        hobbyId: hobby.id,
        today: today!,
      );
      subtitle = p.describe();
      final label = streak?.label ?? '';
      if (label.isNotEmpty) subtitle = '$subtitle  •  $label';
    } else if (today != null) {
      final start = weekStartOf(today!);
      final m = minutesByHobby(
        acts,
        from: start,
        to: shiftLocalDate(start, 6),
      )[hobby.id];
      subtitle = m == null ? 'No goal set' : '${durationShort(m)} this week';
    } else {
      subtitle = '';
    }
    return Semantics(
      button: true,
      label: '${hobby.name}, $subtitle',
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => HobbyDetailScreen(hobby: hobby),
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 80),
          child: ExcludeSemantics(
            child: Row(
              children: [
                TintedIcon(
                  icon: hobbyIcon(hobby.iconKey),
                  cat: Cat.hobby,
                  size: 52,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hobby.name, style: text.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: text.bodyMedium?.copyWith(color: t.textMuted),
                      ),
                    ],
                  ),
                ),
                if (p != null)
                  DoneMark(done: p.met, size: 28)
                else
                  Icon(Icons.chevron_right_rounded, color: t.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Minutes per hobby this week as simple bars with each one's share. Plain
/// facts, no targets or comparisons.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.today,
    required this.acts,
    required this.hobbies,
  });

  final String? today;
  final List<HobbyActivity> acts;
  final List<Hobby> hobbies;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final start = today == null ? null : weekStartOf(today!);
    final byHobby = start == null
        ? const <String, int>{}
        : minutesByHobby(acts, from: start, to: shiftLocalDate(start, 6));
    final names = {for (final h in hobbies) h.id: h.name};
    final rows = [
      for (final e in byHobby.entries)
        if (names.containsKey(e.key)) (names[e.key]!, e.value),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    final total = rows.fold<int>(0, (a, r) => a + r.$2);

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This week', style: text.titleMedium),
          const SizedBox(height: 4),
          if (rows.isEmpty)
            Text(
              'Nothing logged yet this week. Whenever you are ready.',
              style: text.bodyMedium?.copyWith(color: t.textMuted),
            )
          else ...[
            Text(
              '${durationShort(total)} across ${rows.length} '
              '${rows.length == 1 ? 'hobby' : 'hobbies'}',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 10),
            for (final r in rows) ...[
              Semantics(
                label:
                    '${r.$1}, ${durationShort(r.$2)}, '
                    '${(r.$2 * 100 / total).round()} percent of the week',
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(r.$1, style: text.bodyMedium)),
                          Text(
                            '${durationShort(r.$2)}  •  '
                            '${(r.$2 * 100 / total).round()}%',
                            style: text.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: r.$2 / total,
                          minHeight: 8,
                          backgroundColor: t.track,
                          color: t.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }
}
