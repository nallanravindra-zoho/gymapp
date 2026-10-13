import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../account/account_screen.dart';
import '../account/sync_providers.dart';
import 'group_screen.dart';
import 'groups_models.dart';
import 'groups_providers.dart';
import 'group_categories_ui.dart';
import 'groups_ui.dart';
import 'groups_widgets.dart';

/// The Groups tab: the groups you are in, and ways to create or join one.
class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available = ref.watch(groupsRemoteProvider).isAvailable;
    final user = ref.watch(authUserProvider).value;

    final Widget body;
    if (!available) {
      body = const _Notice(
        title: 'Groups are not available in this build',
        detail:
            'Groups need sync to be set up. Everything else works without it.',
      );
    } else if (user == null) {
      body = const _SignedOut();
    } else {
      body = const _GroupList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text('Groups'),
        ),
        actions: [
          if (available && user != null)
            IconButton(
              tooltip: 'Add group',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.add_rounded, size: 28),
              onPressed: () => _showAddMenu(context, ref),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: body,
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.title, required this.detail, this.action});
  final String title;
  final String detail;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(title, style: text.titleLarge),
        const SizedBox(height: 8),
        Text(
          detail,
          style: text.bodyMedium?.copyWith(color: context.tokens.textMuted),
        ),
        if (action != null) ...[const SizedBox(height: 24), action!],
      ],
    );
  }
}

class _SignedOut extends StatelessWidget {
  const _SignedOut();

  @override
  Widget build(BuildContext context) => _Notice(
    title: 'Groups need an account',
    detail:
        'Sign in to create a group or join one with an invite. Members see '
        'only what they choose to share. Sleep and screen time stay private '
        'unless you switch them on for a group.',
    action: FilledButton(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(kMinTapTarget),
      ),
      onPressed: () => Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const AccountScreen())),
      child: const Text('Sign in'),
    ),
  );
}

Future<void> _createGroup(BuildContext context, WidgetRef ref) async {
  final name = await showDialog<String>(
    context: context,
    builder: (_) => const TextPromptDialog(
      title: 'New group',
      label: 'Group name',
      action: 'Create',
      maxLength: 40,
    ),
  );
  if (name == null || !context.mounted) return;
  final sharing = await showSharingSheet(
    context,
    title: 'What would you like to share?',
    intro:
        'Choose what to share with $name. Only the categories you switch '
        'on are visible to its members.',
    action: 'Create group',
  );
  if (sharing == null || !context.mounted) return;
  try {
    final g = await ref
        .read(groupsActionsProvider)
        .create(name, sharing: sharing);
    if (context.mounted) _open(context, g.id, g.name);
  } catch (e) {
    if (context.mounted) showGroupsError(context, e);
  }
}

Future<void> _joinGroup(BuildContext context, WidgetRef ref) async {
  final input = await showDialog<String>(
    context: context,
    builder: (_) => const TextPromptDialog(
      title: 'Join a group',
      label: 'Invite code',
      hint: '4 digits',
      action: 'Continue',
      keyboardType: TextInputType.number,
    ),
  );
  if (input == null || !context.mounted) return;
  final code = parseInviteCode(input);
  if (code == null) {
    showGroupsError(
      context,
      const GroupsException(GroupsProblem.inviteNotFound),
    );
    return;
  }
  try {
    final remote = ref.read(groupsRemoteProvider);
    final preview = await remote.previewInvite(code);
    if (!context.mounted) return;
    GroupSharing? sharing;
    if (!preview.alreadyMember) {
      sharing = await showSharingSheet(
        context,
        title: 'Join ${preview.name}?',
        intro:
            '${preview.memberCount} '
            '${preview.memberCount == 1 ? 'member' : 'members'}. They see '
            'only what you choose to share.',
        action: 'Join',
      );
      if (sharing == null || !context.mounted) return;
    }
    final id = await ref
        .read(groupsActionsProvider)
        .join(code, sharing: sharing);
    if (context.mounted) _open(context, id, preview.name);
  } catch (e) {
    if (context.mounted) showGroupsError(context, e);
  }
}

