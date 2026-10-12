-- Behaviour tests for 20261011000000_four_digit_codes.sql.
-- Run on a database with the harness and the first two migrations applied
-- (the third is applied here, over groups that already exist), from the
-- repository root.

\set ON_ERROR_STOP on
\set alice '''aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'''
\set bob   '''bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'''
\set cara  '''cccccccc-cccc-4ccc-8ccc-cccccccccccc'''

insert into auth.users (id) values (:alice), (:bob), (:cara);

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

-- Groups made under earlier formats.
insert into groups (id, name, owner_id, invite_code) values
  ('11111111-1111-4111-8111-111111111111', 'Letters', :alice, 'abc123def456'),
  ('22222222-2222-4222-8222-222222222222', 'Eight', :alice, '12345678'),
  ('33333333-3333-4333-8333-333333333333', 'Four', :alice, '4321');
insert into group_members (group_id, user_id, role)
  select id, :alice, 'owner' from groups;

\i supabase/migrations/20261011000000_four_digit_codes.sql

-- 1. Conversion ----------------------------------------------------------------
select pg_temp.assert((select count(*) from groups where invite_code ~ '^[0-9]{4}$') = 3,
  'every group has a 4-digit code');
select pg_temp.assert((select invite_code from groups where name = 'Four') = '4321',
  'a 4-digit code is kept');
select pg_temp.assert((select count(distinct invite_code) from groups) = 3, 'codes are unique');
create temp table many as select public.new_invite_code() as c from generate_series(1, 300);
select pg_temp.assert((select count(*) from many where c ~ '^[0-9]{4}$') = 300,
  '300 new codes are all 4 digits (leading zeros kept)');
select pg_temp.assert(
  (select count(*) from many m join groups g on g.invite_code = m.c) = 0,
  'a new code never repeats one in use');

-- 2. Guessing is limited ---------------------------------------------------------
create temp table real_code as select invite_code as c from groups where name = 'Four';
grant all on real_code to public;

select pg_temp.as_user(:bob);
-- Four wrong guesses are fine, and nothing is joined.
select pg_temp.assert(join_group('zzz1') is null, 'wrong guess 1');
select pg_temp.assert(join_group('zzz2') is null, 'wrong guess 2');
select pg_temp.assert((select count(*) from group_preview('zzz3')) = 0, 'a wrong preview returns nothing');
select pg_temp.assert(join_group('zzz4') is null, 'wrong guess 4');
-- A right code between guesses still works and costs nothing.
select pg_temp.assert((select name from group_preview((select c from real_code))) = 'Four',
  'a right code still previews');
select pg_temp.assert(join_group((select c from real_code)) is not null, 'a right code still joins');
-- The fifth wrong guess is allowed; the sixth try is refused, right code or not.
select pg_temp.assert(join_group('zzz5') is null, 'wrong guess 5');
do $$ begin
  begin perform join_group('zzz6'); raise exception 'FAILED: 6th wrong guess was allowed';
  exception when raise_exception then
    if sqlerrm like 'FAILED%' then raise; end if;
    if sqlerrm <> 'too_many_attempts' then raise exception 'FAILED: wrong error %', sqlerrm; end if;
  end;
  begin perform join_group((select c from real_code)); raise exception 'FAILED: locked-out account joined';
  exception when raise_exception then
    if sqlerrm like 'FAILED%' then raise; end if;
    if sqlerrm <> 'too_many_attempts' then raise exception 'FAILED: wrong error %', sqlerrm; end if;
  end;
  begin perform * from group_preview((select c from real_code)); raise exception 'FAILED: locked-out account previewed';
  exception when raise_exception then
    if sqlerrm like 'FAILED%' then raise; end if;
    if sqlerrm <> 'too_many_attempts' then raise exception 'FAILED: wrong error %', sqlerrm; end if;
  end;
end $$;
reset role;

select pg_temp.assert((select count(*) from join_attempts where user_id = :bob) = 5,
  'exactly the 5 wrong guesses were recorded');

-- Someone else is not affected by Bob's guesses.
select pg_temp.as_user(:cara);
select pg_temp.assert(join_group((select c from real_code)) is not null, 'cara can still join');
reset role;

-- After 15 minutes the lock lifts.
update join_attempts set attempted_at = now() - interval '16 minutes' where user_id = :bob;
select pg_temp.as_user(:bob);
select pg_temp.assert(join_group('zzz7') is null, 'guessing is allowed again after the wait');
reset role;

-- Old records are cleared out.
update join_attempts set attempted_at = now() - interval '2 days';
select pg_temp.as_user(:cara);
select join_group((select c from real_code));
reset role;
select pg_temp.assert((select count(*) from join_attempts) = 0, 'attempts older than a day are removed');

-- 3. The attempt log is private -----------------------------------------------------
select pg_temp.as_user(:alice);
do $$ begin
  begin perform count(*) from join_attempts; raise exception 'FAILED: a member read the attempt log';
  exception when insufficient_privilege then null; end;
  begin perform check_join_rate('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'); raise exception 'FAILED: internal function callable';
  exception when insufficient_privilege then null; end;
end $$;
reset role;
set role anon;
do $$ begin
  begin perform group_preview('1234'); raise exception 'FAILED: anon previewed';
  exception when insufficient_privilege then null; end;
end $$;
reset role;

-- 4. Deleting an account removes its attempts ---------------------------------------
select pg_temp.as_user(:cara);
select join_group('zzz8');
reset role;
select pg_temp.assert((select count(*) from join_attempts where user_id = :cara) = 1, 'a wrong guess is recorded');
delete from auth.users where id = :cara;
select pg_temp.assert((select count(*) from join_attempts where user_id = :cara) = 0, 'and goes with the account');

select 'ALL CHECKS PASSED' as result;
