-- Behaviour tests for 20261010000000_numeric_invite_codes.sql.
-- Run on a database with the harness and the first two migrations applied
-- (the third is applied by this script, over groups that already exist).

\set ON_ERROR_STOP on

insert into auth.users (id) values
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'), ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb');

create or replace function pg_temp.assert(cond boolean, msg text) returns void language plpgsql as $$
begin
  if not coalesce(cond, false) then raise exception 'FAILED: %', msg; end if;
end $$;

-- Groups made before the change have 12-character codes.
insert into groups (id, name, owner_id, invite_code) values
  ('11111111-1111-4111-8111-111111111111', 'Old one', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'abc123def456'),
  ('22222222-2222-4222-8222-222222222222', 'Old two', 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', '0123456789ab'),
  ('33333333-3333-4333-8333-333333333333', 'Already numeric', 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', '12345678');

\i supabase/migrations/20261010000000_numeric_invite_codes.sql

select pg_temp.assert((select count(*) from groups where invite_code ~ '^[0-9]{8}$') = 3,
  'every group has an 8-digit code');
select pg_temp.assert((select invite_code from groups where name = 'Already numeric') = '12345678',
  'a code that is already numeric is kept');
select pg_temp.assert((select count(distinct invite_code) from groups) = 3, 'codes are unique');
select pg_temp.assert((select count(*) from groups where invite_code in ('abc123def456', '0123456789ab')) = 0,
  'old codes no longer match any group');

-- Many codes: all 8 digits (leading zeros kept) and none repeated.
create temp table made_codes as select public.new_invite_code() as c from generate_series(1, 500);
select pg_temp.assert((select count(*) from made_codes where c ~ '^[0-9]{8}$') = 500, '500 codes are all 8 digits');

select 'ALL CHECKS PASSED' as result;
