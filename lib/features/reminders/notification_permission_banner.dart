import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import 'reminder_providers.dart';

/// Whether the phone currently lets this app show notifications. Re-read
/// whenever the app returns to the foreground (for example from settings).
final notificationAllowedProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(notificationSchedulerProvider).hasPermission(),
);

/// A calm, non-blocking warning shown when reminders are switched on for a
/// habit but notifications are off in Android settings. Preferences are kept
/// and logging in the app works; the button opens the phone's settings.
class NotificationPermissionBanner extends ConsumerStatefulWidget {
  const NotificationPermissionBanner({super.key, required this.remindersOn});

  /// At least one habit has a reminder turned on.
  final bool remindersOn;

  @override
  ConsumerState<NotificationPermissionBanner> createState() =>
      _NotificationPermissionBannerState();
}

class _NotificationPermissionBannerState
    extends ConsumerState<NotificationPermissionBanner>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(notificationAllowedProvider);
      ref.invalidate(upcomingRemindersProvider);
      // Permission may have just been granted: put the reminders back.
      ref.read(reminderServiceProvider).reschedule();
    }
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(notificationAllowedProvider).value ?? true;
    if (!widget.remindersOn || allowed) return const SizedBox.shrink();
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return Container(
      key: const Key('notification-warning'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.error),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              'Notifications are turned off for this app, so reminders will '
              'not appear. Your reminder settings are kept, and you can still '
              'log habits here.',
              style: text.bodyMedium,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: () =>
                  ref.read(systemSettingsProvider).openNotificationSettings(),
              child: const Text('Open notification settings'),
            ),
          ),
        ],
      ),
    );
  }
}
