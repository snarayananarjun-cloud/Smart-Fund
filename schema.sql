-- ============================================================
-- Our Expenses App — Supabase schema
-- Run this entire file once in Supabase: SQL Editor → New Query → paste → Run
-- ============================================================

-- Table: expenses
create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(),
  amount numeric(10,2) not null check (amount > 0),
  category text not null,
  description text not null,
  date date not null,
  person text not null,
  type text not null default 'expense' check (type in ('expense','income')),
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create index if not exists expenses_date_idx on public.expenses(date);
create index if not exists expenses_category_idx on public.expenses(category);

-- Table: settings (single row for shared app settings like wedding target)
create table if not exists public.app_settings (
  key text primary key,
  value text not null,
  updated_at timestamptz not null default now()
);

-- Table: custom_categories (categories either of you have added beyond the base list)
create table if not exists public.custom_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

-- ============================================================
-- Row Level Security: only the two allowed emails can read/write
-- ============================================================
alter table public.expenses enable row level security;
alter table public.app_settings enable row level security;
alter table public.custom_categories enable row level security;

-- Helper: a function that checks if the current logged-in user's email
-- is one of the two allowed accounts. Edit this list if you ever add a third person.
create or replace function public.is_allowed_user()
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1 from auth.users
    where id = auth.uid()
    and email in ('snarayananarjun@gmail.com', 'sanjanavaithi@gmail.com')
  );
$$;

-- Policies: expenses
drop policy if exists "Allowed users can read expenses" on public.expenses;
create policy "Allowed users can read expenses"
  on public.expenses for select
  using (public.is_allowed_user());

drop policy if exists "Allowed users can insert expenses" on public.expenses;
create policy "Allowed users can insert expenses"
  on public.expenses for insert
  with check (public.is_allowed_user());

drop policy if exists "Allowed users can update expenses" on public.expenses;
create policy "Allowed users can update expenses"
  on public.expenses for update
  using (public.is_allowed_user());

drop policy if exists "Allowed users can delete expenses" on public.expenses;
create policy "Allowed users can delete expenses"
  on public.expenses for delete
  using (public.is_allowed_user());

-- Policies: app_settings
drop policy if exists "Allowed users can read settings" on public.app_settings;
create policy "Allowed users can read settings"
  on public.app_settings for select
  using (public.is_allowed_user());

drop policy if exists "Allowed users can write settings" on public.app_settings;
create policy "Allowed users can write settings"
  on public.app_settings for insert
  with check (public.is_allowed_user());

drop policy if exists "Allowed users can update settings" on public.app_settings;
create policy "Allowed users can update settings"
  on public.app_settings for update
  using (public.is_allowed_user());

-- Policies: custom_categories
drop policy if exists "Allowed users can read categories" on public.custom_categories;
create policy "Allowed users can read categories"
  on public.custom_categories for select
  using (public.is_allowed_user());

drop policy if exists "Allowed users can insert categories" on public.custom_categories;
create policy "Allowed users can insert categories"
  on public.custom_categories for insert
  with check (public.is_allowed_user());

-- ============================================================
-- Seed: June 2026 expenses (Arjun's existing tracked data)
-- ============================================================
insert into public.expenses (amount, category, description, date, person, type) values
  (3.45, 'Food', 'YFood', '2026-06-02', 'Arjun', 'expense'),
  (12.44, 'Groceries', 'Tesco', '2026-06-02', 'Arjun', 'expense'),
  (6.20, 'Food', 'Fresh', '2026-06-03', 'Arjun', 'expense'),
  (1.30, 'Groceries', 'Bread', '2026-06-03', 'Arjun', 'expense'),
  (4.70, 'Food', 'Fresh', '2026-06-04', 'Arjun', 'expense'),
  (4.20, 'Groceries', 'Tesco', '2026-06-04', 'Arjun', 'expense'),
  (1.55, 'Food', 'Fresh', '2026-06-05', 'Arjun', 'expense'),
  (50.00, 'Gifts', 'To People in need', '2026-06-05', 'Arjun', 'expense'),
  (1.56, 'Personal', 'Water', '2026-06-08', 'Arjun', 'expense'),
  (18.40, 'Groceries', 'Tesco', '2026-06-08', 'Arjun', 'expense'),
  (1.50, 'Food', 'salad for wrap', '2026-06-09', 'Arjun', 'expense'),
  (5.78, 'Food', 'Fresh', '2026-06-10', 'Arjun', 'expense'),
  (12.99, 'Personal', 'Sim Card', '2026-06-10', 'Arjun', 'expense'),
  (2.24, 'Groceries', 'Milk', '2026-06-11', 'Arjun', 'expense'),
  (1.50, 'Food', 'Drink', '2026-06-11', 'Arjun', 'expense'),
  (15.11, 'Food', 'Fresh', '2026-06-12', 'Arjun', 'expense'),
  (20.00, 'Gifts', 'Token', '2026-06-12', 'Arjun', 'expense'),
  (22.00, 'Food', 'Dinner for Sanju', '2026-06-12', 'Arjun', 'expense'),
  (90.00, 'Personal', 'Dress for me & Sanju', '2026-06-14', 'Arjun', 'expense'),
  (7.95, 'Food', 'Supermac''s', '2026-06-14', 'Arjun', 'expense'),
  (2.06, 'Groceries', 'Tesco', '2026-06-14', 'Arjun', 'expense'),
  (11.62, 'Groceries', 'Tesco', '2026-06-15', 'Arjun', 'expense'),
  (8.50, 'Groceries', 'Lidl', '2026-06-14', 'Arjun', 'expense'),
  (3.85, 'Food', 'Fresh', '2026-06-15', 'Arjun', 'expense'),
  (7.50, 'Personal', 'Wifi', '2026-06-15', 'Arjun', 'expense')
on conflict do nothing;

-- Default wedding target
insert into public.app_settings (key, value) values ('wedding_target', '4500')
on conflict (key) do nothing;
