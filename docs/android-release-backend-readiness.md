# FI-YOU Android Release Backend Readiness

Last updated: 2026-06-17

Status note: superseded for the full paid Android release by `docs/backend-supabase-release-contract.md`. This older document was written when Star/payment/relation features were considered deferrable. Use the newer contract when Google Play Billing, Paddle web checkout, Star, entitlements, paid reports, and relation features are in release scope.

Owner: Backend & Supabase Lead

Scope: Flutter Android production release. The official website is excluded from this scope.

## Release Position

This is not a demo/MVP-only backend contract. The Android release backend must protect real user data, support Play Console review, and keep Flutter simple enough that the client does not need to know database internals.

Release-critical flows:

1. Google OAuth sign-in
2. Profile creation/read/update
3. Questions read
4. Answers upsert/read
5. Diary CRUD
6. U-Map read
7. Current Signature read
8. Relationship feature read/write with privacy-safe constraints
9. Star ledger read and server-side mutation
10. Google Play Billing purchase verification
11. Paid report entitlement read/write
12. Report read or internal generation handoff
13. Account deletion and data deletion
14. RLS and privacy verification

Payments, Star, paid reports, and relationship features are now explicitly in Android production release scope. They are P0 backend gates, not extension-only backlog items.

## Current SQL vs Release Schema Gap

Current source:

- `supabase/sql/001_initial_schema.sql`
- `docs/database-design.md`
- `docs/mvp-backend-api-contract.md`

| Area | Current state | Release decision | Gap/risk |
| --- | --- | --- | --- |
| Profile | `public.users` maps 1:1 to `auth.users` | Keep `public.users` as profile table | No auth trigger/RPC bootstrap yet. New Google users can lack profile row. |
| Profiles naming | No `profiles` table | Do not add duplicate `profiles` table for release | Flutter calls this "profile", DB remains `users`. |
| Onboarding | No dedicated onboarding table/status | Add profile status fields or `onboarding_answers` if onboarding has separate answers | Current schema cannot mark onboarding completion. |
| Questions | `public.questions`, active read policy | Keep | Need seed/versioning plan for production question catalog. |
| Answers | `public.answers` with unique `(user_id, question_id)` and audit trigger | Keep | Direct table upsert requires client to send `user_id`; release should use RPC deriving `auth.uid()`. |
| Answer metadata | Column grants hide timing/edit metadata | Keep | Verify REST cannot select hidden columns. |
| Diary | `public.diary` singular table | Keep for DB, expose as `diaries` in Flutter repository layer | Direct client mutations currently possible and safe by RLS, but RPC preferred for validation. |
| U-Map | `public.u_map` current-state map | Keep for first Android release | No snapshot history. Add `u_map_snapshots` only if app needs timeline. |
| Signature | `public.signatures` read-only to user | Keep | Need "current signature" selection rule, e.g. latest by `created_at` for `signature_type = primary`. |
| Reports | `public.reports` user can read full row including `payload` | Restrict via RPC or column grants before production | Full `payload` may expose internal prompts/evidence if stored there. |
| Points/Star | `public.points_ledger` exists, user can read own rows | Include in release with server-owned mutation path | Need append-only ledger, idempotent Play Billing processing, no client-side arbitrary crediting, and no internal payment secrets in metadata. |
| Relations | `public.relationships` permits select/insert/update involved rows | Include in release with privacy-safe API/RLS | Need user-owned isolation, minimal third-party personal data, non-diagnostic copy contract, and cross-user RLS verification. |
| Account deletion | FK cascades from `auth.users` | Use server/Edge Function with service role to delete auth user and cascade data | Client cannot receive service role. Need implementation endpoint and session invalidation flow. |
| Data deletion request | Not modeled | Add deletion request/audit table in `private` or backend ticketing | Needed for Play policy handling and support traceability. |
| RPC layer | Not present | Add release RPCs | Flutter should not own DB details or sensitive validation. |

## Release DB/API Contract

Flutter uses Supabase Flutter with the production project URL and publishable/anon key. All user operations run with the user's JWT. Service role key is server-only.

### Auth

Provider:

- Google OAuth through Supabase Auth.

Client responsibilities:

- Start OAuth.
- Hold user session securely through Supabase Flutter.
- Never use `user_metadata` for authorization.
- After sign-in, call `bootstrap_my_profile()`.

Server/dashboard responsibilities:

- Configure Android OAuth redirect/deep link.
- Configure Google OAuth client IDs for release package and SHA-1/SHA-256 as required by the app setup.
- Keep JWT expiry short enough for privacy-sensitive operations.

### Profile

