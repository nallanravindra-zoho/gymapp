import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import 'badges.dart';
import 'streak_providers.dart';

class MilestonesScreen extends ConsumerWidget {
  const MilestonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(streakSnapshotProvider);
    final awarded = ref.watch(awardedBadgesProvider).value ?? const <String>{};
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final current = snap?.overall.current ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Milestones')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Text('$current', style: text.displaySmall),
                  Text(
                    current == 1
                        ? 'day activity streak'
                        : 'days activity streak',
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Badges', style: text.bodySmall),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final m in streakMilestones)
                Expanded(
                  child: _Badge(
                    days: m,
                    earned: awarded.contains(streakBadgeKey('overall', m)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Personal bests', style: text.bodySmall),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _Best(
                    label: 'Longest streak',
                    value: '${snap?.overall.longest ?? 0} days',
                  ),
                  _Best(
                    label: 'Most active minutes in a week',
                    value: '${snap?.bestWeekMinutes ?? 0} min',
                  ),
                ],
              ),
            ),
          ),
          if (snap != null && snap.overall.freezeAvailable)
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 4),
              child: Text(
                'Freeze available.',
                style: text.bodySmall?.copyWith(color: t.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.days, required this.earned});
  final int days;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      label: '$days-day badge, ${earned ? 'earned' : 'not yet earned'}',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: earned ? t.accent.withValues(alpha: 0.14) : t.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: earned ? t.accent : t.textMuted.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          children: [
            Icon(
              earned ? Icons.local_fire_department : Icons.lock_outline,
              color: earned ? t.accent : t.textMuted,
            ),
            const SizedBox(height: 4),
            Text('$days days', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Best extends StatelessWidget {
  const _Best({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    ),
  );
}
