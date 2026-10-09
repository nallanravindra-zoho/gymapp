-- Well-Being Companion: private per-user data and sync support.
--
-- Run once in the Supabase SQL editor (or `supabase db push`).
--
-- Every table here is private: a signed-in user can read and write only their
-- own rows. Sleep and screen time are never visible to anyone else (spec 6.5).
-- Group tables arrive in a later migration with their own policies.
--
-- Sync model
--   * Clients write rows with their own `updated_at`. The newest write wins; a
--     stale or duplicate write is silently ignored (see sync_guard below).
--   * Each accepted write gets a new, ever-increasing `sync_seq`. Clients pull
--     with "give me rows after the last sync_seq I saw", so a device with a
--     slow or wrong clock cannot miss changes.
--   * Rows are never deleted by clients: they set `deleted_at` (soft delete)
--     and that change syncs like any other.

create sequence if not exists public.sync_seq;

-- The guard trigger runs as the signed-in user and calls nextval().
grant usage on sequence public.sync_seq to authenticated;

create or replace function public.sync_guard()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'UPDATE' then
    -- Keep the newer row: ignore writes that are not strictly newer.
    if new.updated_at <= old.updated_at then
      return null;
    end if;
  end if;
  new.sync_seq := nextval('public.sync_seq');
  return new;
end;
$$;


-- profiles ---------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default '',
  avatar_url text,
  timezone text not null default 'UTC',
  day_cutoff_minutes integer not null default 0,
  quiet_hours_start integer,
  quiet_hours_end integer,
  daily_reminder_cap integer not null default 6,
  weekly_rest_days integer not null default 2,
  freeze_enabled boolean not null default true,
  freeze_interval_days integer not null default 7,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  sync_seq bigint not null default 0
);

create index if not exists profiles_owner_seq_idx
  on public.profiles (id, sync_seq);

create trigger profiles_sync_guard
  before insert or update on public.profiles
  for each row execute function public.sync_guard();

alter table public.profiles enable row level security;

create policy "profiles: owner reads" on public.profiles
  for select to authenticated
  using (id = (select auth.uid()));

create policy "profiles: owner inserts" on public.profiles
  for insert to authenticated
  with check (id = (select auth.uid()));

create policy "profiles: owner updates" on public.profiles
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- No delete policy on purpose: clients soft-delete with deleted_at.
grant select, insert, update on public.profiles to authenticated;


-- workout_types ---------------------------------------------------------------
create table if not exists public.workout_types (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  icon_key text not null,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  sync_seq bigint not null default 0
);

create index if not exists workout_types_owner_seq_idx
  on public.workout_types (user_id, sync_seq);

create trigger workout_types_sync_guard
  before insert or update on public.workout_types
  for each row execute function public.sync_guard();

alter table public.workout_types enable row level security;

create policy "workout_types: owner reads" on public.workout_types
  for select to authenticated
  using (user_id = (select auth.uid()));

create policy "workout_types: owner inserts" on public.workout_types
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy "workout_types: owner updates" on public.workout_types
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- No delete policy on purpose: clients soft-delete with deleted_at.
grant select, insert, update on public.workout_types to authenticated;


-- workouts ---------------------------------------------------------------
create table if not exists public.workouts (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  workout_type_id text not null,
  started_at timestamptz not null,
  ended_at timestamptz not null,
  duration_minutes integer not null,
  intensity text check (intensity in ('low', 'mid', 'high')),
  note text,
  source text not null check (source in ('timer', 'manual')),
  tz_offset_minutes integer not null default 0,
  local_date text not null,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  sync_seq bigint not null default 0
);

create index if not exists workouts_owner_seq_idx
  on public.workouts (user_id, sync_seq);

create trigger workouts_sync_guard
  before insert or update on public.workouts
  for each row execute function public.sync_guard();

alter table public.workouts enable row level security;

create policy "workouts: owner reads" on public.workouts
  for select to authenticated
  using (user_id = (select auth.uid()));

create policy "workouts: owner inserts" on public.workouts
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy "workouts: owner updates" on public.workouts
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- No delete policy on purpose: clients soft-delete with deleted_at.
grant select, insert, update on public.workouts to authenticated;


-- habits ---------------------------------------------------------------
create table if not exists public.habits (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  kind text not null check (kind in ('water', 'stand', 'stretch', 'custom')),
  daily_target integer not null default 1,
  reminders_enabled boolean not null default false,
  reminder_config text not null default '{}',
  is_active boolean not null default true,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  sync_seq bigint not null default 0
);

create index if not exists habits_owner_seq_idx
  on public.habits (user_id, sync_seq);

create trigger habits_sync_guard
  before insert or update on public.habits
  for each row execute function public.sync_guard();

alter table public.habits enable row level security;

create policy "habits: owner reads" on public.habits
  for select to authenticated
  using (user_id = (select auth.uid()));

create policy "habits: owner inserts" on public.habits
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy "habits: owner updates" on public.habits
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- No delete policy on purpose: clients soft-delete with deleted_at.
grant select, insert, update on public.habits to authenticated;


-- habit_logs ---------------------------------------------------------------
create table if not exists public.habit_logs (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  habit_id uuid not null,
  logged_at timestamptz not null,
  count integer not null default 1,
  tz_offset_minutes integer not null default 0,
  local_date text not null,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  sync_seq bigint not null default 0
);

