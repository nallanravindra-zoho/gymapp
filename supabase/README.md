# Backend (Supabase)

Everything the server side needs lives here. The app is local-first: it works
fully offline with no account, and syncing is added on top once you sign in.

## What is in this folder

| Path | Purpose |
|---|---|
| `migrations/20261007000000_private_data_and_sync.sql` | The ten private per-user tables, row-level security, and the sync triggers |
| `tests/rls_and_sync.sql` | Behaviour tests for the above, run on a real PostgreSQL |
| `migrations/20261008000000_groups.sql` | Groups: members, feed, cheers, weekly leaderboard, invite codes, and who can see what |
| `migrations/20261009000000_delete_account.sql` | `delete_my_account()`: a person deletes their own account and all its data |
| `tests/delete_account.sql` | Behaviour tests for account deletion |
| `migrations/20261010000000_numeric_invite_codes.sql` | Invite codes become 8 digits (existing groups get new codes) |
| `tests/numeric_codes.sql` | Tests that old-format codes are replaced |
| `migrations/20261011000000_four_digit_codes.sql` | Invite codes become 4 digits, with a limit of 5 wrong codes per 15 minutes per account |
| `tests/four_digit_codes.sql` | Tests for the 4-digit codes and the guessing limit |
| `tests/groups.sql` | Behaviour tests for groups (sharing switches, leaderboard totals, leaving, limits) |
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
   `migrations/20261007000000_private_data_and_sync.sql`, and run it. For groups, do the same
   with `migrations/20261008000000_groups.sql` afterwards.
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

The app reads three values at build time, from a file that is not committed.
Copy `env.example.json` (in the project root) to `env.json` and fill it in:

```json
{
  "SUPABASE_URL": "https://YOUR-PROJECT.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_...",
  "GOOGLE_WEB_CLIENT_ID": "YOUR-WEB-CLIENT-ID.apps.googleusercontent.com"
}
```

Then run the app with:

```
flutter run --dart-define-from-file=env.json
```

(In Android Studio, add `--dart-define-from-file=env.json` under *Run, Edit
configurations, Additional run args*.) Without the file the app still works,
offline only, and the Account screen says sync is not set up.

For the downloadable CI build, add the same three as repository secrets named
`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` and `GOOGLE_WEB_CLIENT_ID`.

**Google sign-in and signing keys.** Google checks the SHA-1 of the key that
signed the app, so each key you sign with must be added to the Android OAuth
client. Builds from your own computer use your local debug key. CI builds use
a different, throwaway key every run, so sign-in will not work in a CI-built
APK. Use `flutter run` for sign-in testing.

**In Supabase,** under *Authentication, Providers, Google*, put the **Web**
client ID in both the client ID field and the *Authorized Client IDs* list.

## Testing the schema

Requires PostgreSQL 14 or newer locally (or let CI do it on every push).

```
createdb wellbeing_test
psql -v ON_ERROR_STOP=1 -d wellbeing_test -f tests/harness.sql
psql -v ON_ERROR_STOP=1 -d wellbeing_test -f migrations/20261007000000_private_data_and_sync.sql
psql -v ON_ERROR_STOP=1 -d wellbeing_test -f tests/rls_and_sync.sql   # ends with: ALL CHECKS PASSED

# Groups tests want a fresh database (they check exact totals):
createdb wellbeing_groups
for f in tests/harness.sql migrations/20261007000000_private_data_and_sync.sql \
         migrations/20261008000000_groups.sql tests/groups.sql; do
  psql -v ON_ERROR_STOP=1 -d wellbeing_groups -f $f
done
```
