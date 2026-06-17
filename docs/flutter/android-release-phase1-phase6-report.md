# FI-YOU Android Release Phase 1 + Phase 6 Frontend Report

Last updated: 2026-06-17

## Current Judgment

Conditional complete.

Frontend Phase 1 and Phase 6 setup is implemented and verified at code/build level. Runtime production verification is still blocked by missing live Supabase RPCs, Google Play Billing product configuration, and emulator/device QA.

## What Changed

- Android package identity is fixed:
  - `namespace = "com.fiyou.app"`
  - `applicationId = "com.fiyou.app"`
  - app label `FI-YOU`
- Kotlin package moved to `com.fiyou.app`.
- Supabase config is injected through dart-define:
  - `SUPABASE_URL`
  - `SUPABASE_PUBLISHABLE_KEY`
  - `SUPABASE_ANON_KEY` remains only as a compatibility fallback.
- Release runtime no longer falls back to mock data.
- Dev/test mock repository remains available only when not in release mode and `APP_ENV` is local/development/test.
- Supabase repository now targets Backend RPC contracts instead of app-owned business logic.
- Auth session restore is connected through `getCurrentProfile()`.
- Screens and state surfaces added/updated:
  - Auth
  - Onboarding
  - Today
  - Question
  - Diary list/detail/edit/delete
  - U-Map
  - Signature
  - Relations
  - Reports
  - Store / Google Play Billing entry
  - Settings / Legal / deletion request
- Android release build config updated:
  - `compileSdk = 36`
  - `targetSdk = 36`
  - network permission
  - adaptive icon XML
  - dark splash background
- Privacy policy URL is wired to `https://fi-you.vercel.app/privacy`.

## Verification

Executed in `mobile/fi_you`:

```powershell
C:\Users\frog8\development\flutter\bin\flutter.bat pub get
```

Result: passed.

```powershell
C:\Users\frog8\development\flutter\bin\cache\dart-sdk\bin\dart.exe analyze
```

Result: passed, no issues found.

```powershell
C:\Users\frog8\development\flutter\bin\flutter.bat test
```

Result: passed, 1 test passed.

Workspace AAB build was blocked by OneDrive file locks in generated `build/` plugin folders. To isolate source/build correctness, the same source was copied to:

```text
C:\Users\frog8\AppData\Local\Temp\fi_you_build_check
```

Then:

```powershell
C:\Users\frog8\development\flutter\bin\flutter.bat pub get
C:\Users\frog8\development\flutter\bin\flutter.bat build appbundle --release
```

Result: passed.

Generated AAB:

```text
C:\Users\frog8\AppData\Local\Temp\fi_you_build_check\build\app\outputs\bundle\release\app-release.aab
```

Size: 51.4 MB.

## Backend Requests

Required RPCs for current Flutter integration:

```sql
get_my_profile()
upsert_my_profile(display_name text, avatar_url text, timezone text)
get_next_question()
upsert_my_answer(question_id uuid, answer_text text, answer_value jsonb)
get_my_diaries(from_date date, to_date date)
get_my_diary(id uuid)
create_my_diary(entry_date date, title text, body text, mood_score smallint, tags text[])
update_my_diary(id uuid, entry_date date, title text, body text, mood_score smallint, tags text[])
delete_my_diary(id uuid)
get_my_u_map()
get_current_signature(signature_type text)
get_my_star_balance()
get_my_entitlements()
get_store_products(platform text)
submit_android_purchase_token(product_id text, purchase_token text, source text)
get_my_relations()
create_my_relation(label text, note text)
get_my_reports()
request_account_deletion(reason text)
```

Backend must validate Android purchase tokens server-side before granting Stars, entitlements, or report access.

## AI Logic Requests

- Question payloads must keep questions free and not imply paid access is required.
- U-Map payload must represent current record-based tendency and clarity only.
- Signature payload must be a current-flow summary, not a fixed type.
- Relation payload must describe the user's own relationship pattern from their records, not evaluate or label the other person.
- Report payloads must avoid fixed typing, certainty, and prohibited clinical language.

## Release Requests

- Configure Google Play products for Android:
  - consumable Star products
  - non-consumable or entitlement-backed paid report products
- Confirm product IDs with Backend and Flutter before closed testing.
- Keep Paddle for web checkout only.
- Use Apple StoreKit / IAP for future iOS internal purchases.
- Confirm Play Console privacy policy URL:
  - `https://fi-you.vercel.app/privacy`
- Move production signing credentials outside the repo before final upload.

## Product QA Requests

Check these first:

- No copy says the user is a fixed type.
- No copy uses prohibited certainty or clinical framing.
- Question flow is never paywalled.
- Store entry does not appear before the core self-discovery loop.
- U-Map copy says current records and clarity.
- Signature copy says current flow and can change with more records.
- Relation flow asks only for a user-facing alias and optional note.
- Settings exposes privacy policy, deletion request, and logout.
- Small screen, font scaling, keyboard, and Android back navigation pass emulator QA.

## Remaining Blockers

- Live Supabase RPCs are not available in this thread, so production data flow is not runtime-verified.
- Google Play Billing product IDs and backend token validation are not yet configured.
- Emulator QA was not run in this turn.
- Workspace AAB build is blocked by OneDrive/generated-file locks, but the same source builds successfully in a temp path outside OneDrive.
- Flutter warns that some transitive plugins still apply Kotlin Gradle Plugin. This is not blocking today, but should be monitored before future Flutter upgrades.
