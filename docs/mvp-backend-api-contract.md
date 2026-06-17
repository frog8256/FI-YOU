# FI-YOU Historical Backend/API Contract

> Superseded for Android official release planning. This file is historical context only; use the Android production release and Supabase readiness documents for current launch decisions.

Last updated: 2026-06-17

## MVP Backend Scope

This historical document narrowed the backend scope for an earlier Flutter Android MVP to the core self-discovery loop:

1. Auth sign-in
2. Profile bootstrap
3. Question fetch
4. Answer upsert/read
5. Diary CRUD
6. U-Map and current Signature read
7. Next question recommendation inputs
8. Account/data deletion

Payments, Star balance, relations, and paid report flows remain extension points for the first release unless they are needed for QA or internal testing.

## Current Schema Mapping

The current SQL source is `supabase/sql/001_initial_schema.sql`.

| Product concept | Current table | MVP status | Notes |
| --- | --- | --- | --- |
| Auth user | `auth.users` | P0 | Google OAuth identity source. |
| Profile/user | `public.users` | P0 | Current schema uses `users`, not `profiles`. Flutter should treat this as the profile row. |
| Questions | `public.questions` | P0 | Shared catalog, authenticated users read active rows. |
| Answers | `public.answers` | P0 | One current answer per user/question. Answer timing/edit metadata is not exposed to normal users. |
| Answer audit | `private.answer_revisions` | P0 internal | Private schema only. No client access. |
| Diary | `public.diary` | P0 | Current schema uses singular `diary`. Flutter API can expose this as `diaries`. |
| U-Map | `public.u_map` | P0 read | Current-state trait map. Snapshot history is not present yet. |
| Signature | `public.signatures` | P0 read | User-owned generated signature rows. |
| Reports | `public.reports` | P1 internal | Generation is backend-only. Client may read ready reports later. |
| Star/points ledger | `public.points_ledger` | P1 hold | Keep append-only ledger. Do not surface as MVP requirement. |
| Relations | `public.relationships` | Hold | Not required for P0 loop. |

## P0 Data Contract

All Flutter requests use the authenticated Supabase client with a user JWT. Never ship service role keys to Flutter.

### Profile Bootstrap

Purpose: create or fetch the app profile row after OAuth sign-in.

Current table path:

- `select` from `public.users`
- `insert` into `public.users` with `id = auth.currentUser.id`
- `update` only `display_name`, `avatar_url`, `timezone`

Recommended RPC contract:

```sql
get_my_profile() -> jsonb
upsert_my_profile(display_name text, avatar_url text, timezone text) -> jsonb
```

Response shape:

```json
{
  "id": "uuid",
  "displayName": "string|null",
  "avatarUrl": "string|null",
  "timezone": "Asia/Seoul"
}
```

Launch note: there is no `auth.users` trigger that auto-creates `public.users`. Flutter must bootstrap the row after sign-in, or the backend should add a safe auth trigger before launch.

### Questions

Purpose: fetch active question catalog.

Current table path:

- `public.questions`
- filter: `is_active = true`
- order: `sort_order asc, created_at asc`

Recommended RPC contract:

```sql
get_questions() -> setof question dto
```

Response shape:

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

### Answers

Purpose: save and fetch the current user's answers.

Current table path:

- `public.answers`
- unique key: `(user_id, question_id)`
- user can select only `id`, `user_id`, `question_id`, `answer_text`, `answer_value`
- timing/edit columns are intentionally hidden from `authenticated`

Recommended RPC contract:

```sql
upsert_my_answer(question_id uuid, answer_text text, answer_value jsonb) -> jsonb
get_my_answers() -> setof answer dto
```

Response shape:

```json
{
  "id": "uuid",
  "questionId": "uuid",
  "answerText": "string|null",
  "answerValue": {}
}
```

Validation:

- `answer_text` or `answer_value` must be present.
- Flutter must not send `user_id`; backend/RLS should derive it from `auth.uid()`.
- Direct table upsert is possible today, but RPC is preferred before MVP to keep user ownership and future validation out of the client.

### Diary CRUD

Purpose: create, read, update, and delete private diary entries.

Current table path:

- `public.diary`
- user can select/insert/update/delete only own rows

Recommended RPC contract:

```sql
create_my_diary(entry_date date, title text, body text, mood_score smallint, tags text[]) -> jsonb
update_my_diary(id uuid, entry_date date, title text, body text, mood_score smallint, tags text[]) -> jsonb
delete_my_diary(id uuid) -> void
get_my_diaries(from_date date, to_date date) -> setof diary dto
```

Response shape:

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

### U-Map

Purpose: show the current self-discovery map.

Current table path:

- `public.u_map`
- join with active `public.traits`
- user can read own rows only
- client writes are not allowed

Recommended RPC contract:

```sql
get_my_u_map() -> setof u_map dto
```

Response shape:

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

Launch note: historical `u_map_snapshots` are not in the current SQL. For MVP, use `u_map` as the current state. Add snapshot history only if the app needs timeline/replay.

### Current Signature

Purpose: show the latest generated Signature.

Current table path:

- `public.signatures`
- user can read own rows only

Recommended RPC contract:

```sql
get_current_signature(signature_type text default 'primary') -> jsonb
```

Response shape:

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

Implementation rule:

- Flutter reads Signature.
- Backend/internal process generates or updates Signature.
- Client must not insert generated analysis results directly for production.

### Next Question Recommendation

Purpose: choose the next question after current answers.

MVP-safe option:

