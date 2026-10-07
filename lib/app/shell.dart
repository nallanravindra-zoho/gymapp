import 'package:flutter/material.dart';

import '../core/theme/section_theme.dart';
import '../core/widgets/placeholder_screen.dart';

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
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          PlaceholderScreen(
            title: 'Today',
            note: 'No workouts logged this week.',
            section: AppSection.workout,
          ),
          PlaceholderScreen(title: 'Week', note: 'Week view.'),
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
    );
  }
}
