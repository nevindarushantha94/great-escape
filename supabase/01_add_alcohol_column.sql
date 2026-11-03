-- STEP 1 of 4. Safe to run now. Run in Supabase > SQL Editor.
-- Adds ONE nullable column. Does not touch existing data, RLS, constraints, policies or other columns.
-- The currently deployed website keeps working after this (it simply never fills the new column).
alter table public.event_rsvps add column if not exists alcohol_preference boolean;
