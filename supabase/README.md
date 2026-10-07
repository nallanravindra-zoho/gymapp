# Backend (Supabase)

Everything the server side needs lives here. The app is local-first: it works
fully offline with no account, and syncing is added on top once you sign in.

## What is in this folder

| Path | Purpose |
|---|---|
| `migrations/20261007000000_private_data_and_sync.sql` | The ten private per-user tables, row-level security, and the sync triggers |
| `tests/rls_and_sync.sql` | Behaviour tests for the above, run on a real PostgreSQL |
| `tests/harness.sql` | Stand-in for Supabase's `auth` schema, so the tests run anywhere |

## How sync works

* **Local first.** Every action writes to the phone's own database and works
  offline. Nothing waits for the network.
* **Row ids are UUIDs made on the phone**, so sending a row twice can never
  create a duplicate.
* **Newest write wins.** Each row carries `updated_at`. The server keeps the
  newer version and silently ignores stale or duplicate writes
  (`sync_guard` trigger).
* **Pulling uses a server counter, not clocks.** Every accepted write gets the
  next `sync_seq`. A phone asks for "everything after the last number I saw",
  so a phone with a wrong clock cannot miss changes.
* **Deletes are soft** (`deleted_at`) and sync like any edit. Clients cannot
  hard-delete.
* **One person, many phones.** The phone's local user id is mapped to the
  account id when sending and back when receiving.
* **Private by default.** Row-level security limits every table to the signed-in
  owner. Sleep and screen time are never visible to anyone else. Group tables
  come later, with their own policies.
* **Stays on the phone:** cached streaks, weekly insights, the tips library.

Known limits, fine for a family-and-friends app: conflicts are decided by the
phones' clocks, and `sync_seq` is assigned when a write is accepted rather than
when it commits, so two writes landing at the same instant could in theory be
seen in a different order.

## One-time setup (you do this, about 15 minutes)

You need two free accounts: Supabase and Google Cloud.

### 1. Create the Supabase project

1. Sign up at supabase.com and create a project (any name, closest region).
2. Open **SQL Editor**, paste the contents of
   `migrations/20261007000000_private_data_and_sync.sql`, and run it.
3. Open **Project Settings, API** and note two values:
   * **Project URL**
   * **anon public key**

   Both are safe to put in the app: row-level security is what protects the
   data. **Never share or use the `service_role` key** in the app or in chat.

### 2. Set up Google sign-in

1. In Google Cloud Console, create a project and set up the **OAuth consent
   screen** (External, add yourself and any testers as test users).
2. Create two OAuth client IDs under **Credentials**:
   * **Web application.** Note its **Client ID** and **Client secret**.
   * **Android.** Package name `com.gymapp.wellbeing`, and the SHA-1 of the key
     that signs your build. For debug builds:
     `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
     (CI builds are signed with a different debug key, so add its SHA-1 too, or
     test with a local build first.)
3. In Supabase, **Authentication, Providers, Google**: enable it and paste the
   **Web** client ID and secret.

### 3. Give the app the values

The app reads them at build time, not from source control:

```
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR-ANON-KEY \
  --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR-WEB-CLIENT-ID.apps.googleusercontent.com
```

For the downloadable CI build, add the same three as repository secrets named
`SUPABASE_URL`, `SUPABASE_ANON_KEY` and `GOOGLE_WEB_CLIENT_ID`.

## Testing the schema

Requires PostgreSQL 14 or newer locally (or let CI do it on every push).

```
createdb wellbeing_test
psql -v ON_ERROR_STOP=1 -d wellbeing_test -f tests/harness.sql
psql -v ON_ERROR_STOP=1 -d wellbeing_test -f migrations/20261007000000_private_data_and_sync.sql
psql -v ON_ERROR_STOP=1 -d wellbeing_test -f tests/rls_and_sync.sql   # ends with: ALL CHECKS PASSED
```
