import 'package:flutter/material.dart';

import '../../data/tables/tables.dart';
import 'reminder_config.dart';

/// Starting values for each kind of habit (spec 5, Habits and breaks).
class HabitDefaults {
  const HabitDefaults({
    required this.label,
    required this.icon,
    required this.dailyTarget,
    required this.config,
  });

  final String label;
  final IconData icon;
  final int dailyTarget;
  final ReminderConfig config;
}

const _day = {1, 2, 3, 4, 5, 6, 7};

final habitDefaults = <HabitKind, HabitDefaults>{
  HabitKind.water: const HabitDefaults(
    label: 'Water',
    icon: Icons.water_drop_outlined,
    dailyTarget: 6,
    config: ReminderConfig(
      windowStart: 9 * 60,
      windowEnd: 17 * 60,
      everyMinutes: 120,
      activeDays: _day,
    ),
  ),
  HabitKind.stand: const HabitDefaults(
    label: 'Stand',
    icon: Icons.accessibility_new_rounded,
    dailyTarget: 8,
    config: ReminderConfig(
      windowStart: 9 * 60,
      windowEnd: 16 * 60,
      everyMinutes: 60,
      activeDays: _day,
    ),
  ),
  HabitKind.stretch: const HabitDefaults(
    label: 'Stretch',
    icon: Icons.self_improvement_rounded,
    dailyTarget: 4,
    config: ReminderConfig(
      windowStart: 9 * 60,
      windowEnd: 15 * 60,
      everyMinutes: 120,
      activeDays: _day,
    ),
  ),
  HabitKind.custom: const HabitDefaults(
    label: 'Custom',
    icon: Icons.eco_outlined,
    dailyTarget: 1,
    config: ReminderConfig(
      mode: ReminderMode.times,
      times: [12 * 60],
      activeDays: _day,
    ),
  ),
};

IconData habitIcon(HabitKind kind) => habitDefaults[kind]!.icon;

/// "Every 2 hours", "Every 90 minutes", or the times of day.
String describeInterval(int minutes) {
  if (minutes % 60 == 0) {
    final h = minutes ~/ 60;
    return h == 1 ? 'Every hour' : 'Every $h hours';
  }
  return 'Every $minutes minutes';
}
