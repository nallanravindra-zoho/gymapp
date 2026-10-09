-- Behaviour tests for 20261009000000_delete_account.sql.
-- Run on a database with the harness and all three migrations applied.

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

-- Alice and Bob each have data, and share a group Alice owns.
insert into profiles (id, display_name, created_at, updated_at) values
  (:alice, 'Alice', now(), now()), (:bob, 'Bob', now(), now());
insert into workouts (id, user_id, workout_type_id, started_at, ended_at,
  duration_minutes, source, local_date, created_at, updated_at) values
  ('11111111-1111-4111-8111-111111111111', :alice, 'builtin-yoga', now(), now(), 30, 'manual', to_char(now(), 'YYYY-MM-DD'), now(), now()),
  ('22222222-2222-4222-8222-222222222222', :bob, 'builtin-run', now(), now(), 20, 'manual', to_char(now(), 'YYYY-MM-DD'), now(), now());
insert into sleep_logs (id, user_id, bedtime_at, wake_at, duration_minutes,
  local_date, created_at, updated_at)
values ('33333333-3333-4333-8333-333333333333', :alice, now(), now(), 480,
  '2026-05-13', now(), now());

select pg_temp.as_user(:alice);
create temp table g as select * from create_group('Crew');
grant all on g to public;
reset role;
select pg_temp.as_user(:bob);
select join_group((select invite_code from g));
reset role;
insert into workouts (id, user_id, workout_type_id, started_at, ended_at,
  duration_minutes, source, local_date, created_at, updated_at)
values ('44444444-4444-4444-8444-444444444444', :alice, 'builtin-walk', now(), now(), 15, 'manual', to_char(now(), 'YYYY-MM-DD'), now(), now());
select pg_temp.assert((select count(*) from group_events where user_id = :alice) = 1,
  'alice has a feed item before deleting');

-- 1. Anonymous users cannot call it. ---------------------------------------------------
set role anon;
do $$ begin
  begin perform delete_my_account(); raise exception 'FAILED: anon deleted an account';
  exception when insufficient_privilege then null; end;
end $$;
reset role;

-- 2. Alice deletes her account. --------------------------------------------------------
select pg_temp.as_user(:alice);
select delete_my_account();
reset role;

select pg_temp.assert(not exists (select 1 from auth.users where id = :alice), 'alice is gone');
select pg_temp.assert((select count(*) from profiles where id = :alice) = 0, 'her profile is gone');
select pg_temp.assert((select count(*) from workouts where user_id = :alice) = 0, 'her workouts are gone');
select pg_temp.assert((select count(*) from sleep_logs where user_id = :alice) = 0, 'her sleep logs are gone');
select pg_temp.assert((select count(*) from group_members where user_id = :alice) = 0, 'her memberships are gone');
select pg_temp.assert((select count(*) from group_events where user_id = :alice) = 0, 'her feed items are gone');

-- 3. Nobody else is touched; the group she owned passes to Bob. ---------------------
select pg_temp.assert(exists (select 1 from auth.users where id = :bob), 'bob remains');
select pg_temp.assert((select count(*) from workouts where user_id = :bob) = 1, 'bob keeps his workout');
select pg_temp.assert((select owner_id from groups) = :bob, 'bob now owns the group');
select pg_temp.assert((select role from group_members where user_id = :bob) = 'owner', 'and is marked owner');

-- 4. Bob cannot delete anyone but himself (the function takes no id), and when the
--    last member goes, the group goes with them.
select pg_temp.as_user(:bob);
select delete_my_account();
reset role;
select pg_temp.assert((select count(*) from groups) = 0, 'an empty group is removed');
select pg_temp.assert((select count(*) from workouts) = 0, 'nothing left behind');

-- 5. Signed-out calls fail clearly. ------------------------------------------------------
select set_config('request.jwt.claim.sub', '', false);
set role authenticated;
do $$ begin
  begin perform delete_my_account(); raise exception 'FAILED: no user but it ran';
  exception when raise_exception then
    if sqlerrm like 'FAILED%' then raise; end if;
    if sqlerrm <> 'not_signed_in' then raise exception 'FAILED: wrong error %', sqlerrm; end if;
  end;
end $$;
reset role;

select 'ALL CHECKS PASSED' as result;
