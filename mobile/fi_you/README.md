# FI-YOU Flutter App

This folder contains the Android-first Flutter implementation for the FI-YOU release app.

Release identifiers:

- Android package name: `com.fiyou.app`
- App name: `FI-YOU`
- Version: `1.0.0+1`
- Privacy policy: `https://fi-you.vercel.app/privacy`

After Flutter is available on PATH, run:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release --dart-define=APP_ENV=production --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=your-publishable-key
```

Expected AAB:

```text
build/app/outputs/bundle/release/app-release.aab
```

Android payments:

- Android in-app digital goods must use Google Play Billing.
- Web checkout uses Paddle only outside the Android app.
- Product IDs and QA scenarios are defined in `../../docs/android-billing-release-plan.md`.

Runtime config:

```powershell
flutter run --dart-define=APP_ENV=development --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=your-publishable-key
```

Mock data is available only for local/dev/test builds by passing `--dart-define=APP_ENV=development` without Supabase values. Production and release builds must pass `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`.
