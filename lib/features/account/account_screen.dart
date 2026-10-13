import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../streaks/streak_providers.dart';
import '../metrics/metrics_screen.dart';
import '../settings/settings_screen.dart';
import 'auth_service.dart';
import 'sync_providers.dart';

/// Sign-in and sync status. Everything in the app works without an account;
/// signing in adds backup and use on more than one phone.
class SyncAccountScreen extends ConsumerStatefulWidget {
  const SyncAccountScreen({super.key});

  @override
  ConsumerState<SyncAccountScreen> createState() => _SyncAccountScreenState();
}

class _SyncAccountScreenState extends ConsumerState<SyncAccountScreen> {
  bool _signingIn = false;

  Future<void> _signIn() async {
    setState(() => _signingIn = true);
    final result = await ref.read(authServiceProvider).signInWithGoogle();
    if (!mounted) return;
    setState(() => _signingIn = false);
    if (result == SignInResult.failed) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('Could not sign in. Try again.')),
        );
    }
  }

  Future<void> _signOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Your data stays on this phone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(authServiceProvider).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authServiceProvider);
    final user = ref.watch(authUserProvider).value;
    final status = ref.watch(syncControllerProvider);
    final text = Theme.of(context).textTheme;
    final t = context.tokens;

    Widget body;
    if (!auth.isAvailable) {
      final issue = ref.watch(syncSetupIssueProvider);
      final missing = AppConfig.missing;
      body = _Message(
        title: 'Sync is not set up in this build',
        detail: [
          'Everything works on this phone without an account.',
          if (issue != null)
            'Sync could not start: $issue'
          else if (missing.isNotEmpty)
            'This build is missing: ${missing.join(', ')}. Run it with '
                '--dart-define-from-file=env.json (see supabase/README.md).',
        ].join('\n\n'),
      );
    } else if (user == null) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Back up and sync', style: text.titleLarge),
          const SizedBox(height: 12),
          const Text(
            'Sign in to keep your data safe and use it on more than one '
            'phone. Everything also works without an account.',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(kMinTapTarget),
            ),
            onPressed: _signingIn ? null : _signIn,
            icon: const Icon(Icons.login_rounded),
            label: const Text('Continue with Google'),
          ),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              minTileHeight: kMinTapTarget + 16,
              leading: CircleAvatar(
                backgroundColor: t.accent.withValues(alpha: 0.15),
                child: Text(
                  (user.displayName ?? user.email ?? '?').characters.first
                      .toUpperCase(),
                  style: TextStyle(color: t.accent),
                ),
              ),
              title: Text(user.displayName ?? user.email ?? 'Signed in'),
              subtitle: user.displayName != null && user.email != null
                  ? Text(user.email!)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          if (status.accountConflict)
            _ConflictCard(
              onReplace: () =>
                  ref.read(syncControllerProvider.notifier).replaceLocalData(),
              onSignOut: _signOut,
            )
          else ...[
            Text('Sync', style: text.bodySmall),
            const SizedBox(height: 4),
            Text(_statusLine(context, status), style: text.bodyMedium),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(kMinTapTarget),
              ),
              onPressed: status.syncing
                  ? null
                  : () => ref.read(syncControllerProvider.notifier).syncNow(),
              child: const Text('Sync now'),
            ),
          ],
          const SizedBox(height: 24),
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, kMinTapTarget),
            ),
            onPressed: _signOut,
            child: const Text('Sign out'),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Account & sync')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [body],
      ),
    );
  }

  String _statusLine(BuildContext context, SyncStatus s) {
    if (s.syncing) return 'Syncing.';
    if (s.lastFailed) return 'Could not sync. It will retry.';
    final at = s.lastSyncedAt;
    if (at == null) return 'Not synced yet.';
    return 'Last synced ${TimeOfDay.fromDateTime(at.toLocal()).format(context)}.';
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.title, required this.detail});
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text(detail),
    ],
  );
}

class _ConflictCard extends StatelessWidget {
  const _ConflictCard({required this.onReplace, required this.onSignOut});

  final VoidCallback onReplace;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Different account',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'This phone holds data from another account. Replace it with '
              'this account\'s data, or sign out to keep it.',
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(kMinTapTarget),
              ),
              onPressed: onReplace,
              child: const Text('Replace data on this phone'),
            ),
          ],
        ),
      ),
    );
  }
}

