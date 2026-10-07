import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/placeholder_screen.dart';
import '../features/streaks/celebration_host.dart';
import '../features/streaks/streak_providers.dart';
import '../features/today/today_screen.dart';
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

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // Keeps the streak cache fresh and awards badges while the app is open.
    ref.watch(streakEffectsProvider);

    return CelebrationHost(
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [
            TodayScreen(),
            WeekScreen(),
            PlaceholderScreen(title: 'Groups', note: 'No groups yet.'),
            PlaceholderScreen(title: 'Insights', note: 'No insights yet.'),
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
