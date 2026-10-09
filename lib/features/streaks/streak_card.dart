import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/app_database.dart';
import '../week/week_providers.dart';
import '../workouts/workout_providers.dart';
import 'badges.dart';
import 'milestones_screen.dart';
import 'streak_engine.dart';
import 'streak_providers.dart';

/// Whether the most recent missed day was covered by a freeze, so the card can
/// say so plainly (spec 7.2): `Streak kept. Freeze used.`
bool freezeJustUsed(StreakResult r, String? today) {
  final f = r.lastFreezeDate;
  if (f == null || today == null) return false;
  // Yesterday or today in local dates; compare via the freeze list's last day.
  final d = DateTime.parse(today).difference(DateTime.parse(f)).inDays;
  return d <= 1 && r.current > 0;
}

/// Overall streak plus the best current per-type streak. Taps through to
/// milestones.
class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(streakSnapshotProvider);
    final today = ref.watch(todayDateProvider).value;
    final types = {
      for (final t
          in ref.watch(workoutTypesProvider).value ?? const <WorkoutType>[])
        t.id: t,
    };
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    final overall = snap?.overall.current ?? 0;
    String? bestType;
    var bestDays = 0;
    for (final e
        in snap?.byType.entries ?? const <MapEntry<String, StreakResult>>[]) {
      if (e.value.current > bestDays) {
        bestDays = e.value.current;
        bestType = types[e.key]?.name;
      }
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const MilestonesScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department_outlined,
                color: overall > 0 ? t.accent : t.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overall > 0 ? streakMessage(overall) : 'No streak yet.',
                      style: text.titleLarge,
                    ),
                    if (snap != null && freezeJustUsed(snap.overall, today))
                      Text('Streak kept. Freeze used.', style: text.bodySmall)
                    else if (bestType != null)
                      Text(
                        '$bestType ${streakMessage(bestDays)}',
                        style: text.bodySmall,
                      ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: kMinTapTarget),
                child: Icon(Icons.chevron_right_rounded, color: t.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Overall and per-type streaks for the Week tab.
class WeekStreaks extends ConsumerWidget {
  const WeekStreaks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(streakSnapshotProvider);
    if (snap == null) return const SizedBox.shrink();
    final types = {
      for (final t
          in ref.watch(workoutTypesProvider).value ?? const <WorkoutType>[])
        t.id: t,
    };
    final text = Theme.of(context).textTheme;

    final perType =
        snap.byType.entries.where((e) => e.value.current > 0).toList()
          ..sort((a, b) => b.value.current.compareTo(a.value.current));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Streaks', style: text.bodySmall),
            const SizedBox(height: 8),
            _Row(
              label: 'Overall',
              value: snap.overall.current > 0
                  ? '${snap.overall.current} days'
                  : 'None',
            ),
            for (final e in perType)
              _Row(
                label: types[e.key]?.name ?? 'Workout',
                value: '${e.value.current} days',
              ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value),
      ],
    ),
  );
}
