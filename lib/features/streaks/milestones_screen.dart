import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import 'badges.dart';
import 'category_streaks.dart';
import 'streak_providers.dart';

class MilestonesScreen extends ConsumerWidget {
  const MilestonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(streakSnapshotProvider);
    final awarded = ref.watch(awardedBadgesProvider).value ?? const <String>{};
    final earnedOn =
        ref.watch(awardedBadgeDatesProvider).value ??
        const <String, DateTime>{};
    final streaks = ref.watch(categoryStreaksProvider);
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
                        'overall activity streak',
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
          for (final c in StreakCategory.values) ...[
            CategoryMilestones(
              streak:
                  streaks?[c] ??
                  CategoryStreak(
                    category: c,
                    current: 0,
                    longest: 0,
                    hasGoal: c != StreakCategory.hobbies,
                  ),
              earnedOn: earnedOn,
            ),
            const SizedBox(height: 18),
          ],
          Text('Overall activity badges', style: text.titleMedium),
          const SizedBox(height: 2),
          Text(
            'Overall activity allows rest days and a streak freeze, so it is '
            'kept apart from the four streaks above.',
            style: text.bodySmall?.copyWith(color: t.textMuted),
          ),
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

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// `12 May 2026`.
String formatEarnedDate(DateTime d) {
  final l = d.toLocal();
  return '${l.day} ${_months[l.month - 1]} ${l.year}';
}

/// One category: its streak and a grid of the six milestones. Earned ones are
/// filled and coloured with the date; the next one shows how far there is to
/// go; the rest stay visible but subdued.
class CategoryMilestones extends StatelessWidget {
  const CategoryMilestones({
    super.key,
    required this.streak,
    required this.earnedOn,
  });

  final CategoryStreak streak;
  final Map<String, DateTime> earnedOn;

  @override
  Widget build(BuildContext context) {
    final c = streak.category;
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final colors = t.cat(c.cat);
    final earned = {
      for (final m in categoryMilestones)
        if (earnedOn.containsKey(c.badgeKey(m))) m,
    };
    int? next;
    for (final m in categoryMilestones) {
      if (!earned.contains(m) && m > streak.current) {
        next = m;
        break;
      }
    }
    final unit = streak.unit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TintedIcon(icon: c.icon, cat: c.cat, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.label, style: text.titleMedium),
                  Text(
                    '${streak.caption}. Now ${streak.currentText}.',
                    style: text.bodySmall?.copyWith(color: t.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, box) {
            const gap = 8.0;
            final w = (box.maxWidth - gap * 2) / 3;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final m in categoryMilestones)
                  SizedBox(
                    width: w,
                    child: _MilestoneTile(
                      category: c,
                      milestone: m,
                      unit: unit,
                      colors: colors,
                      earnedAt: earnedOn[c.badgeKey(m)],
                      toGo: m == next
                          ? toGoText(m, streak.current, unit)
                          : null,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({
    required this.category,
    required this.milestone,
    required this.unit,
    required this.colors,
    required this.earnedAt,
    required this.toGo,
  });

  final StreakCategory category;
  final int milestone;
  final StreakUnit unit;
  final CatColors colors;
  final DateTime? earnedAt;
  final String? toGo;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final earned = earnedAt != null;
    final title = '$milestone ${unit.word(milestone)}';
    final sub = earned ? formatEarnedDate(earnedAt!) : (toGo ?? 'Not yet');
    return Semantics(
      container: true,
      label:
          '${category.label} $title badge, '
          '${earned ? 'earned ${formatEarnedDate(earnedAt!)}' : (toGo ?? 'not yet earned')}',
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: earned ? colors.tint : t.track.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
            border: earned
                ? Border.all(
                    color: colors.icon.withValues(alpha: 0.5),
                    width: 1.5,
                  )
                : null,
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: earned ? colors.icon : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  earned ? category.icon : Icons.lock_outline_rounded,
                  size: earned ? 26 : 22,
                  color: earned ? Colors.white : t.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: text.titleSmall?.copyWith(
                  color: earned ? t.text : t.textMuted,
                  fontWeight: earned ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              Text(
                sub,
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(
                  color: earned || toGo != null ? t.text : t.textMuted,
                ),
              ),
            ],
          ),
        ),
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
