import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/avatar_button.dart';
import '../account/account_screen.dart';
import '../account/sync_providers.dart';
import 'group_screen.dart';
import 'groups_models.dart';
import 'groups_providers.dart';
import 'groups_widgets.dart';
import 'invite_links.dart';

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
        title: const Text('Groups'),
        actions: const [AvatarButton()],
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

class _SignedOut extends ConsumerWidget {
  const _SignedOut();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasInvite = ref.watch(pendingInviteProvider) != null;
    const invitedNote = 'You have an invite to a group. Sign in to join it. ';
    return _Notice(
      title: 'Groups need an account',
      detail:
          '${hasInvite ? invitedNote : ''}'
          'Sign in to create a group or join one with an invite. Members see '
          'only what they choose to share. Sleep and screen time are never '
          'shared.',
      action: FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(kMinTapTarget),
        ),
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const AccountScreen())),
        child: const Text('Sign in'),
      ),
    );
  }
}

/// Asks about an invite code and joins: shows what the group is, asks for
/// confirmation, then opens the group. Used for pasted codes and tapped links.
Future<void> joinWithInvite(
  BuildContext context,
  WidgetRef ref,
  String code,
) async {
  try {
    final remote = ref.read(groupsRemoteProvider);
    final preview = await remote.previewInvite(code);
    if (!context.mounted) return;
    if (!preview.alreadyMember) {
      final ok = await confirm(
        context,
        title: 'Join ${preview.name}?',
        body:
            '${preview.memberCount} '
            '${preview.memberCount == 1 ? 'member' : 'members'}. '
            'They will see the workouts and break goals you choose to '
            'share. You can change that any time in group settings.',
        action: 'Join',
      );
      if (!ok || !context.mounted) return;
    }
    final id = await ref.read(groupsActionsProvider).join(code);
    if (context.mounted) _openGroup(context, id, preview.name);
  } catch (e) {
    if (context.mounted) showGroupsError(context, e);
  }
}

void _openGroup(BuildContext context, String id, String name) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => GroupScreen(groupId: id, initialName: name),
    ),
  );
}

class _GroupList extends ConsumerStatefulWidget {
  const _GroupList();

  @override
  ConsumerState<_GroupList> createState() => _GroupListState();
}

class _GroupListState extends ConsumerState<_GroupList> {
  @override
  void initState() {
    super.initState();
    // An invite that was tapped before sign-in, or while the app was closed,
    // is handled as soon as the list is on screen.
    ref.listenManual(pendingInviteProvider, (_, code) {
      if (code == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final taken = ref.read(pendingInviteProvider.notifier).take();
        if (taken != null) joinWithInvite(context, ref, taken);
      });
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsListProvider);
    final text = Theme.of(context).textTheme;

    Future<void> create() async {
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
      try {
        final g = await ref.read(groupsActionsProvider).create(name);
        if (context.mounted) _openGroup(context, g.id, g.name);
      } catch (e) {
        if (context.mounted) showGroupsError(context, e);
      }
    }

    Future<void> join() async {
      final input = await showDialog<String>(
        context: context,
        builder: (_) => const TextPromptDialog(
          title: 'Join a group',
          label: 'Invite link or code',
          action: 'Continue',
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
      await joinWithInvite(context, ref, code);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(groupsListProvider);
        await ref.read(groupsListProvider.future).catchError((_) => <Group>[]);
      },
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(kMinTapTarget),
                  ),
                  onPressed: create,
                  child: const Text('Create group'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(kMinTapTarget),
                  ),
                  onPressed: join,
                  child: const Text('Join with a code'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...switch (groups) {
            AsyncData(value: final list) when list.isEmpty => [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'No groups yet. Create one, or join with an invite code.',
                  style: text.bodyMedium?.copyWith(
                    color: context.tokens.textMuted,
                  ),
                ),
              ),
            ],
            AsyncData(value: final list) => [
              for (final g in list)
                Card(
                  child: ListTile(
                    minTileHeight: kMinTapTarget + 16,
                    title: Text(g.name),
                    subtitle: Text(
                      '${g.memberCount} ${g.memberCount == 1 ? 'member' : 'members'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openGroup(context, g.id, g.name),
                  ),
                ),
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
