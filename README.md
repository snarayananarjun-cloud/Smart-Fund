# Our Expenses

A private, minimalist expense tracker for Arjun & Sanjana. Built as a static
site backed by Supabase (auth + database).

## One-time setup (do this before the app will work)

1. Open your Supabase project → **SQL Editor** → New Query.
2. Paste the entire contents of `schema.sql` (in this repo) and click **Run**.
   This creates the `expenses`, `app_settings`, and `custom_categories` tables,
   locks them down with Row Level Security so only
   `snarayananarjun@gmail.com` and `sanjanavaithi@gmail.com` can read/write,
   and seeds your existing June 2026 expenses.
3. In Supabase → **Authentication → Providers**, make sure "Email" is enabled
   (it is by default). This app uses **magic link sign-in** (no password) —
   under Authentication → Email Templates you can leave the default "Magic
   Link" template as-is.
4. In Supabase → **Authentication → URL Configuration**, add your live
   Vercel URL (once you have it) to "Redirect URLs" — otherwise the magic
   link will fail to bring you back into the app after you tap it.

## First login (and every login after, on a new device)

1. Open the app. You'll see the welcome screen — type your email
   (`snarayananarjun@gmail.com` or `sanjanavaithi@gmail.com`) and tap
   Confirm.
2. Check that inbox — Supabase emails a one-time sign-in link.
3. Tap the link on the same device. You're in.
4. After that, this device remembers you — the welcome screen won't show
   again unless you sign out (tap the profile icon in the bottom nav).

Only these two email addresses are allowed in — anyone else who finds the
URL and tries to sign in will be blocked both before the email is sent
(client-side check) and at the database level (Row Level Security), even if
they somehow got a magic link some other way.

## Local structure

- `public/index.html` — the entire app (HTML/CSS/JS, talks directly to
  Supabase from the browser using the public anon key, which is safe to
  expose since Row Level Security enforces who can actually read/write).
- `public/welcome-illustration.png` — Arjun's own illustration used on the
  welcome screen.
- `schema.sql` — run once in Supabase, not deployed.
- `vercel.json` — routes everything to index.html.

