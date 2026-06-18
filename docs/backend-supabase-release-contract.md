# FI-YOU Backend & Supabase Release Contract

Last updated: 2026-06-17

Scope: Android production release for package `com.fiyou.app`, app name `FI-YOU`.

Payment policy:

- Android in-app purchases: Google Play Billing only.
- Web checkout: Paddle only.
- Future iOS in-app purchases: Apple StoreKit / In-App Purchase.
- Paddle must not be used for Android in-app digital goods.

Privacy policy URL: https://fi-you.vercel.app/privacy

## Implemented Files

Migration:

- `supabase/migrations/20260617090119_release_backend_contract.sql`

Edge Functions:

- `supabase/functions/verify-google-play-purchase/index.ts`
- `supabase/functions/paddle-webhook/index.ts`
- `supabase/functions/delete-account/index.ts`
- `supabase/config.toml`

Release contract doc:

- `docs/backend-supabase-release-contract.md`

## Migration Summary

The release migration extends the existing SQL schema without removing existing data.

New or extended structures:

- `public.users`
  - Adds `onboarding_completed_at`
  - Adds `deletion_requested_at`
- `public.onboarding_answers`
  - Stores structured onboarding state per user and step.
- `public.u_map_snapshots`
  - Stores generated U-Map snapshots if the product needs history.
- `public.star_ledger`
  - Release Star source of truth. No balance column exists.
  - Idempotency index on `(user_id, idempotency_key)`.
  - Provider event index on `(source_provider, source_event_id, user_id)`.
- `public.entitlements`
  - Stores paid report/subscription/feature access.
  - Provider event uniqueness prevents duplicate entitlement grants.
  - Also represents report credits/unlocks when `entitlement_type = 'paid_report'`.
- `public.payment_events`
  - Stores Google Play, Paddle, future StoreKit event processing state.
  - This is the current implementation of the product-facing `purchase_transactions` concept.
  - Purchase token is stored as hash only.
- `public.report_bodies`
  - Separates report body payload from report metadata.
  - RLS allows body read only for free reports or active paid-report entitlement.
- `public.relations`
  - Android release relation record with user-owned `label` and optional `note`.
  - Avoids storing a non-user third party's personal identifiers by default.
- `public.relation_answers`
  - Stores relation feature answers with `own_only` or `shared` visibility.
- `public.account_deletion_requests`
  - Stores deletion request processing evidence after auth/user rows are removed.

Existing structures kept:

- `public.users` remains the app profile table.
- `public.diary` remains the DB table for Flutter "diaries".
- `public.relationships` remains available for future app-user-to-app-user relationship workflows.
- `public.points_ledger` remains legacy/deprecated; Android release should use `star_ledger`.

## RPC/API Contract for Flutter

All RPC calls use the authenticated Supabase Flutter client with the user session JWT.

Auth/session:

- Flutter stores session through Supabase Flutter.
- On app launch, restore session from Supabase Flutter and call `get_my_profile()`.
- After Google OAuth sign-in, call `bootstrap_my_profile()`.
- On account deletion success, clear local Supabase session immediately.

Profile/onboarding:

- `get_my_profile() -> jsonb`
- `bootstrap_my_profile(display_name, avatar_url, timezone) -> jsonb`
- `complete_onboarding(display_name, timezone, answers) -> jsonb`

Questions/answers:

- `get_questions() -> jsonb`
- `get_next_question() -> jsonb`
- `upsert_my_answer(question_id, answer_text, answer_value) -> jsonb`
- `get_my_answers() -> jsonb`

Diary:

- `get_my_diaries(from_date, to_date) -> jsonb`
- `save_my_diary(diary_id, entry_date, title, body, mood_score, tags) -> jsonb`
- `delete_my_diary(diary_id) -> jsonb`

U-Map/Signature/Reports:

- `get_my_u_map() -> jsonb`
- `get_current_signature(signature_type) -> jsonb`
- `get_my_reports() -> jsonb`
- `get_my_report(report_id) -> jsonb`
- `get_paid_report_access(report_id) -> jsonb`