DB table:

- `public.users`

Required release RPC:

```sql
bootstrap_my_profile(
  display_name text default null,
  avatar_url text default null,
  timezone text default 'Asia/Seoul'
) -> jsonb
```

Behavior:

- Uses `auth.uid()` as `public.users.id`.
- Inserts row if absent.
- Updates only user-controlled display fields if present.
- Returns normalized profile DTO.

DTO:

```json
{
  "id": "uuid",
  "displayName": "string|null",
  "avatarUrl": "string|null",
  "timezone": "Asia/Seoul",
  "onboardingCompletedAt": "timestamp|null"
}
```

Required migration:

- Add `onboarding_completed_at timestamptz` to `public.users`, or create `public.onboarding_answers` if onboarding collects separate structured answers.

### Questions

DB table:

- `public.questions`

Release query contract:

```dart
supabase
  .from('questions')
  .select('id, code, prompt, category, question_type, answer_schema, sort_order')
  .eq('is_active', true)
  .order('sort_order');
```

Optional RPC:

```sql
get_questions() -> jsonb
```

DTO:

```json
{
  "id": "uuid",
  "code": "string",
  "prompt": "string",
  "category": "string",
  "questionType": "text|single_choice|multi_choice|scale|json",
  "answerSchema": {},
  "sortOrder": 0
}
```

Release rule:

- Flutter reads catalog only.
- Catalog writes are service/admin only.

### Answers

DB table:

- `public.answers`

Required release RPC:

```sql
upsert_my_answer(
  question_id uuid,
  answer_text text default null,
  answer_value jsonb default null
) -> jsonb
```

Behavior:

- Derives `user_id` from `auth.uid()`.
- Rejects unauthenticated calls.
- Rejects empty answer where both `answer_text` and `answer_value` are null/blank.
- Upserts on `(user_id, question_id)`.
- Returns only user-facing answer fields.
- Lets `private.audit_answer_changes()` maintain timing/edit audit.

Read contract:

```sql
get_my_answers() -> jsonb
```

DTO:

```json
{
  "id": "uuid",
  "questionId": "uuid",
  "answerText": "string|null",
  "answerValue": {}
}
```

Release rule:

- Do not expose `answered_at`, `last_edited_at`, `edit_count`, `created_at`, or `updated_at` to Flutter unless product explicitly needs them.

### Diary

DB table:

- `public.diary`

Required release RPCs:

```sql
create_my_diary(
  entry_date date,
  title text,
  body text,
  mood_score smallint,
  tags text[]
) -> jsonb

update_my_diary(
  diary_id uuid,
  entry_date date,
  title text,
  body text,
  mood_score smallint,
  tags text[]
) -> jsonb

delete_my_diary(diary_id uuid) -> jsonb

get_my_diaries(from_date date default null, to_date date default null) -> jsonb
```

DTO:

