# THE GREAT ESCAPE: Digital Invitation (final)

## Folder structure
```
netlify.toml          tells Netlify to publish the "site" folder
site/
  index.html          the six-scene invitation (the only page)
  images/             hero-1600.jpg, hero-900.jpg, pavilion.jpg, resort-pool.jpg
supabase/             SQL to run in the Supabase SQL Editor, in numeric order
  01_add_alcohol_column.sql
  02_read_only_checks.sql
  03_new_submit_function.sql
  04_cutover_remove_old_function.sql
```

## Order of work (do it in this order)
1. **Supabase, run `01_add_alcohol_column.sql`.** Adds the `alcohol_preference` column only. Safe; the live site is unaffected.
2. **Supabase, run the queries in `02_read_only_checks.sql`** one at a time. They only read. Copy the result of query A.
3. **Supabase, create the new 5-parameter function** using `03_new_submit_function.sql`. I did not have your original function definition, so that file gives the 5 exact edits to make to *your* definition (or send me the output of query A and I will prepare the finished SQL). Then run the two permission lines at the bottom of that file. The old function still exists, so nothing breaks yet.
4. **Netlify, deploy the new site** (below).
5. **Test once for real**: submit an RSVP on the live site, confirm the row in Table Editor has `alcohol_preference` filled, then delete the test row.
6. **Supabase, run `04_cutover_remove_old_function.sql`.** Removes the old 4-parameter function so there is only one public submission route. Check 1 in that file must show exactly one row.

If you deploy the new site before step 3, RSVPs will fail (the site calls a function that does not exist yet). If you skip step 6, the old route stays open and can create RSVPs with no alcohol answer.

## Deploy to Netlify
1. Netlify > Add new site > Deploy manually.
2. Drag the whole project folder (the one containing `netlify.toml` and `site/`) into the drop zone. Dragging only `site/` also works.
3. Open the site URL and check: envelope opens, the four photos load, the live list in scene 6 appears.

## Download RSVP records as CSV
Only signed-in members of your Supabase project can see this table.
- Quick way: Supabase > **Table Editor** > `event_rsvps` > **Export** > **Download CSV**. This includes extra columns (id, mobile_normalized, transport, updated_at); ignore them.
- Exact columns: Supabase > **SQL Editor**, run the query below, then use **Download CSV** on the results:
```sql
select full_name as "Full name", mobile as "Mobile",
       case when attending then 'Yes' else 'No' end as "Attending",
       case when alcohol_preference then 'Yes' when alcohol_preference is false then 'No' end as "Alcohol preference",
       created_at at time zone 'Asia/Colombo' as "Registered (Sri Lanka time)"
from public.event_rsvps order by created_at;
```
- Excel drops the leading 0 of mobile numbers when you double-click a CSV. Use Data > From Text/CSV and set the Mobile column to Text.
- To change someone's response when they ask: Table Editor > edit that row's `attending` (or `alcohol_preference`). This works through your project login, not the public website.

## Completed
- Approved six-scene design unchanged (envelope, transitions, progress bar, RSVP shortcut, keyboard + swipe, photographs, botanicals, reduced motion, WhatsApp share).
- Cost updated to **LKR 5,000 per person**. All other event details unchanged. Countdown and deadline use Sri Lanka time (+05:30) whatever the visitor's device timezone.
- RSVP form has exactly four fields: full name, mobile, attending Yes/No, alcohol Yes/No (required, with the planning-only note). Sends `p_full_name, p_mobile, p_attending, p_transport="not_applicable", p_alcohol_preference` (Boolean).
- Duplicate mobile message: "This mobile number has already registered. Please contact the organiser if you need to change your response." No public change option.
- Confirmation animation shows "Your response has been received. Thank you!" plus the selected response (Attending / Not attending) with a polite message for No.
- Custom admin dashboard, admin SQL, admin code and the unused Turnstile Edge Function draft removed.
- Public summary call unchanged (`get_event_rsvp_summary`, 30-second refresh); the page shows names and counts only.
- No service_role or secret key anywhere in the code (only the publishable key).

## Pending setup and security work
- **Database steps 1 to 6 above have NOT been run.** Until they are, the new form cannot save RSVPs.
- The new function SQL is not written because the original definition is needed (step 3).
- Run the checks in `02_read_only_checks.sql` and confirm: RLS on, no anon policies or grants on `event_rsvps`, summary returns no mobile/alcohol. I could not verify any of this against your project.
- **No bot protection is active.** There is no CAPTCHA and no Turnstile. Anyone can call the public RSVP function. If you add it later you need: a Cloudflare Turnstile site, a Supabase Edge Function that verifies the token server-side with the secret key and then calls the RSVP function, the website switched to call that Edge Function, and anon execute permission revoked on the RSVP function. Until all of that is deployed and tested, do not describe it as protected.
- **Mobile ownership is not verified** (no OTP, by design).
- Not tested against your real Supabase project, or on real phones.
- Optional: an `og:image` for a richer WhatsApp preview needs your final site URL.
