-- Behaviour tests for 20261102000001_gps_distance.sql.
--
-- Run on a database with the harness and ALL migrations applied (this one
-- twice, to prove it can be re-run). Every check raises an exception on
-- failure.

\set ON_ERROR_STOP on
\set alice '''aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'''

insert into auth.users (id) values (:alice);

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

select pg_temp.as_user(:alice);

-- All three sources, and no source, are accepted.
insert into workouts (id, user_id, workout_type_id, started_at, ended_at, duration_minutes,
  source, local_date, created_at, updated_at, distance_km, metrics_note)
values
  ('80000000-0000-4000-8000-000000000001', :alice, 'builtin-walk', now(), now(), 30,
   'timer', '2026-05-13', now(), now(), 2.1, 'gps'),
  ('80000000-0000-4000-8000-000000000002', :alice, 'builtin-walk', now(), now(), 30,
   'timer', '2026-05-13', now(), now(), 2.1, 'estimated'),
  ('80000000-0000-4000-8000-000000000003', :alice, 'builtin-walk', now(), now(), 30,
   'manual', '2026-05-13', now(), now(), 2.1, 'measured'),
  ('80000000-0000-4000-8000-000000000004', :alice, 'builtin-yoga', now(), now(), 30,
   'manual', '2026-05-13', now(), now(), null, null);
select pg_temp.assert((select count(*) from workouts where metrics_note = 'gps') = 1,
  'a gps workout is stored');

-- Anything else is still refused.
select pg_temp.must_fail($q$
  insert into workouts (id, user_id, workout_type_id, started_at, ended_at, duration_minutes,
    source, local_date, created_at, updated_at, metrics_note)
  values (gen_random_uuid(), 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'builtin-walk', now(),
    now(), 30, 'timer', '2026-05-13', now(), now(), 'satellite')$q$,
  'an unknown metrics note must be refused');
reset role;

select 'gps_distance tests passed' as result;
