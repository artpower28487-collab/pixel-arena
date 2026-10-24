-- Pixel Arena shared backend starter schema.
-- Run in Supabase SQL Editor after creating a project.
-- Do not disable RLS or put a secret/service_role key in either website.

create extension if not exists pgcrypto;

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  phone text not null,
  sport text not null check (sport in ('Cricket','Pickleball','Badminton','Volleyball')),
  booking_date date not null,
  start_time time not null,
  duration_hours int not null check (duration_hours between 1 and 4),
  amount numeric(10,2) not null check (amount >= 0),
  status text not null default 'pending' check (status in ('pending','confirmed','declined','cancelled')),
  created_at timestamptz not null default now()
);

create table if not exists public.offers (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  discount_type text not null check (discount_type in ('percent','flat')),
  discount_value numeric(10,2) not null check (discount_value >= 0),
  sport text not null default 'all',
  valid_from date,
  valid_until date,
  promo_code text,
  active boolean not null default false,
  updated_at timestamptz not null default now()
);

alter table public.bookings enable row level security;
alter table public.offers enable row level security;

revoke all on public.bookings from anon, authenticated;
revoke all on public.offers from anon, authenticated;
grant insert on public.bookings to anon;
grant select, update on public.bookings to authenticated;
grant select on public.offers to anon, authenticated;
grant insert, update, delete on public.offers to authenticated;

drop policy if exists "Visitors can submit booking requests" on public.bookings;
create policy "Visitors can submit booking requests" on public.bookings
  for insert to anon with check (status = 'pending');
drop policy if exists "Owner can review bookings" on public.bookings;
create policy "Owner can review bookings" on public.bookings
  for select to authenticated using ((auth.jwt() ->> 'email') = 'artpower28487@gmail.com');
drop policy if exists "Owner can update booking status" on public.bookings;
create policy "Owner can update booking status" on public.bookings
  for update to authenticated using ((auth.jwt() ->> 'email') = 'artpower28487@gmail.com')
  with check ((auth.jwt() ->> 'email') = 'artpower28487@gmail.com');
drop policy if exists "Visitors can read active offers" on public.offers;
create policy "Visitors can read active offers" on public.offers
  for select to anon using (active = true);
drop policy if exists "Owner can manage offers" on public.offers;
create policy "Owner can manage offers" on public.offers
  for all to authenticated using ((auth.jwt() ->> 'email') = 'artpower28487@gmail.com')
  with check ((auth.jwt() ->> 'email') = 'artpower28487@gmail.com');

-- Create the owner account in Supabase Authentication > Users. Policies
-- restrict owner data to this exact email even if another account is added.

-- Enable live booking updates in the owner portal.
do $$ begin
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='bookings') then
    alter publication supabase_realtime add table public.bookings;
  end if;
end $$;
