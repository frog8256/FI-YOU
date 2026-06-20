# FI-YOU Supabase Live Contract

Status: P0 handoff for Flutter live repository.

Flutter repository implementation handoff: see `docs/flutter-supabase-repository-mapping.md`.

## Client security boundary

- Android uses only `SUPABASE_URL` and anon/publishable key.
- Android never receives `service_role`, Google Play service account JSON, Paddle webhook secrets, or Edge Function private env values.
- User-owned source records can be written by the authenticated user through RPC/table RLS.
- Derived records are server-written only: `signals`, `u_map_snapshots`, `star_ledger`, `entitlements`.
- Do not use Auth `user_metadata` as the release gate. Launch/onboarding state must come from `profiles` and `get_flutter_launch_state()`.

## Flutter API mapping

| Flutter repository need | Supabase contract |
| --- | --- |
| `restoreSession()` | `supabase.auth.currentSession`, then `rpc('get_flutter_launch_state')` |
| `signInWithGoogle()` | `supabase.auth.signInWithOAuth(Provider.google)` or approved release auth method |
| `signOut()` | `supabase.auth.signOut()` |
| `loadProfile()` | `profiles.select().eq('user_id', auth.uid())`, plus `rpc('get_star_balance')` |
| `upsertProfile(...)` | `rpc('upsert_profile', { p_nickname, p_preferred_language, p_birthday, p_focus_area })` |
| `loadQuestionLoop(questionSet)` | `rpc('get_question_loop_state', { p_question_set })`, then select `questions` and `question_options` by id/set |
| `submitQuestionAnswer(...)` | `rpc('submit_question_answer', { p_question_set, p_question_id, p_selected_option_id, p_optional_text, p_skipped })` |
| `completeOnboarding(...)` | `rpc('complete_onboarding', { p_nickname, p_preferred_language, p_birthday, p_focus_area })` |
| `listDiaries()` | `diaries.select().is('deleted_at', null).order('entry_date', ascending: false)` |
| `saveDiary(...)` | `rpc('upsert_diary', { p_body, p_mood_label, p_title, p_entry_date, p_diary_id, p_metadata })` |
| `deleteDiary(id)` | `rpc('delete_diary_with_star_revoke', { p_diary_id: id })` |
| `loadLatestUMap()` | `rpc('get_latest_u_map')` |
| `hideInsight(...)` | `rpc('save_insight_feedback', { p_target_type, p_target_id, p_action: 'hide' })` |
| `disagreeInsight(...)` | `rpc('save_insight_feedback', { p_target_type, p_target_id, p_action: 'disagree' })` |
| `updateInsightNote(...)` | `rpc('save_insight_feedback', { p_target_type, p_target_id, p_action: 'revise_note', p_note })` |
| `reportInsight(...)` | `rpc('report_ai_output', { p_target_type, p_target_id, p_reason, p_details })` |
| `recordLegalConsent(...)` | `rpc('record_legal_consent', { p_terms_version, p_privacy_version, p_ai_notice_version, p_locale, p_user_agent })` |
| `requestDataExport(...)` | `rpc('request_data_export', { p_metadata })`, then `rpc('get_privacy_request_state')` |
| `requestAccountDeletion(...)` | `rpc('request_account_deletion', { p_reason, p_metadata })`, then `rpc('get_privacy_request_state')` |
| `verifyGooglePlayPurchase(...)` | POST `supabase/functions/v1/verify-google-play-purchase` with user bearer JWT |

## Question answer flow

Flutter must not send answer labels as the source of truth. It must send stable ids:

```json
{
  "p_question_set": "basic_free",
  "p_question_id": "uuid",
  "p_selected_option_id": "uuid",
  "p_optional_text": "optional text",
  "p_skipped": false
}
```

The RPC writes `onboarding_answers` or `answers`. Existing triggers refresh `signals` and `u_map_snapshots`.

## Diary metadata

`upsert_diary` accepts privacy-bounded metadata:

```json
{
  "situation": "max 120 chars",
  "people": "max 80 chars",
  "memorableSentence": "max 180 chars",
  "emotionTags": ["calm", "tired"]
}
```

The backend stores this under `diaries.metadata`. It should not contain contacts, phone numbers, addresses, or third-party sensitive details.

## U-Map eight-axis contract

Backend storage keeps stable English axis keys; Flutter displays `labelKo` from `get_latest_u_map()`.

| axisKey | labelKo |
| --- | --- |
| `self_expression` | 에너지 리듬 |
| `emotional_sensitivity` | 감정 인식 |
| `independence` | 가치 기준 |
| `initiative` | 선택 방식 |
| `relationship` | 관계 흐름 |
| `stability` | 긴장과 회복 |
| `growth` | 성장 동기 |
| `exploration` | 삶의 방향 |

## RLS two-user verification

Run with two real authenticated users:

1. User A inserts profile/onboarding/basic answer/diary through RPC.
2. User B cannot select User A rows from `profiles`, `onboarding_answers`, `answers`, `diaries`, `signals`, `u_map_snapshots`, `star_ledger`, `entitlements`, `insight_feedback`, `ai_report_requests`.
3. User B cannot update/delete User A diary.
4. User A cannot directly insert/update/delete `signals` or `u_map_snapshots`.
5. User A can only see their own privacy request state.
6. Service-role-only `record_star_purchase` cannot execute with anon/authenticated JWT.

## Open questions

- Confirm release auth method: Google-only, email OTP fallback, or both.
- Confirm whether birthday is collected. Current launch gate no longer requires birthday.
- Confirm Google Play product ids and `GOOGLE_PLAY_PRODUCT_MAP` star amounts.
- Confirm whether Store is visible in first release. If visible, Play verification Edge Function deployment/env setup is P0.
- Confirm support operations for `ai_report_requests`, `data_export_requests`, and `account_deletion_requests` status updates.
