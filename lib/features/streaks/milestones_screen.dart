import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
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
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milestones'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned.fill(
                  child: ExcludeSemantics(
                    child: CustomPaint(painter: _ConfettiPainter()),
                  ),
                ),
                Container(
                  width: 236,
                  height: 236,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dark
                        ? const Color(0xFF3A2E22)
                        : const Color(0xFFFDEBD3),
                    border: Border.all(
                      color: t.accent.withValues(alpha: 0.10),
                      width: 10,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF07A32),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$current ${current == 1 ? 'day' : 'days'}',
                        style: text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'activity streak',
                        style: text.bodyLarge?.copyWith(color: t.accentDeep),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Text(
              current > 0
                  ? "You're on a roll."
                  : 'Log a workout to start a streak.',
              style: text.titleSmall?.copyWith(color: t.accentDeep),
            ),
          ),
          const SizedBox(height: 22),
          Text('Badges', style: text.titleMedium),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < streakMilestones.length; i++)
                Expanded(
                  child: _Badge(
                    days: streakMilestones[i],
                    tier: i,
                    earned: awarded.contains(
                      streakBadgeKey('overall', streakMilestones[i]),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Personal bests', style: text.titleMedium),
          const SizedBox(height: 10),
          SoftCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _Best(
                  label: 'Longest streak',
                  value: '${snap?.overall.longest ?? 0} days',
                ),
                const RowDivider(),
                _Best(
                  label: 'Most active minutes in a week',
                  value: '${snap?.bestWeekMinutes ?? 0} min',
                ),
              ],
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
  const _Badge({required this.days, required this.tier, required this.earned});
  final int days;
  final int tier;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tiers = [
      (
        dark ? const Color(0xFF3E2E22) : const Color(0xFFFDEBD6),
        const Color(0xFFF07A32),
        Colors.transparent,
      ),
      (
        dark ? const Color(0xFF23392E) : const Color(0xFFDDF1E6),
        Colors.white,
        t.accent,
      ),
      (
        dark ? const Color(0xFF3F3220) : const Color(0xFFFBEBC8),
        Colors.white,
        const Color(0xFFD9962B),
      ),
    ];
    final style = tiers[tier % tiers.length];

    return Semantics(
      label: '$days-day badge, ${earned ? 'earned' : 'not yet earned'}',
      child: ExcludeSemantics(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: earned ? style.$1 : t.track,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: earned ? style.$3 : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  earned
                      ? Icons.local_fire_department_rounded
                      : Icons.lock_outline_rounded,
                  size: earned ? 32 : 28,
                  color: earned ? style.$2 : t.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$days days',
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(color: earned ? t.text : t.textMuted),
              ),
              Text(
                earned ? 'Earned' : 'Not yet',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
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
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    ),
  );
}

/// Still confetti around the streak circle (no animation, so nothing moves
/// for people who prefer reduced motion).
class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(11);
    const colors = [
      Color(0xFFF07A32),
      Color(0xFF2CB1C4),
      Color(0xFFE5483C),
      Color(0xFF8C6FD6),
      Color(0xFFF2B33D),
    ];
    final c = size.center(Offset.zero);
    for (var i = 0; i < 26; i++) {
      final angle = rnd.nextDouble() * math.pi * 2;
      final radius = 128 + rnd.nextDouble() * 18 + (i.isEven ? 6 : 0);
      final p = c + Offset(math.cos(angle), math.sin(angle)) * radius;
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 0.85);
      if (i % 3 == 0) {
        canvas.drawCircle(p, 3, paint);
      } else {
        canvas.save();
        canvas.translate(p.dx, p.dy);
        canvas.rotate(rnd.nextDouble() * math.pi);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-1.8, -5, 3.6, 10),
            const Radius.circular(2),
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => false;
}
