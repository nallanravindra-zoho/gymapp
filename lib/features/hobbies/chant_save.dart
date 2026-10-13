import '../../data/app_database.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/hobby_repository.dart';
import '../../data/tables/tables.dart';
import 'chant_logic.dart';

/// The user's Chanting habit: the first one named "Chanting", ignoring case
/// and surrounding spaces. Null when there is none.
Habit? findChantingHabit(Iterable<Habit> habits) {
  for (final h in habits) {
    if (h.name.trim().toLowerCase() == 'chanting') return h;
  }
  return null;
}

class ChantSaveResult {
  const ChantSaveResult({this.habitLogId, this.hobbyLogId});
  final String? habitLogId;
  final String? hobbyLogId;
  bool get savedAnything => habitLogId != null || hobbyLogId != null;
}

/// Saves a finished chanting session:
///
/// * with a [habit], one log of [ChantSummary.count] completions on that
///   habit (the count of chants), at the time the session ended;
/// * with a [hobbyId], one timer log on that hobby for the session's minutes,
///   one session, with a note of the chant count.
///
/// Either, both or neither may be given.
Future<ChantSaveResult> saveChantSession({
  required ChantSummary summary,
  required String userId,
  required int dayCutoffMinutes,
  required HabitRepository habits,
  required HobbyRepository hobbies,
  Habit? habit,
  String? hobbyId,
}) async {
  String? habitLogId;
  String? hobbyLogId;
  if (habit != null && summary.count > 0) {
    habitLogId = await habits.log(
      habit: habit,
      dayCutoffMinutes: dayCutoffMinutes,
      count: summary.count,
      at: summary.endedAt,
    );
  }
  if (hobbyId != null) {
    hobbyLogId = await hobbies.addLog(
      userId: userId,
      hobbyId: hobbyId,
      dayCutoffMinutes: dayCutoffMinutes,
      source: HobbyLogSource.timer,
      startedAt: summary.startedAt,
      endedAt: summary.endedAt,
      durationMinutes: summary.minutes,
      note:
          'Om chanting: ${summary.count} '
          '${summary.count == 1 ? 'chant' : 'chants'}',
    );
  }
  return ChantSaveResult(habitLogId: habitLogId, hobbyLogId: hobbyLogId);
}
