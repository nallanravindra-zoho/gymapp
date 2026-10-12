import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../week/day_format.dart';
import '../../core/time/local_date.dart';
import 'groups_models.dart';
import 'groups_providers.dart';
import 'groups_ui.dart';

/// What each switch shares, in plain words. Used by the onboarding sheet and
/// by group settings so both say the same thing.
String categoryShareText(GroupCategory c) => switch (c) {
  GroupCategory.workouts =>
    'Your active time and active days, and your workouts in the activity '
        'feed.',
  GroupCategory.habits =>
    'Which daily habit goals you met, and goal items in the activity feed.',
  GroupCategory.sleep =>
    'Nights logged, average sleep and how close you are to your own '
        'target. Off unless you switch it on.',
  GroupCategory.screenTime =>
    'Daily screen time compared with your own limit. Off unless you switch '
        'it on.',
};

/// The sentence that explains how people are ranked, shown with the boards.
const overallDisclosure = 'Ranked on the categories each person shares.';
const categoryDisclosure =
    'Ranked on how closely each person meets their own targets this week.';

/// Shown in the sheet and in settings: what never leaves the phone.
const neverSharedText =
    'Weight, height and body measurements are never shared with a group.';

/// Asks what to share with a group before creating or joining it. Returns the
/// choices, or null when cancelled. Workouts and Healthy Habits start on;
/// sleep and screen time start off.
Future<GroupSharing?> showSharingSheet(
  BuildContext context, {
  required String title,
  required String intro,
  required String action,
}) {
  return showModalBottomSheet<GroupSharing>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _SharingSheet(title: title, intro: intro, action: action),
  );
}

class _SharingSheet extends StatefulWidget {
  const _SharingSheet({
    required this.title,
    required this.intro,
    required this.action,
  });
  final String title;
  final String intro;
  final String action;

  @override
  State<_SharingSheet> createState() => _SharingSheetState();
}

class _SharingSheetState extends State<_SharingSheet> {
  var _sharing = const GroupSharing();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = text.bodyMedium?.copyWith(color: context.tokens.textMuted);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: text.titleLarge),
                  const SizedBox(height: 8),
                  Text(widget.intro, style: muted),
                  const SizedBox(height: 8),
                  Text(
                    'Members see a category only if they share it too. '
                    'Sleep and screen time start off. $neverSharedText You '
                    'can change this any time in group settings.',
                    style: muted,
                  ),
                  const SizedBox(height: 8),
                  for (final c in GroupCategory.values)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(c.label),
                      subtitle: Text(categoryShareText(c)),
                      value: _sharing.shares(c),
                      onChanged: (v) => setState(
                        () => _sharing = _sharing.withCategory(c, v),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Column(
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(kMinTapTarget),
                  ),
                  onPressed: () => Navigator.pop(context, _sharing),
                  child: Text(widget.action),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(kMinTapTarget),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Overall plus the available categories. Scrolls sideways when the labels do
/// not fit.
class GroupTabBar extends StatelessWidget {
  const GroupTabBar({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onChanged,
  });

  final List<GroupTab> tabs;
  final GroupTab selected;
  final ValueChanged<GroupTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = math.max(c.maxWidth, tabs.length * 118.0);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: PillTabs<GroupTab>(
              outlined: true,
              height: 44,
              options: {for (final t in tabs) t: t.label},
              selected: selected,
              onChanged: onChanged,
            ),
          ),
        );
      },
    );
  }
}

Widget _rankMark(BuildContext context, int rank) {
  final text = Theme.of(context).textTheme;
  return SizedBox(
    width: 28,
    child: rank == 1
        ? const Icon(
            Icons.workspace_premium_rounded,
            color: Color(0xFFE6A23C),
            size: 22,
          )
        : Text('$rank', style: text.titleSmall),
  );
}

/// The Overall tab: rank, name and small chips for the categories behind the
/// rank. No score is shown anywhere.
class OverallBoardCard extends StatelessWidget {
  const OverallBoardCard({
    super.key,
    required this.entries,
    required this.me,
    required this.onOpen,
  });

