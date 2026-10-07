import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/placeholder_screen.dart';
import '../data/providers.dart';
import '../features/reminders/action_bridge.dart';
import '../features/reminders/reminder_providers.dart';
import '../features/screen_time/screen_time_providers.dart';
import '../features/insights/insights_screen.dart';
import '../features/streaks/celebration_host.dart';
import '../features/streaks/streak_providers.dart';
import '../features/today/today_screen.dart';
import '../features/week/week_providers.dart';
import '../features/week/week_screen.dart';

class _Tab {
  const _Tab(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _tabs = [
  _Tab('Today', Icons.today_outlined, Icons.today),
  _Tab('Week', Icons.calendar_view_week_outlined, Icons.calendar_view_week),
  _Tab('Groups', Icons.group_outlined, Icons.group),
  _Tab('Insights', Icons.insights_outlined, Icons.insights),
  _Tab('Chat', Icons.chat_bubble_outline, Icons.chat_bubble),
];

/// Bottom-tab shell (spec section 5). Each tab keeps its own state.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  int _index = 0;
  void Function()? _stopListening;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // A notification action may have written data from a background isolate.
    _stopListening = listenForActionResults(_refreshFromDatabase);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopListening?.call();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshFromDatabase();
  }

  /// Re-reads data that may have changed outside this isolate, and moves
  /// "today" forward if midnight passed while the app was in the background.
  void _refreshFromDatabase() {
    if (!mounted) return;
    final db = ref.read(databaseProvider);
    db.markTablesUpdated([db.habitLogs, db.habits]);
    ref.invalidate(todayDateProvider);
    // Usage access may have been granted in system settings; re-check, which
    // also refreshes today's totals.
    ref.invalidate(screenTimeAccessProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the streak cache fresh and awards badges while the app is open.
    ref.watch(streakEffectsProvider);
    // Keeps scheduled reminders in step with habits and today's progress.
    ref.watch(reminderEffectsProvider);
    // Reads phone usage into the database once access is granted.
    ref.watch(screenTimeEffectsProvider);

    return CelebrationHost(
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [
            TodayScreen(),
            WeekScreen(),
            PlaceholderScreen(title: 'Groups', note: 'No groups yet.'),
            InsightsScreen(),
            PlaceholderScreen(title: 'Chat', note: 'Not available yet.'),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            for (final t in _tabs)
              NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.selectedIcon),
                label: t.label,
              ),
          ],
        ),
      ),
    );
  }
}
