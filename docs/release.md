# Releasing Well-Being Companion

How to get a signed build onto your phone and into Google Play's internal testing. Nothing here needs code changes; it needs a few things only you can create.

## 1. Make an upload key (once)

On any computer with Java:

```
keytool -genkeypair -v -keystore upload-keystore.jks -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Choose strong passwords and write them down somewhere safe (a password manager). **Keep `upload-keystore.jks` and both passwords. If you lose them you can ask Play to reset the upload key, but it takes days.** Never commit the file (`.gitignore` already excludes `*.jks` and `android/key.properties`).

## 2. Give GitHub the key (once)

In the repository: Settings, Secrets and variables, Actions, New repository secret. Add four secrets:

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | the keystore as text: `base64 -w0 upload-keystore.jks` (on a Mac: `base64 -i upload-keystore.jks`) |
| `ANDROID_KEYSTORE_PASSWORD` | the store password |
| `ANDROID_KEY_ALIAS` | `upload` |
| `ANDROID_KEY_PASSWORD` | the key password |

The Supabase and Google secrets you already added (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `GOOGLE_WEB_CLIENT_ID`) are reused.

## 3. Build

Actions tab, **Android release (signed)**, Run workflow. When it finishes, download the `wellbeing-release` artifact: `app-release.aab` (for Play) and `app-release.apk` (to install on a phone). The log ends with the signing certificate's SHA-1.

To build on your own computer instead, create `android/key.properties`:

```
storeFile=/full/path/to/upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

and run `flutter build appbundle --release --dart-define-from-file=env.json`.

Every Play upload needs a higher build number: raise the number after `+` in `pubspec.yaml` (`version: 1.0.0+2`) before building.

## 4. Why the release build can look "signed out" of Google

Google sign-in checks which key signed the app. Debug builds, CI debug builds and release builds each use a different key, so each needs its SHA-1 registered.

## 5. Register the release key with Google sign-in

1. Take the SHA-1 printed at the end of the release workflow log (or run `keytool -list -v -keystore upload-keystore.jks -alias upload`).
2. Google Cloud console, APIs and Services, Credentials: open your **Android** OAuth client (package `com.gymapp.wellbeing`) and add the SHA-1, or create another Android client with it.
3. If you publish through Play with Play App Signing (the default), Google re-signs the app with its own key. In Play Console, Test and release, App integrity, App signing, copy the **App signing key certificate** SHA-1 and register that one the same way. Without it, sign-in works on your sideloaded build but fails for people who install from Play.

## 6. Google Play

1. Create a Play Console developer account (one-time fee, identity checks can take days).
2. Create the app: name Well-Being, default language, App (not game), Free.
3. Fill the store listing: short description, full description, an icon (512 x 512, the launcher icon design), at least two phone screenshots, a feature graphic (1024 x 500).
4. Privacy policy: publish `docs/privacy-policy.md` somewhere with a public URL (a GitHub Pages page, or a public gist) after filling in the contact line, and give Play that URL.
5. App content forms:
   - **Data safety.** Collected and linked to the person: name and email (account), workouts, sleep and habit entries (health and fitness, optional), screen-time totals (optional). Shared with other people only when the person turns sharing on in a group: workout type and duration, break goals, name. Encrypted in transit: yes. Deletion: yes, in the app (Settings, Delete account). No ads, no analytics, no data sold.
   - **Permissions.** Usage access (`PACKAGE_USAGE_STATS`) is the one Play looks at closely: say it powers the screen-time feature, that only daily totals leave the reading step, and that the person grants it in system settings after an explanation screen. Notifications and the boot receiver are for reminders.
   - **Health apps declaration:** say it is a general wellness app, not a medical device; the tips carry a "not medical advice" footer.
   - Target audience: adults (18+) is simplest.
6. Internal testing: Test and release, Testing, Internal testing, create a release, upload `app-release.aab`, add testers by email, share the opt-in link.

## Crash reporting

None is included. The app sends no analytics or crash data. If you want crash reports later, a service such as Sentry or Firebase Crashlytics can be added, but the privacy policy and the Data safety form must then say so.

## Before each release

`flutter analyze` and `flutter test` (the release workflow runs both), bump the build number, and check `supabase/migrations` have all been run on the Supabase project.