void _open(BuildContext context, String id, String name) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => GroupScreen(groupId: id, initialName: name),
    ),
  );
}

/// The "+" menu: create a group or join one.
Future<void> _showAddMenu(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              minTileHeight: 60,
              leading: const TintedIcon(
                icon: Icons.add_rounded,
                cat: Cat.leaf,
                size: 44,
              ),
              title: const Text('Create group'),
              onTap: () {
                Navigator.pop(sheet);
                _createGroup(context, ref);
              },
            ),
            ListTile(
              minTileHeight: 60,
              leading: const TintedIcon(
                icon: Icons.pin_outlined,
                cat: Cat.screen,
                size: 44,
              ),
              title: const Text('Join with a code'),
              onTap: () {
                Navigator.pop(sheet);
                _joinGroup(context, ref);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _GroupList extends ConsumerWidget {
  const _GroupList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsListProvider);
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    final me = ref.watch(authUserProvider).value?.id;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(groupsListProvider);
        await ref.read(groupsListProvider.future).catchError((_) => <Group>[]);
      },
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          4,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          ...switch (groups) {
            AsyncData(value: final list) when list.isEmpty => [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
                child: Text(
                  'No groups yet. Create one, or join with an invite code.',
                  style: text.bodyMedium?.copyWith(color: t.textMuted),
                ),
              ),
              FilledButton(
                onPressed: () => _createGroup(context, ref),
                child: const Text('Create group'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => _joinGroup(context, ref),
                child: const Text('Join with a code'),
              ),
            ],
            AsyncData(value: final list) => [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
                child: Text('My groups', style: text.titleMedium),
              ),
              for (final g in list) ...[
                SoftCard(
                  onTap: () => _open(context, g.id, g.name),
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Row(
                    children: [
                      GroupBadge(id: g.id, size: 58),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(g.name, style: text.titleMedium),
                            const SizedBox(height: 2),
                            Text(
                              '${g.memberCount} ${g.memberCount == 1 ? 'member' : 'members'}  •  You\'re in',
                              style: text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: t.textMuted),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (list.isNotEmpty) ...[
                const SizedBox(height: 14),
                _LeaderboardPreview(group: list.first, me: me),
              ],
            ],
            AsyncError() => [
              Text('Could not load your groups.', style: text.bodyMedium),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, kMinTapTarget),
                ),
                onPressed: () => ref.invalidate(groupsListProvider),
                child: const Text('Try again'),
              ),
            ],
            _ => const [
              Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          },
        ],
      ),
    );
  }
}

/// "Leaderboards": this week's top three in the first group, with the same
/// Volume | Consistency switch as the group screen.
class _LeaderboardPreview extends ConsumerWidget {
  const _LeaderboardPreview({required this.group, required this.me});

  final Group group;
  final String? me;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    final metric = ref.watch(leaderboardMetricProvider);
    final board = ref.watch(groupLeaderboardProvider(group.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('Leaderboards', style: text.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 12),
          child: Text(
            'Weekly  •  ${group.name}',
            style: text.bodyMedium?.copyWith(color: t.textMuted),
          ),
        ),
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
        const SizedBox(height: 12),
        switch (board) {
          AsyncData(value: final entries) when entries.isEmpty => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(
              'No one is sharing workouts yet.',
              style: text.bodyMedium?.copyWith(color: t.textMuted),
            ),
          ),
          AsyncData(value: final entries) => LeaderboardCard(
            entries: entries,
            metric: metric,
            me: me,
            limit: 3,
            footer: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 44),
                ),
                onPressed: () => _open(context, group.id, group.name),
                child: const Text('View full leaderboard'),
              ),
            ),
          ),
          AsyncError() => Text(
            'Could not load the leaderboard.',
            style: text.bodySmall,
          ),
          _ => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        },
      ],
    );
  }
}