```json
{
  "id": "uuid",
  "entryDate": "2026-06-17",
  "title": "string|null",
  "body": "string",
  "moodScore": 1,
  "tags": ["string"],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

Release validation:

- `body` required and non-blank.
- `mood_score` nullable or 1-10.
- `tags` max count and max length should be enforced in RPC or client+RPC.
- Flutter never sends `user_id`.

### U-Map

DB tables:

- `public.u_map`
- `public.traits`

Required release RPC:

```sql
get_my_u_map() -> jsonb
```

DTO:

```json
{
  "traitId": "uuid",
  "traitCode": "string",
  "name": "string",
  "dimension": "string",
  "score": 0.0,
  "confidence": 0.0,
  "evidenceCount": 0,
  "calculatedAt": "timestamp"
}
```

Write path:

- Server/internal only.
- Flutter never inserts or updates `u_map`.

Snapshot decision:

- For first Android production release, `public.u_map` is the current state.
- Add `public.u_map_snapshots` only when history/timeline becomes a product requirement.

### Signature

DB table:

- `public.signatures`

Required release RPC:

```sql
get_current_signature(signature_type text default 'primary') -> jsonb
```

Selection rule:

- `where user_id = auth.uid()`
- `where signature_type = coalesce(input, 'primary')`
- latest by `created_at desc`

DTO:

```json
{
  "id": "uuid",
  "signatureType": "primary",
  "label": "string",
  "summary": "string|null",
  "confidence": 0.0,
  "metadata": {}
}
```

Write path:

- Server/internal only.
- Signature text must follow non-diagnostic AI safety language rules.

### Reports

DB table:

- `public.reports`

Release decision:

- If reports are visible in the first Android release, expose a filtered RPC.
- Do not let Flutter read raw `payload` unless the payload is guaranteed user-facing and scrubbed.

Required RPC if enabled:

```sql
get_my_reports() -> jsonb
get_my_report(report_id uuid) -> jsonb
```

DTO:

```json
{
  "id": "uuid",
  "reportType": "string",
  "status": "pending|processing|ready|failed",
  "title": "string|null",
  "summary": "string|null",
  "generatedAt": "timestamp|null"
}
```

Internal generation:

- Use a server/Edge Function with service role.
- Do not log raw answers or diary content.
- Store only user-facing report payload in `public.reports.payload`, or move raw generation artifacts to `private`.

### Account and Data Deletion

Release requirement:

- User must be able to request account/data deletion in app if accounts are created.
- A deletion URL is also needed for Play Console if account creation is supported.

Recommended implementation:

1. Flutter calls an authenticated Edge Function, `delete-account`, or `request-account-deletion`.
2. Function verifies JWT user with the Supabase server client.
3. Function records a deletion request in a private table.
4. For immediate deletion, function uses service role/admin API to delete `auth.users.id = user_id`.
5. Current foreign keys cascade user-owned rows in `public.users`, `answers`, `diary`, `reports`, `signatures`, `u_map`, `points_ledger`, and relationships involving the user.
6. Function signs out the client or instructs Flutter to clear session immediately.

Required migration:

```sql
create table private.account_deletion_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  status text not null default 'requested'
    check (status in ('requested', 'processing', 'completed', 'failed', 'cancelled')),
  reason text,
  requested_at timestamptz not null default now(),
  processed_at timestamptz,
  metadata jsonb not null default '{}'::jsonb
);
```

Important security note:

- Do not implement account deletion with a public `security definer` function in `public`.
- Existing access tokens may remain valid until expiry after user deletion; Flutter must sign out locally and backend should keep token lifetime appropriate for a privacy-sensitive app.

## Required Migration List

Create migrations through Supabase CLI (`supabase migration new <name>`) before writing files.

1. `add_release_profile_state`
   - Add `onboarding_completed_at timestamptz`.
   - Optional: add `deleted_at timestamptz` only if soft-delete is chosen.

2. `add_release_rpc_contracts`
   - `bootstrap_my_profile`
   - `upsert_my_answer`
   - `get_my_answers`
   - `create_my_diary`
   - `update_my_diary`
   - `delete_my_diary`
   - `get_my_diaries`
   - `get_my_u_map`
   - `get_current_signature`
   - `get_questions`
   - `get_my_reports`
   - `get_my_report`
   - `get_my_star_ledger`
   - `get_my_paid_report_entitlements`
   - `get_my_relationships`

3. `add_account_deletion_requests`
   - Create `private.account_deletion_requests`.
   - Revoke all private schema access from `anon` and `authenticated`.

4. `tighten_release_grants`
   - Keep required grants for questions, profile, answers, diary, U-Map, Signature.
   - Revoke direct `select on public.reports` from `authenticated` and expose scrubbed report data through RPC.
   - Revoke direct ledger writes from Flutter; Star mutations must come from verified server-side purchase/entitlement flows.
   - Revoke unsafe direct relationship writes; expose privacy-checked relationship mutations through RPC or Edge Function.

5. `seed_release_catalogs`
   - Seed production `questions`.
   - Seed production `traits`.
   - Ensure inactive or draft questions have `is_active = false`.

6. Optional `add_u_map_snapshots`
   - Only if product requires historical U-Map.
   - Otherwise explicitly defer.

## RLS Policies and Verification Plan

Current RLS foundations are good:

- Every current `public` table enables RLS.
- User-owned rows use `auth.uid() = user_id` or `auth.uid() = id`.
- Catalog rows use active-only select policies.
- `private.answer_revisions` is in a non-exposed schema with grants revoked.
- Static SQL review confirms explicit `grant` statements are present, which is required for Supabase projects affected by newer Data API exposure defaults.

Current static verification status:

| Check | Status |
| --- | --- |
| Supabase CLI available | Pass: local CLI reports `2.104.0`. |
| `public` tables have RLS enabled in SQL | Pass in `001_initial_schema.sql`. |
| Private schema revoked from client roles | Pass in `001_initial_schema.sql`. |
| Answer timing/edit columns hidden by column grant | Pass in `001_initial_schema.sql`. |
| Runtime two-user RLS test | Not run yet; requires linked local or production Supabase project. |
| Supabase migration history | Not ready; repository currently has `supabase/sql/001_initial_schema.sql`, not `supabase/migrations`. |

Release verification must be run against the actual Supabase project or local Supabase stack with two real authenticated users.

### Required Test Users

- `user_a`
- `user_b`
- Optional `anon` no-session client
- Optional service-role server test client

### RLS Scenarios

| Area | Scenario | Expected result |
| --- | --- | --- |
| No session | Select `public.questions` | Denied or 0 rows, depending release auth requirement. |
| Profile own read | `user_a` reads `public.users` where `id = user_a` | 1 own row |
| Profile other read | `user_a` reads `public.users` where `id = user_b` | 0 rows |
| Profile spoof insert | `user_a` inserts `public.users.id = user_b` | Denied |
| Profile spoof update | `user_a` updates `user_b` profile | 0 rows or denied |
| Catalog read | `user_a` reads active questions | Active questions only |
| Catalog write | `user_a` inserts/updates question | Denied |
| Answer own upsert | `user_a` calls `upsert_my_answer` | Success; row user_id is `user_a` |
| Answer spoof insert | `user_a` directly inserts answer with `user_id = user_b` | Denied |
| Answer other read | `user_a` selects answers for `user_b` | 0 rows |
| Answer hidden metadata | `user_a` selects hidden answer timing/edit columns | Denied/not exposed |
| Answer audit | `user_a` selects `private.answer_revisions` | Denied |
| Diary own CRUD | `user_a` creates/updates/deletes own diary | Success |
| Diary other mutation | `user_a` updates/deletes `user_b` diary | 0 rows or denied |
| U-Map own read | `user_a` calls `get_my_u_map` | Only `user_a` rows |
| U-Map client write | `user_a` inserts/updates `u_map` | Denied |
| Signature own read | `user_a` calls `get_current_signature` | Only latest `user_a` signature |
| Signature client write | `user_a` inserts/updates signature | Denied |
| Report read | If enabled, `user_a` reads report via RPC | Only scrubbed `user_a` fields |
| Report raw payload | Flutter direct select of raw `payload` | Denied if report direct select is revoked |
| Ledger read | `user_a` reads own ledger through approved API | Only `user_a` rows |
| Ledger write | `user_a` inserts ledger row | Denied |
| Relations own read/write | `user_a` uses approved relationship API | Only `user_a` relationship rows, privacy-safe fields |
| Relations other read/write | `user_a` reads or mutates `user_b` relationship rows | Denied |
| Account deletion | `user_a` requests deletion | Request recorded, auth user deleted or queued |
| Post-deletion | `user_a` old session tries data read | Denied after session clear/token expiry |

### Catalog/Grant Checks

```sql
select schemaname, tablename, rowsecurity
from pg_tables
where schemaname = 'public'
order by tablename;
```

Expected:

- Every release-exposed `public` table has `rowsecurity = true`.

```sql
select table_schema, table_name, privilege_type
from information_schema.role_table_grants
where grantee in ('anon', 'authenticated')
order by table_schema, table_name, privilege_type;
```

Expected:

- `anon` has no user-data table access.
- `authenticated` grants match release contract.
- Deferred Star/Relation raw access is revoked or explicitly accepted.

## Flutter Release Env Vars

Client-side release variables:

| Variable | Required | Secret? | Notes |
| --- | --- | --- | --- |
| `SUPABASE_URL` | Yes | No | Production Supabase project URL. |
| `SUPABASE_ANON_KEY` or `SUPABASE_PUBLISHABLE_KEY` | Yes | No, but restrict usage | Used by Flutter. Do not confuse with service role. |
| `SUPABASE_AUTH_REDIRECT_URI` | Yes | No | Android deep link/redirect URI used by OAuth. |
| `GOOGLE_ANDROID_CLIENT_ID` | Usually | No | Required depending Supabase/Flutter OAuth setup. |
| `APP_ENV` | Yes | No | Must be `production` for release build. |
| `SENTRY_DSN` or crash reporting DSN | Optional | No | Only if crash reporting is added; do not log sensitive data. |

Server-only variables:

| Variable | Client exposure | Notes |
| --- | --- | --- |
| `SUPABASE_SERVICE_ROLE_KEY` | Never | Edge Functions/backend only. |
| `SUPABASE_DB_URL` | Never | Direct DB/admin tooling only. |
| `GOOGLE_CLIENT_SECRET` | Never | Only if a server-side OAuth flow requires it. |
| AI provider API keys | Never | Analysis/report generation server-side only. |
| Payment provider keys | Never | Deferred; server-side only when enabled. |

Release build rules:

- No `.env` file containing service role or server secrets may be bundled into the app.
- No debug Supabase project URL in release.
- No verbose logging of answers, diary bodies, OAuth tokens, JWTs, or AI prompts.

## Play Console Data Safety Summary

This summary is for Play Console preparation. Final answers must match the actual release build behavior.

### Data Collected

| Data category | FI-YOU examples | Purpose | Shared with third parties? |
| --- | --- | --- | --- |
| Personal info | Google account identifier/email handled by Supabase Auth, display name, avatar | Account creation, authentication, profile | Supabase as backend processor; Google for OAuth |
| User-generated content | Question answers, Diary text, tags | App functionality, self-discovery insights | AI provider only if server sends content for analysis |
| App activity | Questions answered, diary creation/update timestamps, generated insight status | App functionality, persistence, abuse/debug support | Supabase as backend processor |
| Inferences/AI output | U-Map, Signature, Reports | App functionality, user-facing self-discovery | Stored in Supabase; AI provider may process input if enabled |
| Purchases | Play Billing purchase tokens/order identifiers, Star ledger events, paid report entitlements | Payment processing, entitlement, fraud/support handling | Google Play for billing; Supabase as backend processor |
| Contacts/relationships | User-entered relationship labels/context, only if the feature asks for it | App functionality, relationship self-discovery insights | Supabase as backend processor; AI provider only if server sends content for analysis |
| Diagnostics | Crash logs if added | Crash/error analysis | Crash provider if configured |

### Sensitive Handling

- Diary and answers may contain sensitive personal content because users can type freely.
- The app must not claim medical diagnosis, therapy, counseling, or emergency support.
- User content is used to provide app functionality and AI-assisted insights.
- User data should be encrypted in transit through HTTPS and stored in Supabase/Postgres with access controlled by RLS.
- Users must have a deletion path.

### Data Deletion

Play-facing statement:

- Users can request deletion of their account and associated personal data from inside the app.
- A web deletion URL should also be provided in Play Console.
- On deletion, FI-YOU deletes the Supabase Auth user and cascades associated profile, answers, diary entries, U-Map, Signature, reports, and release-scope ledger/relation rows unless legal retention applies in future paid features.

## Launch-Blocking Risks

| Risk | Severity | Blocker? | Required action |
| --- | --- | --- | --- |
| No profile bootstrap trigger/RPC | High | Yes | Implement `bootstrap_my_profile` or auth trigger. |
| No release RPC layer | High | Yes | Add RPCs for answers, diary, U-Map, Signature, deletion/report reads. |
| Account deletion not implemented | High | Yes | Implement authenticated Edge Function or backend endpoint with service role. |
| Onboarding completion not stored | Medium | Yes if onboarding required | Add status field/table. |
| Reports expose raw `payload` | Medium | Yes if reports enabled | Restrict direct grants or scrub payload. |
| Ledger/Relation grants allow unsafe direct mutation | High | Yes | Restrict writes through RPC/Edge Function, validate ownership, and verify RLS isolation. |
| No production RLS test evidence | High | Yes | Run two-user RLS verification and record results. |
| Question/trait seed data absent | High | Yes | Seed release catalogs. |
| Service role handling not documented in build process | High | Yes | Keep service key server-only and audit release build config. |
| Play Data safety answers not matched to actual behavior | High | Yes | Finalize after release build feature flags are frozen. |
| AI provider data flow unclear | Medium | Yes if AI generation enabled | Document provider, content sent, retention, and logs. |
| Star/payment included without Play Billing | High | Yes | Implement Google Play Billing, server-side purchase verification, idempotent ledger updates, entitlement restore, and refund handling. |
| Relationship feature lacks privacy/RLS evidence | High | Yes | Verify minimal data model, no third-party diagnosis, and two-user RLS isolation. |

## Release Go/No-Go Backend Gate

Backend can approve Android release only when:

- Required migrations are applied to production or staging promoted to production.
- RPC contract is implemented and Flutter uses it for profile, answers, diary, U-Map, Signature, and deletion.
- RLS two-user tests pass.
- Account deletion path is functional.
- Service role key is absent from Flutter build artifacts.
- Data Safety answers match the exact release feature set.
- Star/payment/relation features are fully compliant with Google Play Billing, FI-YOU copy policy, privacy minimization, and RLS evidence.

## Source Notes

- Supabase changelog checked on 2026-06-17. The relevant current platform change is that public schema tables may require explicit grants for Data API exposure in new/current projects; the current SQL already uses explicit grants and should continue to do so.
- Current FI-YOU schema source: `supabase/sql/001_initial_schema.sql`.
- Current design docs: `docs/database-design.md`, `docs/mvp-backend-api-contract.md`, `docs/android-release-growth-plan.md`.
