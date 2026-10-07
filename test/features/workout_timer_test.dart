import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/features/workouts/workout_timer.dart';

void main() {
  final t0 = DateTime.utc(2026, 5, 13, 10);

  test('elapsed is computed from timestamps', () {
    final s = TimerState(workoutTypeId: 'a', startedAt: t0);
    expect(
      s.elapsed(t0.add(const Duration(minutes: 32, seconds: 18))),
      const Duration(minutes: 32, seconds: 18),
    );
  });

  test('paused time is excluded and the clock freezes while paused', () {
    var s = TimerState(workoutTypeId: 'a', startedAt: t0);
    s = s.pause(t0.add(const Duration(minutes: 10)));
    // Frozen at 10 minutes however long the pause lasts.
    expect(
      s.elapsed(t0.add(const Duration(minutes: 40))),
      const Duration(minutes: 10),
    );
    s = s.resume(t0.add(const Duration(minutes: 30)));
    expect(
      s.elapsed(t0.add(const Duration(minutes: 45))),
      const Duration(minutes: 25),
    ); // 10 before + 15 after, 20 paused
  });

  test('pause and resume are idempotent', () {
    var s = TimerState(workoutTypeId: 'a', startedAt: t0);
    expect(s.resume(t0), same(s));
    s = s.pause(t0.add(const Duration(minutes: 5)));
    expect(s.pause(t0.add(const Duration(minutes: 9))).pausedAt, s.pausedAt);
  });

  test('survives a JSON round trip (app killed and reopened)', () {
    var s = TimerState(workoutTypeId: 'builtin-yoga', startedAt: t0);
    s = s.pause(t0.add(const Duration(minutes: 3)));
    final back = TimerState.fromJson(s.toJson())!;
    expect(back.workoutTypeId, 'builtin-yoga');
    expect(back.isPaused, isTrue);
    expect(
      back.elapsed(t0.add(const Duration(hours: 5))),
      const Duration(minutes: 3),
    );
  });

  test('bad stored data yields no timer', () {
    expect(TimerState.fromJson(null), isNull);
    expect(TimerState.fromJson('not json'), isNull);
  });

  test('formatElapsed', () {
    expect(formatElapsed(const Duration(minutes: 32, seconds: 18)), '32:18');
    expect(
      formatElapsed(const Duration(hours: 1, minutes: 2, seconds: 3)),
      '01:02:03',
    );
  });
}
