import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/time/local_date.dart';
import '../../data/providers.dart';
import '../account/sync_providers.dart';
import '../week/day_format.dart' show monthNames;
import '../../core/widgets/app_widgets.dart';
import 'group_settings_screen.dart';
import 'groups_ui.dart';
import 'groups_models.dart';
import 'groups_providers.dart';
import 'groups_widgets.dart';

String _weekRange(String weekStart) {
  final a = parseLocalDate(weekStart);
  final b = parseLocalDate(shiftLocalDate(weekStart, 6));
  return a.month == b.month
      ? '${a.day} – ${b.day} ${monthNames[b.month - 1]}'
      : '${a.day} ${monthNames[a.month - 1]} – ${b.day} ${monthNames[b.month - 1]}';
}

/// One group: this week's leaderboard, recent activity with cheers, members.
class GroupScreen extends ConsumerWidget {
  const GroupScreen({
    super.key,
    required this.groupId,
    required this.initialName,
  });

  final String groupId;
  final String initialName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupProvider(groupId));
    final roster = ref.watch(groupRosterProvider(groupId));
    final me = ref.watch(authUserProvider).value?.id;
    final text = Theme.of(context).textTheme;

    final names = <String, String>{
      for (final m in roster.value ?? const <GroupMember>[])
        m.userId: memberName(m.displayName),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(group?.name ?? initialName),
        actions: [
          IconButton(
            tooltip: 'Group settings',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // The code may have changed since the list was loaded (for
              // example from another phone), so read it again.
              ref.invalidate(groupsListProvider);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => GroupSettingsScreen(groupId: groupId),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.read(groupsActionsProvider).refresh(groupId),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            MediaQuery.paddingOf(context).bottom + 24,
          ),
          children: [
            _LeaderboardSection(groupId: groupId, me: me),
            const SizedBox(height: 24),
            Text('Activity', style: text.titleMedium),
            const SizedBox(height: 8),
            _FeedSection(groupId: groupId, me: me, names: names),
            const SizedBox(height: 24),
            Text('Members', style: text.titleMedium),
            const SizedBox(height: 8),
            _MembersSection(roster: roster, me: me),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardSection extends ConsumerWidget {
  const _LeaderboardSection({required this.groupId, required this.me});
  final String groupId;
  final String? me;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metric = ref.watch(leaderboardMetricProvider);
    final board = ref.watch(groupLeaderboardProvider(groupId));
    final week = ref.watch(groupWeekStartProvider);
    final text = Theme.of(context).textTheme;
    final muted = text.bodySmall?.copyWith(color: context.tokens.textMuted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('This week', style: text.titleMedium),
        if (week != null) Text(_weekRange(week), style: muted),
        const SizedBox(height: 12),
        PillTabs<LeaderboardMetric>(
          outlined: true,
          height: 42,
          options: const {
            LeaderboardMetric.volume: 'Volume',
            LeaderboardMetric.consistency: 'Consistency',
          },
          selected: metric,
          onChanged: (m) => ref.read(leaderboardMetricProvider.notifier).set(m),
        ),
        const SizedBox(height: 10),
        switch (board) {
          AsyncData(value: final entries) when entries.isEmpty => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('No one is sharing workouts yet.', style: muted),
          ),
          AsyncData(value: final entries) => LeaderboardCard(
            entries: entries,
            metric: metric,
            me: me,
          ),
          AsyncError() => Text('Could not load the leaderboard.', style: muted),
          _ => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        },
      ],
    );
  }
}

class _FeedSection extends ConsumerWidget {
  const _FeedSection({
    required this.groupId,
    required this.me,
    required this.names,
  });
  final String groupId;
  final String? me;
  final Map<String, String> names;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(groupFeedProvider(groupId));
    final clock = ref.watch(clockProvider);
    final text = Theme.of(context).textTheme;
    final muted = text.bodySmall?.copyWith(color: context.tokens.textMuted);

    Future<void> cheer(GroupEvent e, bool cheered) async {
      try {
        await ref.read(groupsActionsProvider).cheer(groupId, e.id, cheered);
      } catch (err) {
        if (context.mounted) showGroupsError(context, err);
      }
    }

