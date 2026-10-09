import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../account/sync_providers.dart';
import 'groups_models.dart';
import 'groups_providers.dart';
import 'groups_widgets.dart';

/// Name, invite link, what you share with this group, and leaving.
class GroupSettingsScreen extends ConsumerWidget {
  const GroupSettingsScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupProvider(groupId));
    final roster = ref.watch(groupRosterProvider(groupId)).value;
    final me = ref.watch(authUserProvider).value?.id;
    final text = Theme.of(context).textTheme;
    final muted = text.bodySmall?.copyWith(color: context.tokens.textMuted);
    final actions = ref.read(groupsActionsProvider);

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Group settings')),
        body: const SizedBox.shrink(),
      );
    }

    final isOwner = group.ownerId == me;
    GroupMember? mine;
    for (final m in roster ?? const <GroupMember>[]) {
      if (m.userId == me) mine = m;
    }

    Future<void> guarded(Future<void> Function() action) async {
      try {
        await action();
      } catch (e) {
        if (context.mounted) showGroupsError(context, e);
      }
    }

    Future<void> rename() async {
      final name = await showDialog<String>(
        context: context,
        builder: (_) => TextPromptDialog(
          title: 'Group name',
          label: 'Group name',
          action: 'Save',
          initial: group.name,
          maxLength: 40,
        ),
      );
      if (name == null) return;
      await guarded(() => actions.rename(groupId, name));
    }

    Future<void> copyLink() async {
      await Clipboard.setData(
        ClipboardData(
          text:
              'Join my group "${group.name}" in Well-Being. Tap the link to '
              'open the app and join: ${inviteLink(group.inviteCode)}\n'
              'If the link does not open, go to Groups, choose Join with a '
              'code and paste it.',
        ),
      );
      if (context.mounted) showGroupsMessage(context, 'Invite copied.');
    }

    Future<void> newLink() async {
      final ok = await confirm(
        context,
        title: 'Make a new invite link?',
        body: 'The current link will stop working. Members stay in the group.',
        action: 'Make new link',
      );
      if (!ok) return;
      await guarded(() => actions.rotateInvite(groupId));
    }

    Future<void> leave() async {
      final ok = await confirm(
        context,
        title: 'Leave ${group.name}?',
        body:
            'You will stop seeing this group. Your own workouts and data '
            'stay on your phone and in your account.',
        action: 'Leave',
      );
      if (!ok) return;
      try {
        await actions.leave(groupId);
        if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
      } catch (e) {
        if (context.mounted) showGroupsError(context, e);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Group settings')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          Card(
            child: ListTile(
              minTileHeight: kMinTapTarget + 8,
              title: const Text('Name'),
              subtitle: Text(group.name),
              trailing: isOwner ? const Icon(Icons.edit_outlined) : null,
              onTap: isOwner ? rename : null,
            ),
          ),
          const SizedBox(height: 16),
          Text('Invite', style: text.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Anyone with the link can join, up to 20 members. Code: '
            '${group.inviteCode}',
            style: muted,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(kMinTapTarget),
            ),
            onPressed: copyLink,
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copy invite'),
          ),
          if (isOwner)
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(kMinTapTarget),
              ),
              onPressed: newLink,
              child: const Text('Make a new invite link'),
            ),
          const SizedBox(height: 16),
          Text('What you share here', style: text.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Only what is switched on is visible to this group. Turning '
            'something off hides it again straight away. Sleep and screen '
            'time are never shared.',
            style: muted,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Workouts'),
                  subtitle: const Text(
                    'Appear in the activity feed and on the leaderboard.',
                  ),
                  value: mine?.shareWorkouts ?? true,
                  onChanged: mine == null
                      ? null
                      : (v) => guarded(
                          () => actions.setSharing(groupId, workouts: v),
                        ),
                ),
                SwitchListTile(
                  title: const Text('Break goals'),
                  subtitle: const Text(
                    'Appear in the activity feed and count towards active '
                    'days.',
                  ),
                  value: mine?.shareBreaks ?? true,
                  onChanged: mine == null
                      ? null
                      : (v) => guarded(
                          () => actions.setSharing(groupId, breaks: v),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(kMinTapTarget),
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: leave,
            child: const Text('Leave group'),
          ),
        ],
      ),
    );
  }
}
