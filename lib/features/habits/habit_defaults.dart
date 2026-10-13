import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../data/tables/tables.dart';
import 'reminder_config.dart';

/// Starting values for each kind of habit (spec 5, Healthy Habits).
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
    icon: Icons.water_drop_rounded,
    dailyTarget: 6,
    config: ReminderConfig(
      windowStart: 9 * 60,
      windowEnd: 17 * 60,
      everyMinutes: 120,
      activeDays: _day,
    ),
  ),
  HabitKind.stand: const HabitDefaults(
    label: 'Stand and move',
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
    icon: Icons.sports_gymnastics_rounded,
    dailyTarget: 4,
    config: ReminderConfig(
      windowStart: 9 * 60,
      windowEnd: 15 * 60,
      everyMinutes: 120,
      activeDays: _day,
    ),
  ),
  HabitKind.moisturize: const HabitDefaults(
    label: 'Moisturize',
    icon: Icons.spa_rounded,
    dailyTarget: 2,
    config: ReminderConfig(
      mode: ReminderMode.times,
      times: [8 * 60, 21 * 60],
      activeDays: _day,
    ),
  ),
  HabitKind.skinCare: const HabitDefaults(
    label: 'Skin care',
    icon: Icons.face_retouching_natural_rounded,
    dailyTarget: 2,
    config: ReminderConfig(
      mode: ReminderMode.times,
      times: [8 * 60, 21 * 60],
      activeDays: _day,
    ),
  ),
  HabitKind.custom: const HabitDefaults(
    label: 'Custom',
    icon: Icons.eco_rounded,
    dailyTarget: 1,
    config: ReminderConfig(
      mode: ReminderMode.times,
      times: [12 * 60],
      activeDays: _day,
    ),
  ),
};

IconData habitIcon(HabitKind kind) => habitDefaults[kind]!.icon;

/// The tint a habit's icon sits on, by kind (reference: water is blue,
/// stand is green, stretch is pink-violet, anything else is a leaf).
Cat habitCat(HabitKind kind) => switch (kind) {
  HabitKind.water => Cat.water,
  HabitKind.stand => Cat.habit,
  HabitKind.stretch => Cat.stretch,
  HabitKind.moisturize || HabitKind.skinCare || HabitKind.custom => Cat.leaf,
};

/// "Every 2 hours", "Every 90 minutes", or the times of day.
String describeInterval(int minutes) {
  if (minutes % 60 == 0) {
    final h = minutes ~/ 60;
    return h == 1 ? 'Every hour' : 'Every $h hours';
  }
  return 'Every $minutes minutes';
}

/// Quick picks offered when adding a custom habit.
const customSuggestions = ['Meditation', 'Chanting'];

/// "6 reminders a day". Counts reminders, never hours.
String describeOccurrences(int n) =>
    n == 1 ? '1 reminder a day' : '$n reminders a day';
