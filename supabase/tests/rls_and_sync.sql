-- Behaviour tests for 20261007000000_private_data_and_sync.sql.
--
-- Run against a scratch database that has the migration applied and a stand-in
-- for Supabase's `auth` schema (see supabase/README.md, "Testing the schema").
-- Every check raises an exception on failure, so a clean run means all passed.

\set ON_ERROR_STOP on
\set alice '''aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'''
\set bob   '''bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'''

insert into auth.users (id) values (:alice), (:bob);

create or replace function pg_temp.as_user(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  execute 'set role authenticated';
end $$;

create or replace function pg_temp.assert(cond boolean, msg text) returns void language plpgsql as $$
begin
  if not coalesce(cond, false) then raise exception 'FAILED: %', msg; end if;
end $$;

grant all on function pg_temp.as_user(text), pg_temp.assert(boolean, text) to public;

-- 1. A user can write and read their own rows; writes get a sync_seq. --------
select pg_temp.as_user(:alice);
insert into workouts (id, user_id, workout_type_id, started_at, ended_at,
  duration_minutes, source, local_date, created_at, updated_at)
values ('11111111-1111-4111-8111-111111111111', :alice, 'builtin-yoga',
  '2026-05-13 08:00+00', '2026-05-13 08:30+00', 30, 'manual', '2026-05-13',
  '2026-05-13 08:31+00', '2026-05-13 08:31+00');
select pg_temp.assert((select count(*) from workouts) = 1, 'alice sees her workout');
select pg_temp.assert((select sync_seq from workouts) > 0, 'insert is stamped with sync_seq');

-- 2. She cannot write a row as someone else. -----------------------------------
do $$ begin
  begin
    insert into workouts (id, user_id, workout_type_id, started_at, ended_at,
      duration_minutes, source, local_date, created_at, updated_at)
    values ('22222222-2222-4222-8222-222222222222',
      'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'builtin-run',
      now(), now(), 1, 'manual', '2026-05-13', now(), now());
    raise exception 'FAILED: alice wrote a row for bob';
  exception when insufficient_privilege then null; end;
end $$;

-- 3. Another user sees none of it and cannot change it. ------------------------
reset role;
select pg_temp.as_user(:bob);
select pg_temp.assert((select count(*) from workouts) = 0, 'bob sees nothing of alice');
update workouts set note = 'hijack' where id = '11111111-1111-4111-8111-111111111111';
reset role;
select pg_temp.assert((select note is null from workouts), 'bob could not edit alice''s row');

-- 4. Last write wins; stale and duplicate writes are ignored. ------------------
select pg_temp.as_user(:alice);
create temp table seq_before as select sync_seq as s from workouts;
grant all on seq_before to public;

-- Older than the stored row: ignored.
update workouts set note = 'stale', updated_at = '2026-05-13 08:00+00'
  where id = '11111111-1111-4111-8111-111111111111';
select pg_temp.assert((select note is null from workouts), 'stale update ignored');

-- Same timestamp: ignored (a duplicate push).
update workouts set note = 'dup', updated_at = '2026-05-13 08:31+00'
  where id = '11111111-1111-4111-8111-111111111111';
select pg_temp.assert((select note is null from workouts), 'duplicate update ignored');
select pg_temp.assert((select sync_seq from workouts) = (select s from seq_before),
  'ignored writes do not move sync_seq');

-- Newer: applied, and moves sync_seq forward.
update workouts set note = 'newer', updated_at = '2026-05-13 09:00+00'
  where id = '11111111-1111-4111-8111-111111111111';
select pg_temp.assert((select note from workouts) = 'newer', 'newer update applied');
select pg_temp.assert((select sync_seq from workouts) > (select s from seq_before),
  'accepted write moves sync_seq');

-- 5. Upsert, the way the app pushes (insert ... on conflict do update). --------
insert into workouts (id, user_id, workout_type_id, started_at, ended_at,
  duration_minutes, source, local_date, note, created_at, updated_at)
values ('11111111-1111-4111-8111-111111111111', :alice, 'builtin-yoga',
  '2026-05-13 08:00+00', '2026-05-13 08:30+00', 30, 'manual', '2026-05-13',
  'old device', '2026-05-13 08:31+00', '2026-05-13 08:45+00')
on conflict (id) do update set note = excluded.note, updated_at = excluded.updated_at;
select pg_temp.assert((select note from workouts) = 'newer', 'stale upsert did not overwrite');

insert into workouts (id, user_id, workout_type_id, started_at, ended_at,
  duration_minutes, source, local_date, note, created_at, updated_at)
values ('11111111-1111-4111-8111-111111111111', :alice, 'builtin-yoga',
  '2026-05-13 08:00+00', '2026-05-13 08:30+00', 30, 'manual', '2026-05-13',
  'newest', '2026-05-13 08:31+00', '2026-05-13 10:00+00')
on conflict (id) do update set note = excluded.note, updated_at = excluded.updated_at;
select pg_temp.assert((select note from workouts) = 'newest', 'newer upsert applied');
select pg_temp.assert((select count(*) from workouts) = 1, 'upsert never duplicates');

-- 6. Soft delete syncs like any other change; hard delete is not allowed. ------
update workouts set deleted_at = '2026-05-13 11:00+00', updated_at = '2026-05-13 11:00+00'
  where id = '11111111-1111-4111-8111-111111111111';
select pg_temp.assert((select deleted_at is not null from workouts), 'soft delete applied');
do $$ begin
  begin
    delete from workouts;
    raise exception 'FAILED: client could hard-delete';
  exception when insufficient_privilege then null; end;
end $$;

-- 7. A row cannot be handed to another user. -----------------------------------
do $$ begin
  begin
    update workouts set user_id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
      updated_at = '2026-05-13 12:00+00';
    raise exception 'FAILED: alice reassigned a row to bob';
  exception when insufficient_privilege then null; end;
end $$;

-- 8. Pulling: rows after a cursor, in order. ----------------------------------
insert into workouts (id, user_id, workout_type_id, started_at, ended_at,
  duration_minutes, source, local_date, created_at, updated_at)
select ('00000000-0000-4000-8000-00000000000' || i)::uuid, :alice, 'builtin-walk',
  now(), now(), 10, 'manual', '2026-05-14', now(), now()
from generate_series(1, 3) i;
create temp table cursor_at as select max(sync_seq) as c from workouts;
grant all on cursor_at to public;
insert into workouts (id, user_id, workout_type_id, started_at, ended_at,
  duration_minutes, source, local_date, created_at, updated_at)
values ('00000000-0000-4000-8000-000000000009', :alice, 'builtin-run',
  now(), now(), 10, 'manual', '2026-05-15', now(), now());
select pg_temp.assert(
  (select count(*) from workouts where sync_seq > (select c from cursor_at)) = 1,
  'pull after cursor returns only newer changes');

-- 9. Tables keyed by user (sleep targets, profiles). ---------------------------
insert into sleep_targets (user_id, bedtime_minutes, wake_minutes, updated_at)
values (:alice, 1350, 390, '2026-05-13 08:00+00')
on conflict (user_id) do update set bedtime_minutes = excluded.bedtime_minutes,
  wake_minutes = excluded.wake_minutes, updated_at = excluded.updated_at;
insert into sleep_targets (user_id, bedtime_minutes, wake_minutes, updated_at)
values (:alice, 1380, 420, '2026-05-13 07:00+00')   -- older: ignored
on conflict (user_id) do update set bedtime_minutes = excluded.bedtime_minutes,
  wake_minutes = excluded.wake_minutes, updated_at = excluded.updated_at;
select pg_temp.assert((select bedtime_minutes from sleep_targets) = 1350, 'sleep target LWW');

insert into profiles (id, display_name, created_at, updated_at)
values (:alice, 'Alice', now(), now());
select pg_temp.assert((select display_name from profiles) = 'Alice', 'profile written');

-- 10. Private tables stay private; anonymous users get nothing. ---------------
reset role;
select pg_temp.as_user(:bob);
select pg_temp.assert((select count(*) from sleep_targets) = 0, 'bob cannot see alice''s sleep');
select pg_temp.assert((select count(*) from profiles) = 0, 'bob cannot see alice''s profile');
reset role;
set role anon;
do $$ begin
  begin
    perform count(*) from workouts;
    raise exception 'FAILED: anon could read workouts';
  exception when insufficient_privilege then null; end;
end $$;
reset role;

-- 11. Every table, not just workouts: RLS on, every policy tied to the caller,
--     no delete for clients, nothing for anonymous users. ----------------------
do $$
declare t record;
begin
  for t in
    select c.relname, c.relrowsecurity
    from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relkind = 'r'
  loop
    if not t.relrowsecurity then
      raise exception 'FAILED: row level security is off on %', t.relname;
    end if;
    if exists (
      select 1 from pg_policies p
      where p.schemaname = 'public' and p.tablename = t.relname
        and (coalesce(p.qual, '') || coalesce(p.with_check, '')) not like '%auth.uid()%'
    ) then
      raise exception 'FAILED: a policy on % is not tied to auth.uid()', t.relname;
    end if;
    if (select count(*) from pg_policies p
        where p.schemaname = 'public' and p.tablename = t.relname) < 3 then
      raise exception 'FAILED: % is missing a select, insert or update policy', t.relname;
    end if;
    if has_table_privilege('authenticated', 'public.' || t.relname, 'DELETE') then
      raise exception 'FAILED: authenticated can delete from %', t.relname;
    end if;
    if has_table_privilege('anon', 'public.' || t.relname, 'SELECT') then
      raise exception 'FAILED: anon can read %', t.relname;
    end if;
  end loop;
  if (select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relkind = 'r') <> 10 then
    raise exception 'FAILED: expected 10 tables';
  end if;
end $$;

\echo ALL CHECKS PASSED
