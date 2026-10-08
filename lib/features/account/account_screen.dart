import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../settings/settings_screen.dart';
import 'auth_service.dart';
import 'sync_providers.dart';

/// Sign-in and sync status. Everything in the app works without an account;
/// signing in adds backup and use on more than one phone.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
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
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          Card(
            child: ListTile(
              minTileHeight: kMinTapTarget + 8,
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              ),
            ),
          ),
          const SizedBox(height: 16),
          body,
        ],
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
