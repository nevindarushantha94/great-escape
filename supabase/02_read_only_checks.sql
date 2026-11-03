-- STEP 2 of 4. READ-ONLY. Run each query separately in Supabase > SQL Editor. Nothing here changes anything.
-- I was not given your original function definitions, so I have NOT guessed them. Query A returns the real one.

-- A) Exact current definitions (copy the submit_event_rsvp result: you need it for step 3).
select p.oid::regprocedure as signature, pg_get_functiondef(p.oid) as definition
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public' and p.proname in ('submit_event_rsvp', 'get_event_rsvp_summary');

-- B) Who may execute them (anon = the public website).
select p.oid::regprocedure as signature, has_function_privilege('anon', p.oid, 'execute') as anon_can_run, p.proacl
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public' and p.proname in ('submit_event_rsvp', 'get_event_rsvp_summary');

-- C) RLS must be ON (relrowsecurity = true).
select relname, relrowsecurity, relforcerowsecurity from pg_class where oid = 'public.event_rsvps'::regclass;

-- D) Policies on the table. Expect NO policy that lets anon select, insert, update or delete.
select policyname, roles, cmd, qual, with_check from pg_policies where schemaname = 'public' and tablename = 'event_rsvps';

-- E) Direct table privileges for the public roles. Expect no rows for anon.
select grantee, privilege_type from information_schema.role_table_grants
where table_schema = 'public' and table_name = 'event_rsvps' and grantee in ('anon', 'authenticated', 'public');
select grantee, column_name, privilege_type from information_schema.column_privileges
where table_schema = 'public' and table_name = 'event_rsvps' and grantee in ('anon', 'authenticated', 'public');

-- F) Constraints, indexes and triggers (to confirm duplicate-mobile protection is in place).
select conname, pg_get_constraintdef(oid) from pg_constraint where conrelid = 'public.event_rsvps'::regclass;
select indexdef from pg_indexes where schemaname = 'public' and tablename = 'event_rsvps';
select tgname, pg_get_triggerdef(oid) from pg_trigger where tgrelid = 'public.event_rsvps'::regclass and not tgisinternal;

-- G) What the public summary returns. Expect ONLY confirmed/declined counts and names. No mobile, no alcohol.
select public.get_event_rsvp_summary();