create index if not exists habit_logs_owner_seq_idx
  on public.habit_logs (user_id, sync_seq);

create trigger habit_logs_sync_guard
  before insert or update on public.habit_logs
  for each row execute function public.sync_guard();

alter table public.habit_logs enable row level security;

create policy "habit_logs: owner reads" on public.habit_logs
  for select to authenticated
  using (user_id = (select auth.uid()));

create policy "habit_logs: owner inserts" on public.habit_logs
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy "habit_logs: owner updates" on public.habit_logs
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- No delete policy on purpose: clients soft-delete with deleted_at.
grant select, insert, update on public.habit_logs to authenticated;


-- sleep_targets ---------------------------------------------------------------
create table if not exists public.sleep_targets (
  user_id uuid primary key references auth.users (id) on delete cascade,
  bedtime_minutes integer not null,
  wake_minutes integer not null,
  updated_at timestamptz not null,
  sync_seq bigint not null default 0
);

create index if not exists sleep_targets_owner_seq_idx
  on public.sleep_targets (user_id, sync_seq);

create trigger sleep_targets_sync_guard
  before insert or update on public.sleep_targets
  for each row execute function public.sync_guard();

alter table public.sleep_targets enable row level security;

create policy "sleep_targets: owner reads" on public.sleep_targets
  for select to authenticated
  using (user_id = (select auth.uid()));

create policy "sleep_targets: owner inserts" on public.sleep_targets
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy "sleep_targets: owner updates" on public.sleep_targets
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- No delete policy on purpose: clients soft-delete with deleted_at.
grant select, insert, update on public.sleep_targets to authenticated;


-- sleep_logs ---------------------------------------------------------------
create table if not exists public.sleep_logs (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  bedtime_at timestamptz not null,
  wake_at timestamptz not null,
  duration_minutes integer not null,
  tz_offset_minutes integer not null default 0,
  local_date text not null,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  sync_seq bigint not null default 0
);

create index if not exists sleep_logs_owner_seq_idx
  on public.sleep_logs (user_id, sync_seq);

create trigger sleep_logs_sync_guard
  before insert or update on public.sleep_logs
  for each row execute function public.sync_guard();

alter table public.sleep_logs enable row level security;

create policy "sleep_logs: owner reads" on public.sleep_logs
  for select to authenticated
  using (user_id = (select auth.uid()));

create policy "sleep_logs: owner inserts" on public.sleep_logs
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy "sleep_logs: owner updates" on public.sleep_logs
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- No delete policy on purpose: clients soft-delete with deleted_at.
grant select, insert, update on public.sleep_logs to authenticated;


-- rest_days ---------------------------------------------------------------
create table if not exists public.rest_days (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  local_date text not null,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  sync_seq bigint not null default 0
);

create index if not exists rest_days_owner_seq_idx
  on public.rest_days (user_id, sync_seq);

create trigger rest_days_sync_guard
  before insert or update on public.rest_days
  for each row execute function public.sync_guard();

alter table public.rest_days enable row level security;

create policy "rest_days: owner reads" on public.rest_days
  for select to authenticated
  using (user_id = (select auth.uid()));

create policy "rest_days: owner inserts" on public.rest_days
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy "rest_days: owner updates" on public.rest_days
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- No delete policy on purpose: clients soft-delete with deleted_at.
grant select, insert, update on public.rest_days to authenticated;


-- badges_awarded ---------------------------------------------------------------
create table if not exists public.badges_awarded (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  badge_key text not null,
  awarded_at timestamptz not null,
  context text not null default '{}',
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  sync_seq bigint not null default 0
);

create index if not exists badges_awarded_owner_seq_idx
  on public.badges_awarded (user_id, sync_seq);

create trigger badges_awarded_sync_guard
  before insert or update on public.badges_awarded
  for each row execute function public.sync_guard();

alter table public.badges_awarded enable row level security;

create policy "badges_awarded: owner reads" on public.badges_awarded
  for select to authenticated
  using (user_id = (select auth.uid()));

create policy "badges_awarded: owner inserts" on public.badges_awarded
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy "badges_awarded: owner updates" on public.badges_awarded
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- No delete policy on purpose: clients soft-delete with deleted_at.
grant select, insert, update on public.badges_awarded to authenticated;


-- screen_time_daily ---------------------------------------------------------------
create table if not exists public.screen_time_daily (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  local_date text not null,
  total_minutes integer not null,
  category_minutes text not null default '{}',
  late_evening_minutes integer not null default 0,
  share_in_groups boolean not null default false,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  sync_seq bigint not null default 0
);

create index if not exists screen_time_daily_owner_seq_idx
  on public.screen_time_daily (user_id, sync_seq);

create trigger screen_time_daily_sync_guard
  before insert or update on public.screen_time_daily
  for each row execute function public.sync_guard();

alter table public.screen_time_daily enable row level security;

create policy "screen_time_daily: owner reads" on public.screen_time_daily
  for select to authenticated
  using (user_id = (select auth.uid()));

create policy "screen_time_daily: owner inserts" on public.screen_time_daily
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy "screen_time_daily: owner updates" on public.screen_time_daily
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- No delete policy on purpose: clients soft-delete with deleted_at.
grant select, insert, update on public.screen_time_daily to authenticated;