  final List<OverallEntry> entries;
  final String? me;
  final ValueChanged<OverallEntry> onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const RowDivider(),
            Builder(
              builder: (context) {
                final e = entries[i];
                final name = e.userId == me ? 'You' : memberName(e.displayName);
                final counts = e.categories.isEmpty
                    ? 'categories you do not share'
                    : e.categories.map((c) => c.label).join(', ');
                return Semantics(
                  button: true,
                  label: '${e.rank}, $name, based on $counts',
                  child: InkWell(
                    onTap: () => onOpen(e),
                    child: ExcludeSemantics(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: kMinTapTarget + 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              _rankMark(context, e.rank),
                              MemberAvatar(name: e.displayName, size: 40),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: text.titleSmall?.copyWith(
                                        color: e.userId == me
                                            ? t.accentDeep
                                            : t.text,
                                      ),
                                    ),
                                    if (e.categories.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          for (final c in e.categories)
                                            CategoryChip(category: c),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: t.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// A small label saying a category counts towards someone's rank.
class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.category});
  final GroupCategory category;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: t.accentSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        category.shortLabel,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: t.accentDeep),
      ),
    );
  }
}

/// A category tab: rank, name and the person's key figures in one line.
class CategoryBoardCard extends StatelessWidget {
  const CategoryBoardCard({
    super.key,
    required this.category,
    required this.entries,
    required this.me,
    required this.onOpen,
  });

  final GroupCategory category;
  final List<CategoryEntry> entries;
  final String? me;
  final ValueChanged<CategoryEntry> onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const RowDivider(),
            Builder(
              builder: (context) {
                final e = entries[i];
                final name = e.userId == me ? 'You' : memberName(e.displayName);
                final line = metricsSummary(category, e.metrics);
                return Semantics(
                  button: true,
                  label: '${e.rank}, $name, $line',
                  child: InkWell(
                    onTap: () => onOpen(e),
                    child: ExcludeSemantics(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: kMinTapTarget + 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              _rankMark(context, e.rank),
                              MemberAvatar(name: e.displayName, size: 40),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: text.titleSmall?.copyWith(
                                        color: e.userId == me
                                            ? t.accentDeep
                                            : t.text,
                                      ),
                                    ),
                                    Text(
                                      line,
                                      style: text.bodySmall?.copyWith(
                                        color: t.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: t.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Opens a participant's shared key metrics for [categories] (those the
/// server allows: both of you share them). Figures only, no scores.
Future<void> showParticipantSheet(
  BuildContext context, {
  required String groupId,
  required String userId,
  required String name,
  required List<GroupCategory> categories,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => ParticipantSheet(
      groupId: groupId,
      userId: userId,
      name: name,
      categories: categories,
    ),
  );
}

class ParticipantSheet extends ConsumerWidget {
  const ParticipantSheet({
    super.key,
    required this.groupId,
    required this.userId,
    required this.name,
    required this.categories,
  });

  final String groupId;
  final String userId;
  final String name;
  final List<GroupCategory> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final muted = text.bodyMedium?.copyWith(color: context.tokens.textMuted);
    final results = [
      for (final c in categories)
        (c, ref.watch(participantMetricsProvider((groupId, userId, c)))),
    ];
    final loading = results.any((r) => r.$2.isLoading);
    final failed = results.any((r) => r.$2.hasError);
    final shown = [
      for (final r in results)
        if (r.$2.value != null) (r.$1, r.$2.value!),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              MemberAvatar(name: name, size: 44),
              const SizedBox(width: 12),
              Expanded(child: Text(name, style: text.titleLarge)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Shared with this group this week', style: muted),
          const SizedBox(height: 12),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (failed)
            Text('Could not load these figures.', style: muted)
          else if (shown.isEmpty)
            Text(
              'Nothing from $name is shared with you for this week. Figures '
              'show only for categories you both share.',
              style: muted,
            )
          else
            for (final r in shown) ...[
              _MetricsCard(category: r.$1, metrics: r.$2),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _MetricsCard extends StatelessWidget {
  const _MetricsCard({required this.category, required this.metrics});
  final GroupCategory category;
  final ParticipantMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    final lines = describeMetrics(category, metrics.summary);
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category.label, style: text.titleMedium),
          const SizedBox(height: 8),
          for (final l in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.label,
                      style: text.bodyMedium?.copyWith(color: t.textMuted),
                    ),
                  ),
                  Text(l.value, style: text.titleSmall),
                ],
              ),
            ),
          if (metrics.days.isNotEmpty) ...[
            const SizedBox(height: 8),
            const RowDivider(),
            const SizedBox(height: 4),
            for (final d in metrics.days)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dayLabel(d.date),
                        style: text.bodySmall?.copyWith(color: t.textMuted),
                      ),
                    ),
                    Text(
                      dayAmountText(category, d.amount),
                      style: text.bodyMedium,
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

String _dayLabel(String date) {
  final d = parseLocalDate(date);
  return '${weekdayNames[d.weekday - 1].substring(0, 3)} ${d.day} '
      '${monthNames[d.month - 1]}';
}
