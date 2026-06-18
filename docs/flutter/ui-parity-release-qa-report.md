# FI-YOU Flutter UI Parity QA Report

Date: 2026-06-18

## Goal

Rework the Flutter UI so the Android app follows the first FI-YOU web UI direction:

- Deep night canvas: `#020714`
- Violet, blue, cyan, and gold accents
- Glass surface cards with soft borders
- U-Map as a flow visualization, not a type result
- Signature as a current-flow label, not a fixed identity type
- Store and paid reports as optional exploration, not pressure-first sales UX

## Scope Completed

- Existing FI-YOU UI reference reviewed from `src/index.css`, `tailwind.config.ts`, and landing components.
- Flutter design system updated:
  - `AppTheme`
  - `AppBackground`
  - `GlassCard`
  - `ScreenState`
  - shared FI-YOU components
- Screens redesigned:
  - Auth
  - Onboarding
  - Today
  - Question
  - Diary list/detail/edit
  - U-Map
  - Signature
  - Store
  - Reports
  - Relations
  - Settings
  - Legal notices
- Local mock data rewritten to match product tone.
- Navigation labels repaired.
- Empty, loading, and error states unified.
- Mojibake Korean text removed from Flutter `lib`.

## Product Policy QA

Passed:

- No "당신은 OO형입니다" style expression found.
- No "정확도" or "분석 정확도" expression found.
- U-Map copy uses "선명도" and "흐름".
- Signature copy states that it is not a fixed type.
- Store copy states that core questions and Diary remain the center.
- Relations copy states that FI-YOU does not analyze the other person.
- Medical/counseling/diagnosis language appears only in negative disclaimer context.

## Verification

Passed:

- `dart analyze`
- `flutter test`
- Debug APK build
- Debug APK install on `emulator-5556`
- Android activity launch: `com.fiyou.app/.MainActivity`
- Auth screen visual screenshot
- Small-screen forced viewport screenshot at `720x1280`
- Text corruption search in Flutter `lib`
- Policy-risk search for fixed-type/accuracy wording

## Release Build Note

`flutter build appbundle --release` did not complete in the canonical Korean path because Flutter/Gradle AOT reads the path with broken encoding on Windows.

An ASCII build copy at `C:\fiyou_build` passed analysis and reached the release signing step. The remaining failure was `:app:signReleaseBundle`, because `mobile/fi_you/android/key.properties` is not present in the local workspace. This is a signing environment issue, not a UI regression.

Required before final Play upload:

- Restore/create `mobile/fi_you/android/key.properties`.
- Point `storeFile` to the backed-up `fi-you-upload-keystore.jks`.
- Build from an ASCII path such as `C:\fiyou_build\mobile\fi_you` or move the canonical project path to ASCII-only before release AAB generation.
