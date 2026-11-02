-- Nutrition: manually logged meals (Goals redesign, 2 November 2026).
--
-- One new private table. Calories and macronutrients are optional estimates.
--
--   * meal_logs is private. Only its owner can read or write it, and no
--     group policy or function reads it.
--   * It joins the sync protocol like every other private table: a sync_seq
--     stamped by the sync_guard trigger, soft deletes, last write wins.
--   * delete_my_account() needs no change: the table references auth.users
--     with on delete cascade.
--
-- Safe to run twice. Run it by hand in the Supabase SQL editor, after
-- 20261102000001_gps_distance.sql.

create table if not exists public.meal_logs (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null check (length(btrim(name)) > 0),
  servings double precision not null default 1 check (servings > 0),
  calories integer check (calories is null or calories >= 0),
  protein_g double precision check (protein_g is null or protein_g >= 0),
  carbs_g double precision check (carbs_g is null or carbs_g >= 0),
  fat_g double precision check (fat_g is null or fat_g >= 0),
  source text not null default 'entered' check (source in ('listed', 'entered')),
  logged_at timestamptz not null,
  tz_offset_minutes integer not null default 0,
  local_date text not null,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  sync_seq bigint not null default 0
);

create index if not exists meal_logs_owner_seq_idx
  on public.meal_logs (user_id, sync_seq);

drop trigger if exists meal_logs_sync_guard on public.meal_logs;
create trigger meal_logs_sync_guard
  before insert or update on public.meal_logs
  for each row execute function public.sync_guard();

alter table public.meal_logs enable row level security;

drop policy if exists "meal_logs: owner reads" on public.meal_logs;
create policy "meal_logs: owner reads"
  on public.meal_logs for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "meal_logs: owner inserts" on public.meal_logs;
create policy "meal_logs: owner inserts"
  on public.meal_logs for insert to authenticated
  with check (user_id = (select auth.uid()));

drop policy if exists "meal_logs: owner updates" on public.meal_logs;
create policy "meal_logs: owner updates"
  on public.meal_logs for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- No delete policy on purpose: clients soft-delete with deleted_at.
grant select, insert, update on public.meal_logs to authenticated;
