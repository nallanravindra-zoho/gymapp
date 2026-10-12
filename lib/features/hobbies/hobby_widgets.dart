import 'package:flutter/material.dart';

/// Icon keys a hobby can use. Built-ins use the first six.
const hobbyIconChoices = <String, IconData>{
  'music': Icons.music_note_rounded,
  'art': Icons.brush_rounded,
  'dance': Icons.accessibility_new_rounded,
  'learning': Icons.school_rounded,
  'reading': Icons.menu_book_rounded,
  'writing': Icons.edit_rounded,
  'hobby': Icons.interests_rounded,
  'garden': Icons.local_florist_rounded,
  'cook': Icons.restaurant_rounded,
  'craft': Icons.content_cut_rounded,
  'game': Icons.extension_rounded,
  'photo': Icons.photo_camera_rounded,
};

IconData hobbyIcon(String key) =>
    hobbyIconChoices[key] ?? hobbyIconChoices['hobby']!;

/// `6:00 PM` for a minute-of-day, in the phone's own time format.
String formatMinuteOfDay(BuildContext context, int minutes) =>
    TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context);

/// A labelled row that opens a picker, at least 48dp tall.
class PickerTile extends StatelessWidget {
  const PickerTile({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    minTileHeight: 48,
    title: Text(label),
    trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
    onTap: onTap,
  );
}