    String when(DateTime at) {
      final now = clock.now();
      final localNow = now.add(Duration(minutes: clock.offsetAt(now)));
      final local = at.toUtc().add(Duration(minutes: clock.offsetAt(at)));
      final days = DateTime.utc(
        localNow.year,
        localNow.month,
        localNow.day,
      ).difference(DateTime.utc(local.year, local.month, local.day)).inDays;
      final time = MaterialLocalizations.of(context)
          .formatTimeOfDay(TimeOfDay(hour: local.hour, minute: local.minute));
      final day = days <= 0
          ? 'Today'
          : days == 1
          ? 'Yesterday'
          : '${local.day} ${monthNames[local.month - 1]}';
      return '$day, $time';
    }

    return switch (feed) {
      AsyncData(value: final events) when events.isEmpty => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text('Nothing shared yet.', style: muted),
      ),
      AsyncData(value: final events) => SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          children: [
            for (var i = 0; i < events.length; i++) ...[
              if (i > 0) const RowDivider(indent: 56),
              ListTile(
                contentPadding: EdgeInsets.zero,
                minTileHeight: kMinTapTarget + 12,
                leading: TintedIcon(
                  icon: switch (events[i].kind) {
                    GroupEventKind.workout => Icons.directions_run_rounded,
                    GroupEventKind.breakGoal => Icons.water_drop_rounded,
                    GroupEventKind.milestone => Icons.emoji_events_rounded,
                  },
                  cat: switch (events[i].kind) {
                    GroupEventKind.workout => Cat.workout,
                    GroupEventKind.breakGoal => Cat.water,
                    GroupEventKind.milestone => Cat.trophy,
                  },
                  size: 42,
                ),
                title: Text(
                  describeEvent(
                    events[i],
                    events[i].userId == me
                        ? 'You'
                        : names[events[i].userId] ?? 'A member',
                  ),
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(when(events[i].occurredAt)),
                trailing: events[i].userId == me
                    ? (events[i].cheeredBy.isEmpty
                          ? null
                          : Text('${events[i].cheeredBy.length} cheered'))
                    : _CheerButton(
                        cheered: me != null && events[i].cheeredBy.contains(me),
                        count: events[i].cheeredBy.length,
                        onChanged: (v) => cheer(events[i], v),
                      ),
              ),
            ],
          ],
        ),
      ),
      AsyncError() => Text('Could not load the activity.', style: muted),
      _ => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

class _CheerButton extends StatelessWidget {
  const _CheerButton({
    required this.cheered,
    required this.count,
    required this.onChanged,
  });
  final bool cheered;
  final int count;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return TextButton.icon(
      style: TextButton.styleFrom(
        minimumSize: const Size(kMinTapTarget, kMinTapTarget),
        foregroundColor: cheered ? t.accent : t.textMuted,
      ),
      onPressed: () => onChanged(!cheered),
      icon: Icon(cheered ? Icons.favorite : Icons.favorite_border, size: 20),
      label: Text(count == 0 ? 'Cheer' : '$count'),
    );
  }
}

class _MembersSection extends StatelessWidget {
  const _MembersSection({required this.roster, required this.me});
  final AsyncValue<List<GroupMember>> roster;
  final String? me;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: context.tokens.textMuted);
    return switch (roster) {
      AsyncData(value: final members) => SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          children: [
            for (var i = 0; i < members.length; i++) ...[
              if (i > 0) const RowDivider(indent: 56),
              ListTile(
                contentPadding: EdgeInsets.zero,
                minTileHeight: kMinTapTarget + 4,
                leading: MemberAvatar(name: members[i].displayName, size: 40),
                title: Text(
                  members[i].userId == me
                      ? 'You'
                      : memberName(members[i].displayName),
                ),
                trailing: members[i].isOwner ? const Text('Owner') : null,
              ),
            ],
          ],
        ),
      ),
      AsyncError() => Text('Could not load the members.', style: muted),
      _ => const SizedBox.shrink(),
    };
  }
}
