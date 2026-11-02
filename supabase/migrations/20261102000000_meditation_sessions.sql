-- Meditation sessions (Goals redesign, 2 November 2026).
--
-- One new private table. The person chooses the length of each session, so
-- there is no goal column: a row is simply what was done.
--
--   * meditation_sessions is private. Only its owner can read or write it,
--     and no group policy or function reads it.
--   * It joins the sync protocol like every other private table: a sync_seq
--     stamped by the sync_guard trigger, soft deletes, last write wins.
--   * delete_my_account() needs no change: the table references auth.users
--     with on delete cascade.
--
-- Safe to run twice. Run it by hand in the Supabase SQL editor, after
-- 20261013000000_group_categories.sql.

create table if not exists public.meditation_sessions (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  started_at timestamptz not null,
  planned_minutes integer not null check (planned_minutes > 0),
  duration_seconds integer not null check (duration_seconds >= 0),
  completed boolean not null default false,
  tz_offset_minutes integer not null default 0,
  local_date text not null,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  sync_seq bigint not null default 0
);

create index if not exists meditation_sessions_owner_seq_idx
  on public.meditation_sessions (user_id, sync_seq);

drop trigger if exists meditation_sessions_sync_guard on public.meditation_sessions;
create trigger meditation_sessions_sync_guard
  before insert or update on public.meditation_sessions
  for each row execute function public.sync_guard();

alter table public.meditation_sessions enable row level security;

drop policy if exists "meditation_sessions: owner reads" on public.meditation_sessions;
create policy "meditation_sessions: owner reads"
  on public.meditation_sessions for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "meditation_sessions: owner inserts" on public.meditation_sessions;
create policy "meditation_sessions: owner inserts"
  on public.meditation_sessions for insert to authenticated
  with check (user_id = (select auth.uid()));

drop policy if exists "meditation_sessions: owner updates" on public.meditation_sessions;
create policy "meditation_sessions: owner updates"
  on public.meditation_sessions for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- No delete policy on purpose: clients soft-delete with deleted_at.
grant select, insert, update on public.meditation_sessions to authenticated;
