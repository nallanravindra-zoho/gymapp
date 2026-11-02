-- GPS distance for walks and runs (Goals redesign, 2 November 2026).
--
-- A timed walk or run can now follow its distance by GPS. The workout's
-- metrics_note says where the distance came from, so it gains a third value:
--
--   estimated  distance worked out from steps
--   measured   distance entered by the person
--   gps        distance followed by GPS (new)
--
-- Only the check constraint changes; no data is touched. Safe to run twice.
-- Run it by hand in the Supabase SQL editor, after
-- 20261102000000_meditation_sessions.sql.

alter table public.workouts drop constraint if exists workouts_metrics_note_check;
alter table public.workouts
  add constraint workouts_metrics_note_check
  check (metrics_note is null or metrics_note in ('estimated', 'measured', 'gps'));
