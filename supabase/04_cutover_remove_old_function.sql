-- STEP 4 of 4. Run ONLY AFTER: (a) step 3 is done, (b) the new website is deployed on Netlify,
-- (c) you submitted one real test RSVP from it and saw the row (with alcohol_preference filled) in Table Editor.
--
-- Removes the old 4-parameter public route so there is only ONE way to submit an RSVP.
-- Deliberately NOT "drop function if exists": if the types below do not match your old function this must fail
-- loudly rather than silently leave the old route open. If it errors, use the exact signature from check 1 below.
drop function public.submit_event_rsvp(text, text, boolean, text);

-- Check 1: must return exactly ONE row, the 5-parameter version.
select p.oid::regprocedure as signature, has_function_privilege('anon', p.oid, 'execute') as anon_can_run
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public' and p.proname = 'submit_event_rsvp';

-- Check 2: summary must still show names and counts only.
select public.get_event_rsvp_summary();
