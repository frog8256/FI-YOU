# FI-YOU Android First Entry Flow QA Checklist

Date: 2026-06-23
Scope: Flutter Android official release first-entry integration QA

## Current Gate

Release must stay blocked until the first-entry flow is verified on a Play-installable Android build with live Supabase configuration.

The app should be judged by the Flutter Android implementation, not by the PWA prototype. The PWA is useful only as a flow reference.

## Required First-Entry Scenarios

| Scenario | Required result | Blocker if failed |
| --- | --- | --- |
| Fresh install | App opens Intro/Login/Auth gate, not Home or mock data. | P0 |
| Signed out restore | Cold start with no Supabase session routes to signed-out UI. | P0 |
| Google login start | Tapping Google starts provider flow once and shows return/loading state. | P0 |
| Google login cancel | Cancel returns to Login/Intro with retry available and no crash/stuck spinner. | P1 |
| Google login failure/offline | Failure copy is understandable; user can retry; no session is created. | P1 |
| Auth return loading | Returning from browser/app switch restores session or returns to signed-out/error state within a bounded time. | P0 |
| Onboarding required | Signed-in user without completed profile routes to onboarding, not Home. | P0 |
| Profile setup save failure | Name/profile draft remains; duplicate submit is blocked; retry works. | P0 |
| Onboarding answer save failure | Answer draft remains; no false success; retry works after network recovery. | P0 |
| Feedback after clue | Disagree/hide/report feedback is persisted and reflected in Home/Insight state. | P0 |
| Home entry after completion | Completing required onboarding and answer flow opens Home with live user data or safe low-data state. | P0 |
| App relaunch session restore | Force-stop and reopen restores ready/onboarding/signed-out state correctly. | P0 |

## Integration Risks To Recheck

- `main.dart` now uses `LaunchGate`, but verify final branch still does. A regression to direct `FiYouShell` launch is a P0 blocker.
- Korean mojibake remains in multiple Flutter auth/core strings and existing QA docs. Any broken Hangul visible in release screenshots is a P0/P1 depending on surface.
- Android OAuth/deep link handling needs a manifest intent-filter and Supabase redirect URL parity check. Without it, Google return can stall at auth loading.
- Supabase session persistence must be proven after force-stop, app update, token expiry, and sign-out. Release builds must not fall back to mock state.
- `supabase_flutter` OAuth defaults should be checked for Android redirect behavior; explicit redirect URL may be required.
- Question answer persistence is vulnerable to UI option text and Supabase option label mismatch. Save failures must not be shown as success.

## Final Verification Commands

```powershell
cd C:\Users\frog8\Desktop\project\Fi-You\mobile\fi_you
C:\Users\frog8\development\flutter\bin\flutter.bat clean
C:\Users\frog8\development\flutter\bin\flutter.bat pub get
C:\Users\frog8\development\flutter\bin\flutter.bat analyze
C:\Users\frog8\development\flutter\bin\flutter.bat test
C:\Users\frog8\development\flutter\bin\flutter.bat build appbundle --release `
  --dart-define=APP_ENV=production `
  --dart-define=SUPABASE_URL=<production-url> `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<production-key>
```

## Android Studio / Emulator Procedure

1. Use a clean emulator or physical device with Google Play Services.
2. Uninstall the app and clear any existing browser/provider auth state if needed.
3. Install the release-equivalent APK/AAB output, not a debug mock fallback build.
4. Record fresh install -> Google login -> auth return -> onboarding -> Home.
5. Force-stop and relaunch after each state: signed out, auth return, onboarding required, ready/Home.
6. Repeat with network disabled during login, profile save, answer save, and feedback/report save.
7. Capture screenshots for Intro/Login/AuthReturn/Onboarding/Home and confirm no mojibake.