Star/entitlements:

- `get_my_star_balance() -> jsonb`
- `get_my_star_ledger() -> jsonb`
- `get_my_entitlements() -> jsonb`

Relations:

- `get_my_relations() -> jsonb`
- `create_my_relation(label, note) -> jsonb`
- `create_relation_request(addressee_id, relationship_type) -> jsonb`
- `update_relation_status(relationship_id, status) -> jsonb`
- `upsert_relation_answer(relationship_id, question_id, prompt_code, answer_text, answer_value, visibility) -> jsonb`
- `get_relation_answers(relationship_id) -> jsonb`

Deletion:

- `request_account_deletion(reason) -> jsonb`
- Edge Function `delete-account` for actual auth user deletion.

Payment APIs:

- Edge Function `verify-google-play-purchase`
  - Called by Android only after Google Play Billing returns a purchase token.
  - Requires user Authorization bearer token.
  - Accepts the current Flutter body shape:
    - `productId`
    - `purchaseToken`
    - `source`
    - optional top-level metadata fields such as `packageName`, `productType`, `entitlementType`, `amountStars`, `resourceType`, `resourceId`, `productCode`
    - optional wrapped `metadata` object with the same metadata fields
  - Does not trust client-provided Star amounts. Server product catalog decides `amountStars`, entitlement type, product type, and product code.
  - Rejects non-Android/non-Google source values.
  - Rejects package mismatch; production package must be `com.fiyou.app`.
  - Rejects products outside `GOOGLE_PLAY_ALLOWED_PRODUCTS` or the internal product catalog.
  - Verifies token against Google Android Publisher API.
  - On success, writes `payment_events`, grants Stars in `star_ledger`, and grants `entitlements` if requested.
- Edge Function `paddle-webhook`
  - Called by Paddle webhook only.
  - Verifies `paddle-signature`.
  - On success/refund/cancel events, updates the same `payment_events`, `star_ledger`, and `entitlements` structures.
- Edge Function `delete-account`
  - Requires user Authorization bearer token and JSON `{ "confirm": "DELETE" }`.
  - Uses service role server-side to delete the Auth user.

## Required Environment Variables

Flutter release build:

| Variable | Secret? | Required | Notes |
| --- | --- | --- | --- |
| `SUPABASE_URL` | No | Yes | Production Supabase URL. |
| `SUPABASE_ANON_KEY` or publishable key | No, protected by RLS | Yes | Client key only. |
| `SUPABASE_AUTH_REDIRECT_URI` | No | Yes | Android deep link redirect. |
| `GOOGLE_ANDROID_CLIENT_ID` | No | If OAuth setup requires it | Match release package/signing setup. |
| `ANDROID_PACKAGE_NAME` | No | Yes | Must be `com.fiyou.app`. |
| `APP_ENV` | No | Yes | Must be `production` in release. |

Supabase Edge Function secrets:

| Secret | Function | Notes |
| --- | --- | --- |
| `SUPABASE_URL` | all | Available in hosted functions. |
| `SUPABASE_SERVICE_ROLE_KEY` | all | Never exposed to Flutter. |
| `GOOGLE_PLAY_PACKAGE_NAME` | Google Play | Must be `com.fiyou.app`. |
| `GOOGLE_PLAY_ALLOWED_PRODUCTS` | Google Play | Optional comma-separated override. Defaults to the built-in FI-YOU release product catalog. |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Google Play | Service account with Android Publisher access. |
| `PADDLE_WEBHOOK_SECRET` | Paddle | Used to verify webhook signatures. |
| `PADDLE_SIGNATURE_TOLERANCE_SECONDS` | Paddle | Optional. Defaults to `5`. |

Future server-only secrets:

- `APPLE_STOREKIT_*`
- AI provider API keys
- Payment/provider support keys

## Google Play Verification Operations

Production requirements:

