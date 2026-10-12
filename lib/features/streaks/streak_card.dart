import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/app_database.dart';
import '../week/week_providers.dart';
import '../workouts/workout_icons.dart';
import '../workouts/workout_providers.dart';
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

/// "Today's streaks": overall activity and the best current workout streak.
/// Taps through to milestones.
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
    final freezeNote = snap != null && freezeJustUsed(snap.overall, today);

    return SoftCard(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const MilestonesScreen())),
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text("Today's streaks", style: text.titleMedium)),
              Icon(Icons.chevron_right_rounded, color: t.text),
            ],
          ),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: StreakStat(
                    icon: Icons.local_fire_department_rounded,
                    cat: Cat.streak,
                    days: overall,
                    label: 'overall activity',
                  ),
                ),
                VerticalDivider(width: 24, color: t.border),
                Expanded(
                  child: StreakStat(
                    icon: Icons.fitness_center_rounded,
                    cat: Cat.strength,
                    days: bestDays,
                    label: bestType?.toLowerCase() ?? 'workout',
                  ),
                ),
              ],
            ),
          ),
          if (freezeNote) ...[
            const SizedBox(height: 10),
            Text('Streak kept. Freeze used.', style: text.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// A round icon, a "5 day" figure and a small label under it.
class StreakStat extends StatelessWidget {
  const StreakStat({
    super.key,
    required this.icon,
    required this.cat,
    required this.days,
    required this.label,
  });

  final IconData icon;
  final Cat cat;
  final int days;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        TintedIcon(icon: icon, cat: cat, size: 46),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$days',
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: ' day',
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                label,
                style: text.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Overall activity and the best workout streak, as two small cards.
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

    final perType =
        snap.byType.entries.where((e) => e.value.current > 0).toList()
          ..sort((a, b) => b.value.current.compareTo(a.value.current));
    final best = perType.isEmpty ? null : perType.first;
    final bestKey = best == null
        ? 'custom'
        : types[best.key]?.iconKey ?? 'custom';

    Widget card(IconData icon, CatColors colors, String label, int days) =>
        SoftCard(
          padding: const EdgeInsets.fromLTRB(10, 14, 6, 14),
          child: Row(
            children: [
              TintedIcon(
                icon: icon,
                tint: colors.tint,
                color: colors.icon,
                size: 40,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$days',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: days == 1 ? ' day' : ' days',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

    final tokens = context.tokens;
    return Row(
      children: [
        Expanded(
          child: card(
            Icons.local_fire_department_rounded,
            tokens.cat(Cat.streak),
            'Overall activity',
            snap.overall.current,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: card(
            workoutIcon(bestKey),
            workoutColors(context, bestKey),
            best == null ? 'Workout' : types[best.key]?.name ?? 'Workout',
            best?.value.current ?? 0,
          ),
        ),
      ],
    );
  }
}
