-- Well-Being Companion: delete my account (spec step 12).
--
-- Run once in the Supabase SQL editor, after the earlier migrations.
--
-- A signed-in person can delete their own account and everything stored for
-- it. Every table references auth.users with "on delete cascade", so removing
-- the user removes their personal data, memberships, feed items and cheers.
-- Groups they owned pass to the longest-standing member, or are removed when
-- nobody is left (see group_members_after_delete in the groups migration).
--
-- The function can only ever delete the caller: it takes no arguments.

create or replace function public.delete_my_account()
returns void
language plpgsql security definer set search_path = public
as $$
declare
  uid uuid := (select auth.uid());
begin
  if uid is null then raise exception 'not_signed_in'; end if;
  delete from auth.users where id = uid;
end $$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
