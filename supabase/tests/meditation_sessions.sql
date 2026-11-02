-- Behaviour tests for 20261102000000_meditation_sessions.sql.
--
-- Run on a database with the harness and ALL migrations applied (this one
-- twice, to prove it can be re-run). Every check raises an exception on
-- failure.

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
create or replace function pg_temp.must_fail(stmt text, msg text) returns void language plpgsql as $$
begin
  begin
    execute stmt;
  exception when others then
    return;
  end;
  raise exception 'FAILED: %', msg;
end $$;
grant all on function pg_temp.as_user(text), pg_temp.assert(boolean, text),
  pg_temp.must_fail(text, text) to public;

-- 1. Private by construction. ---------------------------------------------------------
do $$
begin
  if not (select relrowsecurity from pg_class
          where oid = 'public.meditation_sessions'::regclass) then
    raise exception 'FAILED: row level security is off';
  end if;
  if (select count(*) from pg_policies
      where schemaname = 'public' and tablename = 'meditation_sessions') <> 3 then
    raise exception 'FAILED: expected exactly select, insert, update policies';
  end if;
  if exists (
    select 1 from pg_policies p
    where p.schemaname = 'public' and p.tablename = 'meditation_sessions'
      and (coalesce(p.qual, '') || coalesce(p.with_check, '')) not like '%auth.uid()%'
  ) then
    raise exception 'FAILED: a policy is not tied to auth.uid()';
  end if;
  if has_table_privilege('authenticated', 'public.meditation_sessions', 'DELETE') then
    raise exception 'FAILED: authenticated can delete';
  end if;
  if has_table_privilege('anon', 'public.meditation_sessions', 'SELECT') then
    raise exception 'FAILED: anon can read';
  end if;
  if not exists (select 1 from pg_trigger
                 where tgrelid = 'public.meditation_sessions'::regclass
                   and tgname = 'meditation_sessions_sync_guard') then
    raise exception 'FAILED: no sync guard';
  end if;
end $$;

-- 2. Alice writes a session; it gets a sync_seq and sensible defaults. -----------------
select pg_temp.as_user(:alice);
insert into meditation_sessions (id, user_id, started_at, planned_minutes,
  duration_seconds, completed, local_date, created_at, updated_at)
values ('70000000-0000-4000-8000-000000000001', :alice, now(), 10, 600, true,
  '2026-05-13', now(), now());
insert into meditation_sessions (id, user_id, started_at, planned_minutes,
  duration_seconds, local_date, created_at, updated_at)
values ('70000000-0000-4000-8000-000000000002', :alice, now(), 5, 140,
  '2026-05-13', now(), now());
select pg_temp.assert((select count(*) from meditation_sessions where sync_seq > 0) = 2,
  'sessions stamped');
select pg_temp.assert((select completed from meditation_sessions
  where id = '70000000-0000-4000-8000-000000000002') = false,
  'a session defaults to not completed');
reset role;

-- 3. Bob sees none of it and cannot write as Alice. -----------------------------------
select pg_temp.as_user(:bob);
select pg_temp.assert((select count(*) from meditation_sessions) = 0, 'bob sees none');
select pg_temp.must_fail($q$
  insert into meditation_sessions (id, user_id, started_at, planned_minutes,
    duration_seconds, local_date, created_at, updated_at)
  values ('70000000-0000-4000-8000-000000000009', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
          now(), 5, 60, '2026-05-13', now(), now())$q$, 'bob wrote a session as alice');
update meditation_sessions set duration_seconds = 1;
select pg_temp.must_fail('delete from meditation_sessions', 'bob may not delete sessions');
reset role;
select pg_temp.assert((select duration_seconds from meditation_sessions
  where id = '70000000-0000-4000-8000-000000000001') = 600, 'alice session untouched');

-- 4. Stale writes are ignored; soft deletes sync like edits. ---------------------------
select pg_temp.as_user(:alice);
select sync_seq as seq_before from meditation_sessions
  where id = '70000000-0000-4000-8000-000000000001' \gset
update meditation_sessions set duration_seconds = 1, updated_at = now() - interval '1 day'
  where id = '70000000-0000-4000-8000-000000000001';
select pg_temp.assert((select duration_seconds from meditation_sessions
  where id = '70000000-0000-4000-8000-000000000001') = 600, 'a stale update is ignored');
update meditation_sessions set deleted_at = now() + interval '1 minute',
  updated_at = now() + interval '1 minute'
  where id = '70000000-0000-4000-8000-000000000001';
select pg_temp.assert((select sync_seq from meditation_sessions
  where id = '70000000-0000-4000-8000-000000000001') > :seq_before,
  'a soft delete gets a newer sync_seq');
reset role;

-- 5. Constraints. -----------------------------------------------------------------------
select pg_temp.as_user(:alice);
select pg_temp.must_fail($q$
  insert into meditation_sessions (id, user_id, started_at, planned_minutes,
    duration_seconds, local_date, created_at, updated_at)
  values (gen_random_uuid(), 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', now(), 0, 10,
          '2026-05-13', now(), now())$q$, 'planned minutes must be positive');
select pg_temp.must_fail($q$
  insert into meditation_sessions (id, user_id, started_at, planned_minutes,
    duration_seconds, local_date, created_at, updated_at)
  values (gen_random_uuid(), 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', now(), 5, -1,
          '2026-05-13', now(), now())$q$, 'duration cannot be negative');
reset role;

-- 6. Deleting the account removes the sessions. ----------------------------------------
select pg_temp.as_user(:alice);
select delete_my_account();
reset role;
select pg_temp.assert((select count(*) from meditation_sessions) = 0,
  'deleting the account removed the sessions');

select 'meditation_sessions tests passed' as result;
