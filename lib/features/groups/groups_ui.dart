import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import 'groups_models.dart';

/// A group's round badge. Groups have no picture, so each gets one of three
/// calm icon styles, chosen from its id so it never changes.
class GroupBadge extends StatelessWidget {
  const GroupBadge({super.key, required this.id, this.size = 56});

  final String id;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final styles = <(IconData, Color, Color)>[
      (Icons.spa_rounded, t.cat(Cat.leaf).tint, t.cat(Cat.leaf).icon),
      (
        Icons.directions_run_rounded,
        t.cat(Cat.water).tint,
        t.cat(Cat.water).icon,
      ),
      (
        Icons.menu_book_rounded,
        dark ? const Color(0xFF462B2A) : const Color(0xFFFAD9D4),
        dark ? const Color(0xFFFF8F80) : const Color(0xFFC9402E),
      ),
    ];
    final s = styles[id.hashCode.abs() % styles.length];
    return TintedIcon(icon: s.$1, tint: s.$2, color: s.$3, size: size);
  }
}

/// A person's initial in a soft circle (no photos in the app).
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({super.key, required this.name, this.size = 40});

  final String name;
  final double size;

  static const _tints = [
    (Color(0xFFFBE0C4), Color(0xFFB4701B)),
    (Color(0xFFD3E6F2), Color(0xFF2A5C99)),
    (Color(0xFFE5DDF5), Color(0xFF4639A8)),
    (Color(0xFFD2EBE0), Color(0xFF2B8062)),
    (Color(0xFFF7DCE3), Color(0xFF9B3A6B)),
  ];

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final pair = _tints[trimmed.hashCode.abs() % _tints.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: pair.$1, shape: BoxShape.circle),
      child: Text(
        trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase(),
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          color: pair.$2,
        ),
      ),
    );
  }
}

String leaderboardValue(RankedEntry r, LeaderboardMetric metric) {
  String days(int d) => '$d ${d == 1 ? 'day' : 'days'}';
  String minutes(int m) {
    final h = m ~/ 60;
    final r = m % 60;
    if (h == 0) return '$r min';
    return r == 0 ? '$h h' : '$h h $r min';
  }

  return metric == LeaderboardMetric.volume
      ? minutes(r.entry.activeMinutes)
      : days(r.entry.activeDays);
}

/// The ranked list: rank (a crown for first place), avatar, name, value.
class LeaderboardCard extends StatelessWidget {
  const LeaderboardCard({
    super.key,
    required this.entries,
    required this.metric,
    required this.me,
    this.limit,
    this.footer,
  });

  final List<LeaderboardEntry> entries;
  final LeaderboardMetric metric;
  final String? me;
  final int? limit;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final ranked = rankLeaderboard(entries, metric);
    final shown = limit == null ? ranked : ranked.take(limit!).toList();

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Column(
        children: [
          for (var i = 0; i < shown.length; i++) ...[
            if (i > 0) const RowDivider(),
            Semantics(
              label:
                  '${shown[i].rank}, ${shown[i].entry.userId == me ? 'You' : memberName(shown[i].entry.displayName)}, ${leaderboardValue(shown[i], metric)}',
              child: ExcludeSemantics(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: shown[i].rank == 1
                            ? const Icon(
                                Icons.workspace_premium_rounded,
                                color: Color(0xFFE6A23C),
                                size: 22,
                              )
                            : Text('${shown[i].rank}', style: text.titleSmall),
                      ),
                      MemberAvatar(name: shown[i].entry.displayName, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          shown[i].entry.userId == me
                              ? 'You'
                              : memberName(shown[i].entry.displayName),
                          style: text.titleSmall?.copyWith(
                            color: shown[i].entry.userId == me
                                ? t.accentDeep
                                : t.text,
                          ),
                        ),
                      ),
                      Text(
                        leaderboardValue(shown[i], metric),
                        style: text.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          ?footer,
        ],
      ),
    );
  }
}
