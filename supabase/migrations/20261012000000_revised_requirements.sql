-- Well-Being Companion: data model for the revised requirements (R2-R11).
--
-- Run once in the Supabase SQL editor, after the earlier migrations. Safe to
-- run again: tables and columns are created only when missing, and triggers
-- and policies are replaced.
--
-- What changes
--   * New private tables: hobbies, hobby_logs, body_measurements,
--     habit_skips. Same rules as every other private table: row-level
--     security on, owner-only select/insert/update, no client delete (clients
--     soft-delete with deleted_at), the sync_guard trigger stamps sync_seq.
--   * New columns on profiles, workouts and screen_time_daily.
--   * habits.kind accepts 'moisturize' and 'skinCare' (the app stores enum
--     names as written in Dart).
--   * Group sharing gets one switch per new category on group_members. Sleep,
--     screen time and hobbies are OFF by default and need an explicit opt-in
--     per group (workouts and Healthy Habits keep their existing defaults).
--   * body_measurements is never shared with groups: no group policy or
--     function reads it.
--   * delete_my_account() needs no change: every new table references
--     auth.users with "on delete cascade", so deleting the account removes
--     the new rows too (tests/revised_requirements.sql checks this).

-- profiles ---------------------------------------------------------------
alter table public.profiles
  add column if not exists date_of_birth text,
  add column if not exists gender text,
  add column if not exists height_cm double precision,
  add column if not exists weight_kg double precision,
  add column if not exists measurement_cadence text not null default 'monthly',
  add column if not exists measurement_reminder_enabled boolean not null default true,
  add column if not exists next_measurement_due text,
  add column if not exists reminder_sound text,
  add column if not exists habit_threshold integer not null default 1;

alter table public.profiles
  drop constraint if exists profiles_measurement_cadence_check;
alter table public.profiles
  add constraint profiles_measurement_cadence_check
  check (measurement_cadence in ('weekly', 'biweekly', 'monthly', 'bimonthly'));

alter table public.profiles
  drop constraint if exists profiles_habit_threshold_check;
alter table public.profiles
  add constraint profiles_habit_threshold_check check (habit_threshold >= 1);


-- workouts ---------------------------------------------------------------
-- Calories are always an estimate; steps_source is 'sensor' or 'estimate';
-- metrics_note is 'estimated' or 'measured'.
alter table public.workouts
  add column if not exists calories_estimate integer,
  add column if not exists steps integer,
  add column if not exists steps_source text,
  add column if not exists distance_km double precision,
  add column if not exists avg_speed_kmh double precision,
  add column if not exists paused_seconds integer not null default 0,
  add column if not exists active_seconds integer,
  add column if not exists metrics_note text;

alter table public.workouts drop constraint if exists workouts_steps_source_check;
alter table public.workouts
  add constraint workouts_steps_source_check
  check (steps_source is null or steps_source in ('sensor', 'estimate'));

alter table public.workouts drop constraint if exists workouts_metrics_note_check;
alter table public.workouts
  add constraint workouts_metrics_note_check
  check (metrics_note is null or metrics_note in ('estimated', 'measured'));


-- screen_time_daily ---------------------------------------------------------------
alter table public.screen_time_daily
  add column if not exists source text not null default 'automatic',
  add column if not exists target_minutes integer;

alter table public.screen_time_daily
  drop constraint if exists screen_time_daily_source_check;
alter table public.screen_time_daily
  add constraint screen_time_daily_source_check
  check (source in ('automatic', 'manual'));


-- habits ---------------------------------------------------------------
alter table public.habits drop constraint if exists habits_kind_check;
alter table public.habits
  add constraint habits_kind_check
  check (kind in ('water', 'stand', 'stretch', 'custom', 'moisturize', 'skinCare'));


-- habit_skips ---------------------------------------------------------------
-- A reminder the person skipped. Kept apart from habit_logs so a skip can
-- never count towards a target.
create table if not exists public.habit_skips (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  habit_id uuid not null,
  skipped_at timestamptz not null,
  tz_offset_minutes integer not null default 0,
  local_date text not null,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  sync_seq bigint not null default 0
);