- Flutter fetches `questions` and `answers`.
- Client picks the first active unanswered question ordered by `sort_order`.

Preferred backend contract:

```sql
get_next_question() -> question dto
```

Future option:

- Use `answers`, `u_map`, and analysis state to recommend a question.
- Keep AI prompt details out of Flutter.

### Account/Data Deletion

Purpose: support user deletion and privacy requests.

MVP contract:

```sql
request_account_deletion(reason text default null) -> jsonb
delete_my_data(confirm_text text) -> jsonb
```

Policy recommendation:

- MVP can use hard delete by deleting `auth.users`; current foreign keys cascade to `public.users`, `answers`, `diary`, `reports`, `signatures`, `u_map`, `points_ledger`, and relationships involving the user.
- Before calling admin delete, sign the user out or revoke sessions where possible because existing access tokens may remain valid until expiry.
- If legal/accounting retention is needed later, replace full cascade for ledger/payment tables with anonymized retained rows.

## RLS Verification Checklist

Run these checks with at least two authenticated test users, `user_a` and `user_b`.

| Area | Check | Expected result |
| --- | --- | --- |
| Profile select | `user_a` selects `public.users` where `id = user_b` | 0 rows |
| Profile insert | `user_a` inserts `public.users.id = user_b` | denied by RLS |
| Profile update | `user_a` updates `user_b` profile | 0 rows or denied |
| Questions | authenticated user selects active questions | active rows only |
| Questions | authenticated user inserts/updates question | denied |
| Answers select | `user_a` selects all answers | only `user_a` rows |
| Answers columns | `user_a` selects answer timing/edit columns via REST | denied/not exposed |
| Answers insert | `user_a` inserts answer with `user_id = user_b` | denied |
| Answers update | `user_a` updates `user_b` answer | 0 rows or denied |
| Answer audit | authenticated user selects `private.answer_revisions` | denied |
| Diary select | `user_a` selects all diary rows | only `user_a` rows |
| Diary insert | `user_a` inserts diary with `user_id = user_b` | denied |
| Diary update/delete | `user_a` mutates `user_b` diary | 0 rows or denied |
| U-Map | `user_a` selects all u_map rows | only `user_a` rows |
| U-Map writes | authenticated user inserts/updates u_map | denied |
| Signature | `user_a` selects all signatures | only `user_a` rows |
| Reports | `user_a` selects all reports | only `user_a` rows |
| Ledger | authenticated user inserts ledger row | denied |
| Ledger select | `user_a` selects ledger | only `user_a` rows |
| Relations | unrelated user selects relationship | 0 rows |

Extra SQL catalog checks:

```sql
select schemaname, tablename, rowsecurity
from pg_tables
where schemaname = 'public'
order by tablename;
```

Every public table exposed to the API should have `rowsecurity = true`.

```sql
select table_schema, table_name, privilege_type
from information_schema.role_table_grants
where grantee in ('anon', 'authenticated')
order by table_schema, table_name, privilege_type;
```

Confirm `anon` has no user-data access and `authenticated` grants match the MVP contract.

## Flutter Integration Order

1. Configure Supabase Flutter with project URL and publishable/anon client key only.
2. Implement Google OAuth sign-in.
3. On successful session, call profile bootstrap.
4. Fetch active questions.
5. Fetch current answers.
6. Upsert answer after each question response.
7. Fetch next question using MVP rule or `get_next_question()`.
8. Implement diary list/create/edit/delete.
9. Fetch U-Map and current Signature after enough answers or after internal generation.
10. Add account/data deletion entry points in settings.
11. Run RLS cross-user tests before release.

## Deferred Backend Features

These were originally marked as non-blocking for the earlier Flutter Android MVP:

- Star balance UI and paid Star consumption.
- Paddle webhook processing.
- Refund/cancellation/dispute ledger events.
- Relationship and relation answer flows.
- Paid report generation UX.
- U-Map snapshot history/timeline.
- Admin dashboards.
- Complex AI next-question ranking.

## Security and Privacy Risks

| Risk | MVP control |
| --- | --- |
| Service role key exposure | Never include service role keys in Flutter, repo, logs, or public env vars. |
| Cross-user reads | RLS verification with two users before launch. |
| Client-provided `user_id` spoofing | Prefer RPCs that derive ownership from `auth.uid()`. |
| Answer edit metadata exposure | Keep column-level grants limited for `public.answers`. |
| Private audit leakage | Keep `private` schema revoked from `anon` and `authenticated`. |
| AI analysis overexposure | Return only user-facing Signature/U-Map fields to Flutter. Keep raw prompts/internal evidence private if sensitive. |
| Account deletion token window | Sign out/revoke sessions and keep JWT expiry short for sensitive operations. |
| Ledger abuse | No client writes to `points_ledger`; enforce idempotency on trusted writes later. |
| Future payment retention | Store payment provider IDs only in server-side/internal metadata with minimal payloads. |
| Logs with personal content | Do not log diary bodies, raw answers, OAuth tokens, or webhook secrets. |

## Recommended Pre-Launch Backend Changes

1. Add RPCs for profile, answer upsert, diary CRUD, U-Map, current Signature, and account deletion.
2. Add a profile bootstrap trigger or formalize Flutter-side bootstrap after OAuth.
3. Decide whether `public.diary` should remain singular or be renamed to `public.diaries` before mobile client work hardens.
4. Decide whether MVP needs `u_map_snapshots`; otherwise document `public.u_map` as current state only.
5. Add seed data for `questions` and `traits`.
6. Run RLS checks against a real Supabase project or local Supabase stack.
