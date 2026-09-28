-- ============================================================
-- Supabase setup for BodyMassIndexCalculator
-- Uses the existing table:
-- public.body_mass_index_calculations
-- No separate Supabase project and no separate profile table are required.
-- First name and last name are stored in Supabase Auth user metadata.
-- ============================================================

-- 1. Enable Row Level Security on the existing BMI table.
alter table public.body_mass_index_calculations
  enable row level security;

-- 2. Allow an authenticated user to read only their own calculations.
drop policy if exists "Users can view own BMI calculations"
  on public.body_mass_index_calculations;

create policy "Users can view own BMI calculations"
on public.body_mass_index_calculations
for select
to authenticated
using (user_id = auth.uid());

-- 3. Allow an authenticated user to insert only a calculation
--    that belongs to their own user id.
drop policy if exists "Users can insert own BMI calculations"
  on public.body_mass_index_calculations;

create policy "Users can insert own BMI calculations"
on public.body_mass_index_calculations
for insert
to authenticated
with check (user_id = auth.uid());

-- The assignment does not require editing or deleting calculation history,
-- so no UPDATE/DELETE policies are added.

-- 4. Give the authenticated role only the table permissions it needs.
grant select, insert
on public.body_mass_index_calculations
to authenticated;

-- ============================================================
-- Authentication settings are configured in the Supabase Dashboard:
-- Authentication -> Providers -> Email
--
-- Registration sends first_name and last_name as Auth user metadata.
-- No public.profiles table is required by the supplied requirements.
-- ============================================================