-- hobbies ---------------------------------------------------------------
create table if not exists public.hobbies (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  icon_key text not null,
  is_builtin boolean not null default false,
  goal_period text check (goal_period in ('daily', 'weekly')),
  goal_value integer check (goal_value is null or goal_value > 0),
  goal_unit text not null default 'minutes' check (goal_unit in ('minutes', 'sessions')),
  reminder_enabled boolean not null default false,
  reminder_config text not null default '{}',
  is_active boolean not null default true,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  sync_seq bigint not null default 0
);


-- hobby_logs ---------------------------------------------------------------
create table if not exists public.hobby_logs (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  hobby_id uuid not null,
  started_at timestamptz not null,
  ended_at timestamptz,
  duration_minutes integer not null check (duration_minutes >= 0),
  count_or_sessions integer not null default 1 check (count_or_sessions >= 0),
  source text not null check (source in ('timer', 'manual')),
  tz_offset_minutes integer not null default 0,
  local_date text not null,
  note text,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  sync_seq bigint not null default 0
);


-- body_measurements ---------------------------------------------------------------
-- Private: never read by any group policy or function. Every value is
-- optional so a partial record is fine. Lengths are in inches.
create table if not exists public.body_measurements (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  measured_at timestamptz not null,
  tz_offset_minutes integer not null default 0,
  local_date text not null,
  weight_kg double precision,
  height_cm double precision,
  bmi double precision,
  waist_in double precision,
  hips_in double precision,
  chest_in double precision,
  arm_in double precision,
  thigh_in double precision,
  notes text,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  sync_seq bigint not null default 0
);


-- Indexes, sync trigger and private-by-default policies for the new tables.
do $$
declare
  t text;
begin
  foreach t in array array['habit_skips', 'hobbies', 'hobby_logs', 'body_measurements']
  loop
    execute format(
      'create index if not exists %I on public.%I (user_id, sync_seq)',
      t || '_owner_seq_idx', t);

    execute format('drop trigger if exists %I on public.%I', t || '_sync_guard', t);
    execute format(
      'create trigger %I before insert or update on public.%I
         for each row execute function public.sync_guard()',
      t || '_sync_guard', t);

    execute format('alter table public.%I enable row level security', t);

    execute format('drop policy if exists %I on public.%I', t || ': owner reads', t);
    execute format(
      'create policy %I on public.%I for select to authenticated
         using (user_id = (select auth.uid()))',
      t || ': owner reads', t);

    execute format('drop policy if exists %I on public.%I', t || ': owner inserts', t);
    execute format(
      'create policy %I on public.%I for insert to authenticated
         with check (user_id = (select auth.uid()))',
      t || ': owner inserts', t);

    execute format('drop policy if exists %I on public.%I', t || ': owner updates', t);
    execute format(
      'create policy %I on public.%I for update to authenticated
         using (user_id = (select auth.uid()))
         with check (user_id = (select auth.uid()))',
      t || ': owner updates', t);

    -- No delete policy on purpose: clients soft-delete with deleted_at.
    execute format('grant select, insert, update on public.%I to authenticated', t);
  end loop;
end $$;


-- Group sharing, per category --------------------------------------------------
-- share_workouts and share_breaks (Healthy Habits) already exist. The new
-- categories are private until a member opts in, per group.
alter table public.group_members
  add column if not exists share_sleep boolean not null default false,
  add column if not exists share_screen_time boolean not null default false,
  add column if not exists share_hobbies boolean not null default false;

grant update (share_workouts, share_breaks, share_sleep, share_screen_time, share_hobbies)
  on public.group_members to authenticated;

-- member_shares() is deliberately left as it was (workouts and breaks only):
-- nothing in a group reads sleep, screen-time or hobby data yet. When the
-- category leaderboards arrive they read the share_* switches above directly.
