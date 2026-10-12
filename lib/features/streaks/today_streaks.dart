import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import 'category_streaks.dart';
import 'milestones_screen.dart';
import 'streak_providers.dart';

/// "Today's streaks": the four separate category streaks (Workout, Healthy
/// habits, Hobbies, Sleep target), each with its current and longest run and
/// a caption saying exactly what is counted. Taps through to Milestones.
class TodayStreaks extends ConsumerWidget {
  const TodayStreaks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streaks = ref.watch(categoryStreaksProvider);
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return SoftCard(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const MilestonesScreen())),
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text("Today's streaks", style: text.titleMedium)),
              Icon(Icons.chevron_right_rounded, color: t.text),
            ],
          ),
          const SizedBox(height: 8),
          for (final c in StreakCategory.values)
            CategoryStreakRow(
              category: c,
              streak:
                  streaks?[c] ??
                  CategoryStreak(
                    category: c,
                    current: 0,
                    longest: 0,
                    hasGoal: c != StreakCategory.hobbies,
                  ),
            ),
        ],
      ),
    );
  }
}

/// One category: icon, label, caption, current figure and longest.
class CategoryStreakRow extends StatelessWidget {
  const CategoryStreakRow({
    super.key,
    required this.category,
    required this.streak,
  });

  final StreakCategory category;
  final CategoryStreak streak;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    return Semantics(
      container: true,
      label: streak.semanticsLabel,
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                TintedIcon(icon: category.icon, cat: category.cat, size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.label, style: text.titleSmall),
                      Text(
                        streak.caption,
                        style: text.bodySmall?.copyWith(color: t.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      streak.currentText,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Longest ${streak.longestText}',
                      style: text.bodySmall?.copyWith(color: t.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
