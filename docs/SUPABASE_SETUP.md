# Cloud Sync Setup (Supabase)

The app works fully offline out of the box. To enable optional cloud sync —
sign in on multiple devices and keep your workouts in sync — connect a free
Supabase project.

While `lib/config/supabase_config.dart` still holds the placeholder values, the
account/sync UI stays hidden and the app behaves exactly as before.

## 1. Create a Supabase project

1. Go to <https://supabase.com>, sign in, and create a new project (the free
   tier is enough).
2. Wait for it to finish provisioning.

## 2. Create the database schema

1. In the project dashboard open **SQL Editor → New query**.
2. Paste the contents of [`supabase/schema.sql`](../supabase/schema.sql) and run
   it. This creates the seven sync tables, indexes, and Row Level Security
   policies (each user can only read/write their own rows).

## 3. Enable email auth

1. Go to **Authentication → Providers → Email** and make sure it is enabled.
2. For easy testing, you may disable "Confirm email" under
   **Authentication → Sign In / Up** so new accounts can sign in immediately.
   (Re-enable it for production.)

## 4. Add your keys to the app

1. In **Project Settings → API**, copy the **Project URL** and the
   **anon/publishable key**.
2. Open `lib/config/supabase_config.dart` and replace the placeholders:

   ```dart
   static const String url = 'https://YOUR-PROJECT.supabase.co';
   static const String anonKey = 'eyJhbGciOi...your-anon-key...';
   ```

3. Rebuild the app. A **Cloud Sync** card now appears at the top of the
   Profile tab.

## 5. Use it

- Tap **Cloud Sync → Sign In**, then create an account or sign in.
- Sync runs automatically right after sign-in and whenever the app resumes.
  You can also tap **Sync now** any time.
- Install the app on a second device, sign in with the same account, and your
  data flows across.

## How sync works (summary)

- **Offline-first.** All reads/writes hit the local SQLite database; sync runs
  in the background and never blocks the UI.
- **Identity.** Every row carries a `uuid`. Built-in (preset) exercises and
  routines get a deterministic uuid derived from their name, so references to
  them resolve on any device without uploading the presets themselves. Only
  your own data is uploaded.
- **Conflicts.** Last-write-wins by `updated_at` (UTC).
- **Deletes.** Propagated as soft-delete tombstones.

## Known limitation

- **Progress photo images are not uploaded** in this phase — only the photo's
  metadata (date/note) syncs. On a second device the image will show a
  placeholder. Uploading the image bytes via Supabase Storage is a planned
  follow-up.