- Play Console app package must be `com.fiyou.app`.
- `GOOGLE_PLAY_PACKAGE_NAME` must be `com.fiyou.app`.
- Google Cloud service account must have Android Publisher access for the Play Console app.
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` must be stored only as a Supabase Edge Function secret.
- `GOOGLE_PLAY_ALLOWED_PRODUCTS`, if set, must include only approved FI-YOU Play product IDs.
- The Edge Function rejects package mismatch, source mismatch, product allowlist mismatch, and product type mismatch before granting any Star/entitlement.
- The server catalog is the source of truth for Star grant amounts and entitlement type. Flutter metadata is treated as a hint only.
- One-time products are verified through Google Play `purchases.products.get`.
- Subscriptions are verified through Google Play `purchases.subscriptionsv2.get`.

Current live status:

- Live Google Play token verification pending.
- The function path is implemented, but it still needs a real internal-testing Play purchase token, production Supabase secrets, and Google service account credentials to prove the end-to-end verification.

## RLS and Access Model

User-owned data:

- `users`, `onboarding_answers`, `answers`, `diary`, `u_map`, `u_map_snapshots`, `signatures`, `reports`, `report_bodies`, `star_ledger`, `entitlements`, `relations`, `relationships`, `relation_answers`, and `account_deletion_requests` are protected by RLS.
- User rows use `auth.uid() = user_id` or `auth.uid() = id`.

Catalog data:

- `questions` and `traits` are authenticated active-only reads.
- Client writes are not granted.

Report access:

- `reports` grants metadata columns only.
- Full report body lives in `report_bodies`.
- `report_bodies` RLS permits read only when the report is free or the user has active paid-report entitlement.

Star/ledger:

- Flutter can read own balance and ledger through RPC.
- Flutter cannot insert/update/delete Star ledger rows.
- Star grants/revokes are server-only through Google Play/Paddle/StoreKit/admin flows.

Relations:

- Relationship row visibility is limited to requester/addressee.
- Android release `relations` rows are user-owned label/note records.
- Relation answers default to `own_only`.
- Shared relation answers are visible only to involved users.
- Relation feature must describe the relationship from submitted records, not diagnose or label the other person.

Payment events:

- No direct client access.
- Purchase token is hashed before storage.
- Provider event ID/idempotency keys prevent duplicate Star/entitlement grants.
- Platform/source separation is explicit:
  - Android in-app payment writes `source_provider = 'google_play'`.
  - Web Paddle payment writes `source_provider = 'paddle'`.
  - Future iOS payment writes `source_provider = 'apple_storekit'`.
  - Entitlements can be read cross-platform after backend verification, but Android purchase CTAs must not route to Paddle.

## RLS Verification Status

Completed static checks:

- Confirmed Supabase CLI is installed: `2.104.0`.
- Created migration through `supabase migration new`.
- Confirmed migration enables RLS for new release tables.
- Confirmed no service role key is present in repository text search.
- Confirmed Flutter Android package is already `com.fiyou.app` in `mobile/fi_you/android/app/build.gradle.kts`.

Attempted runtime checks:

- `supabase db lint --local --schema public --fail-on error`
  - Result: not run; local Postgres refused connection on `127.0.0.1:54322`.
- `supabase start`
  - Result: failed because Docker Desktop/daemon is unavailable in this environment.
- Deno type check
  - Result: not run because `deno` command is not installed in this environment.

Required remaining RLS tests:

| Scenario | Expected |
| --- | --- |
| User A selects User B profile | 0 rows |
| User A upserts answer for User B | Denied |
| User A reads User B diary | 0 rows |
| User A updates/deletes User B diary | 0 rows or denied |
| User A reads User B U-Map/Signature | 0 rows |
| User A reads paid report body without entitlement | 0 rows or empty payload |
| User A reads paid report body with entitlement | Own report body returned |
| User A inserts Star ledger directly | Denied |
| Duplicate Google/Paddle event replay | No duplicate Star/entitlement grant |
| User A reads unrelated relationship | 0 rows |
| User A reads `own_only` relation answer by User B | 0 rows |
| User A reads shared relation answer by involved User B | Returned |
| Paddle webhook with bad signature | 401 |
| Google purchase verify without valid JWT | 401 |
| Account deletion with invalid session | 401 |
| Account deletion with valid session and confirmation | Auth user deleted, data cascades or retained by policy |

## Data Safety Evidence

| Data | Stored in | Purpose | Access | Delete policy |
| --- | --- | --- | --- | --- |
| Account/profile | `auth.users`, `public.users` | Auth, display profile, timezone, onboarding state | Own user via RLS, server admin | Auth user delete cascades `users`; deletion request retained |
| Onboarding answers | `public.onboarding_answers` | Personalization and initial state | Own user via RLS | Cascades with user deletion |
| Question answers | `public.answers`, private audit in `private.answer_revisions` | Self-discovery loop and analysis | Own answer content via RLS; audit server-only | Cascades with user deletion |
| Diary | `public.diary` | Journaling and insight generation | Own user via RLS | Cascades with user deletion |
| U-Map | `public.u_map`, `public.u_map_snapshots` | User-facing self-discovery map | Own user via RLS | Cascades with user deletion |
| Signature | `public.signatures` | User-facing current tendency summary | Own user via RLS | Cascades with user deletion |
| Reports | `public.reports`, `public.report_bodies` | Free/paid report metadata and body | Own metadata; body gated by entitlement RLS | Cascades with user deletion |
| Star ledger | `public.star_ledger` | Star grant/spend/revoke audit | Own read; server-only writes | Cascades for now; future accounting retention may anonymize |
| Entitlements | `public.entitlements` | Paid report/subscription/feature access | Own read; server-only writes | Cascades for now; future accounting retention may anonymize |
| Payment events | `public.payment_events` | Provider event idempotency and refunds/cancellations | Server-only | Retention may be needed for fraud/accounting; raw tokens are not stored |
| Relation data | `public.relations`, `public.relationships`, `public.relation_answers` | Relationship self-reflection feature | Own relation rows; involved app-user relationship rows; answers `own_only` by default | Cascades with user deletion |
| Account deletion requests | `public.account_deletion_requests` | Deletion processing evidence | Own read/insert; server processing | Retained after user delete without content body |

## Release Thread Notes for Play Console

- FI-YOU collects account info, user-generated answers/diary, AI-generated U-Map/Signature/Reports, purchase/entitlement state, and relation self-reflection records.
- User content is used for app functionality and AI-assisted self-discovery.
- The Android app uses Google Play Billing for in-app digital purchases.
- Paddle is web-only and must not appear as Android in-app payment.
- Users can request account deletion in-app and through the privacy URL flow.
- The app must disclose that AI insights are reflective and non-diagnostic.
- Do not claim relationship outputs diagnose or determine another person.

## Remaining Blockers

| Blocker | Owner | Status |
| --- | --- | --- |
| Apply migration to a real/local Supabase DB | Backend | Blocked by unavailable Docker/local DB here |
| Run two-user RLS test suite | Backend QA | Pending real/local Supabase |
| Deno typecheck/deploy Edge Functions | Backend | Pending Deno/Supabase function runtime |
| Configure Google Play service account | Release/Backend | Pending Play Console credentials |
| Configure Paddle webhook secret and URL | Web/Backend | Pending Paddle dashboard |
| Confirm report generation writes payload to `report_bodies`, not `reports.payload` | AI/Backend | Pending generator integration |
| Flutter Supabase repository implementation | Flutter | Pending frontend repository work |
| Payment product code mapping | Product/Backend | Pending SKU/product table decision |
| StoreKit implementation | Future iOS | Backlog |

## Current Judgment

Status: conditional complete.

Reason:

- The release schema, RLS model, RPC contract, Google Play/Paddle/delete-account server boundaries, and Data Safety basis are implemented as repository artifacts.
- Runtime DB lint/RLS execution could not be completed in this environment because Docker/local Supabase is unavailable and the project is not linked to a remote Supabase instance.
- Edge Function typecheck could not be completed because Deno is not installed in this environment.