/// One tappable row of a settings list.
class _HubRow extends StatelessWidget {
  const _HubRow({
    required this.icon,
    required this.title,
    required this.screen,
    this.subtitle,
    this.last = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget Function() screen;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        InkWell(
          onTap: () =>
              Navigator.of(context)
                  .push(MaterialPageRoute<void>(builder: (_) => screen())),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 66),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                children: [
                  Icon(icon, size: 26, color: t.text.withValues(alpha: 0.8)),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: text.bodyLarge),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: text.bodySmall?.copyWith(color: t.textMuted),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: t.textMuted),
                ],
              ),
            ),
          ),
        ),
        if (!last) const RowDivider(indent: 62),
      ],
    );
  }
}

Widget _listScreen(
  BuildContext context,
  String title,
  List<Widget> rows, {
  String? note,
}) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        if (note != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4),
            child: Text(
              note,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: context.tokens.textMuted),
            ),
          ),
        SoftCard(
          padding: EdgeInsets.zero,
          radius: 22,
          child: Column(children: rows),
        ),
      ],
    ),
  );
}

/// Profile Management: who you are and your body metrics.
class ProfileManagementScreen extends StatelessWidget {
  const ProfileManagementScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      _listScreen(context, 'Profile Management', [
        _HubRow(
          icon: Icons.person_outline_rounded,
          title: SettingsSection.profile.title,
          subtitle: 'Name, date of birth, picture',
          screen: () => const SettingsScreen(section: SettingsSection.profile),
        ),
        _HubRow(
          icon: Icons.height_rounded,
          title: SettingsSection.metrics.title,
          subtitle: 'Height and weight',
          screen: () => const SettingsScreen(section: SettingsSection.metrics),
        ),
        _HubRow(
          icon: Icons.straighten_rounded,
          title: 'Body measurements',
          subtitle: 'Records, reminders and guidance',
          screen: () => const MetricsScreen(),
          last: true,
        ),
      ], note: 'Private to you. Nothing here is shared with groups.');
}

/// App Management: how the app looks, sounds and keeps your data.
class AppManagementScreen extends StatelessWidget {
  const AppManagementScreen({super.key});

  @override
  Widget build(BuildContext context) => _listScreen(context, 'App Management', [
    _HubRow(
      icon: Icons.palette_outlined,
      title: SettingsSection.appearance.title,
      subtitle: 'Light, dark or system',
      screen: () => const SettingsScreen(section: SettingsSection.appearance),
    ),
    _HubRow(
      icon: Icons.notifications_none_rounded,
      title: SettingsSection.reminders.title,
      subtitle: 'Sound, quiet hours, daily limit',
      screen: () => const SettingsScreen(section: SettingsSection.reminders),
    ),
    _HubRow(
      icon: Icons.tune_rounded,
      title: SettingsSection.preferences.title,
      screen: () => const SettingsScreen(section: SettingsSection.preferences),
    ),
    _HubRow(
      icon: Icons.lock_outline_rounded,
      title: SettingsSection.data.title,
      screen: () => const SettingsScreen(section: SettingsSection.data),
    ),
    _HubRow(
      icon: Icons.cloud_sync_outlined,
      title: 'Account & sync',
      screen: () => const SyncAccountScreen(),
      last: true,
    ),
  ]);
}

/// Profile & Settings: who you are, and two places for everything else.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final u = ref.watch(userStreamProvider).value;
    final local = u?.displayName.trim() ?? '';
    final account = ref.watch(authUserProvider).value;
    final name = local.isNotEmpty
        ? local
        : (account?.displayName ?? account?.email ?? 'You');
    final photo = u?.avatarUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          Row(
            children: [
              Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.cat(Cat.leaf).tint,
                  border: Border.all(color: t.surface, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F1B2B45),
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: photo != null && photo.isNotEmpty
                    ? Image.file(
                        File(photo),
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _initial(text, t, name),
                      )
                    : _initial(text, t, name),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: text.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      'Well Being Companion',
                      style: text.bodyLarge?.copyWith(color: t.accent),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SoftCard(
            padding: EdgeInsets.zero,
            radius: 22,
            child: Column(
              children: [
                _HubRow(
                  icon: Icons.person_outline_rounded,
                  title: 'Profile Management',
                  subtitle: 'You, your metrics and measurements',
                  screen: () => const ProfileManagementScreen(),
                ),
                _HubRow(
                  icon: Icons.settings_outlined,
                  title: 'App Management',
                  subtitle: 'Appearance, reminders, data and account',
                  screen: () => const AppManagementScreen(),
                  last: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _initial(TextTheme text, AppTokens t, String name) => Text(
    name.characters.first.toUpperCase(),
    style: text.headlineMedium?.copyWith(color: t.cat(Cat.leaf).icon),
  );
}
