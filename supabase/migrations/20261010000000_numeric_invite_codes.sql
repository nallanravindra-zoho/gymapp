-- Well-Being Companion: invite codes are 8 digits.
--
-- Run once in the Supabase SQL editor, after the groups migration.
--
-- A short numeric code is easy to read out or type, and works in any chat
-- app. Codes made before this change (12 letters and digits) are replaced, so
-- every group has an 8-digit code; anyone holding an old code needs a new one.

create or replace function public.new_invite_code()
returns text
language plpgsql volatile security definer set search_path = public
as $$
declare
  code text;
begin
  loop
    -- 32 random bits from a v4 uuid, reduced to 8 digits.
    code := lpad(
      ((('x' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 8))::bit(32)::bigint)
        % 100000000)::text,
      8, '0');
    exit when not exists (select 1 from public.groups where invite_code = code);
  end loop;
  return code;
end $$;

update public.groups
  set invite_code = public.new_invite_code()
  where invite_code !~ '^[0-9]{8}$';
