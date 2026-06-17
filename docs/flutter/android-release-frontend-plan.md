# FI-YOU Flutter Android Release Frontend Plan

Last updated: 2026-06-17

## Implementation Summary

The current repository does not contain a Flutter project. A new Android-first Flutter app source tree has been started under `mobile/fi_you`.

Scope is the app, not the web landing page:

```text
Onboarding -> Auth -> Today -> Question -> Diary -> U-Map -> Signature -> Next Question -> Settings/Legal/Delete
```

Default architecture:

- Routing: `go_router`
- State: `flutter_riverpod`
- Data boundary: `SelfDiscoveryRepository`
- Supabase adapter: `SupabaseSelfDiscoveryRepository`
- QA fallback: `MockSelfDiscoveryRepository`
- Primary shell tabs: `Today`, `Diary`, `U-Map`, `Signature`, `Settings`

## Created/Changed Files

```text
mobile/fi_you/pubspec.yaml
mobile/fi_you/README.md
mobile/fi_you/lib/main.dart
mobile/fi_you/lib/app/fi_you_app.dart
mobile/fi_you/lib/app/router/app_router.dart
mobile/fi_you/lib/app/navigation/app_shell.dart
mobile/fi_you/lib/app/theme/app_theme.dart
mobile/fi_you/lib/core/config/app_config.dart
mobile/fi_you/lib/core/widgets/app_background.dart
mobile/fi_you/lib/core/widgets/glass_card.dart
mobile/fi_you/lib/core/widgets/screen_state.dart
mobile/fi_you/lib/data/models/fiyou_models.dart
mobile/fi_you/lib/data/repositories/*
mobile/fi_you/lib/features/auth/*
mobile/fi_you/lib/features/onboarding/*
mobile/fi_you/lib/features/today/*
mobile/fi_you/lib/features/questions/*
mobile/fi_you/lib/features/diary/*
mobile/fi_you/lib/features/umap/*
mobile/fi_you/lib/features/signature/*
mobile/fi_you/lib/features/settings/*
mobile/fi_you/lib/features/legal/*
mobile/fi_you/test/app_smoke_test.dart
docs/flutter/android-release-frontend-plan.md
```

## Backend/API Dependencies

Current SQL uses these production names:

- Profile: `public.users`
- Questions: `public.questions`
- Answers: `public.answers`
- Diary: `public.diary`
- U-Map current state: `public.u_map` joined to `public.traits`
- Signature: `public.signatures`

Required backend contracts before release:

```sql
get_my_profile() -> jsonb
upsert_my_profile(display_name text, avatar_url text, timezone text) -> jsonb
get_questions() -> setof question dto
get_next_question() -> question dto
upsert_my_answer(question_id uuid, answer_text text, answer_value jsonb) -> jsonb
get_my_answers() -> setof answer dto
create_my_diary(entry_date date, title text, body text, mood_score smallint, tags text[]) -> jsonb
update_my_diary(id uuid, entry_date date, title text, body text, mood_score smallint, tags text[]) -> jsonb
delete_my_diary(id uuid) -> void
get_my_diaries(from_date date, to_date date) -> setof diary dto
get_my_u_map() -> setof u_map dto
get_current_signature(signature_type text default 'primary') -> jsonb
request_account_deletion(reason text default null) -> jsonb
delete_my_data(confirm_text text) -> jsonb
```

Release blockers for backend:

- Add seed data for `questions` and `traits`.
- Confirm profile bootstrap trigger or formalize Flutter-side upsert.
- Run two-user RLS verification.
- Keep service role keys out of Flutter.
- Decide whether direct table access is acceptable for launch or RPCs are mandatory.

## AI Logic Dependencies

AI Logic must provide UI-safe payloads with no diagnostic, fixed type, accuracy, treatment, therapy, or counseling language.

Required payloads:

```json
{
  "question": {
    "id": "string",
    "prompt": "short Korean string",
    "category": "energyRhythm|emotionAwareness|valuesCompass|decisionStyle|relationshipPattern|stressRecovery|growthMotivation|lifeDirection",
    "choices": [{ "id": "string", "label": "short Korean string", "signalHints": ["string"] }],
    "optionalTextPrompt": "short Korean string",
    "whyThisQuestion": "short Korean string"
  },
  "uMap": {
    "overallClarity": 0,
    "axes": [{ "code": "string", "label": "string", "summary": "short string", "score": 0, "clarity": 0, "flow": "emerging|forming|clearer", "signals": ["string"] }],
    "clearAreas": ["string"],
    "unclearAreas": ["string"],
    "nextQuestionFocus": ["string"]
  },
  "signature": {
    "label": "current-flow name",
    "summary": "short non-diagnostic summary",
    "evidence": ["string"],
    "confidenceNote": "고정된 유형이 아니에요..."
  },
  "nextQuestion": {
    "questionId": "string",
    "axis": "string",
    "areaLabel": "string",
    "question": "short Korean string",
    "choices": [{ "id": "string", "label": "string", "signalHints": ["string"] }],
    "optionalTextPrompt": "string",
    "whyThisQuestion": "string"
  }
}
```

## Product QA Requests

Review these screens and phrases first:

- Auth: `FI-YOU`, `나를 단정하지 않고, 기록을 따라 흐름을 보여줘요.`
- Onboarding: `고정된 유형으로 단정하지 않아요.`
- Today: `오늘의 탐험`, `오늘의 질문`, `U-Map 선명도`
- Question: `가장 가까운 답을 골라주세요.`, `저장하고 Diary에 남기기`
- Diary: `아직 남긴 기록이 없어요`, create/detail/edit/delete flow
- U-Map: `현재 기록에서 보이는 경향이에요.`, `아직 덜 보이는 영역이에요`
- Signature: `현재 기록에서 보이는 흐름이에요.`, `고정된 유형이 아니에요.`
- Settings/Legal: terms, privacy, disclaimer, logout, deletion request

QA must check:

- Android safe-area with gesture navigation and 3-button navigation.
- Back navigation from detail/edit/legal screens.
- Keyboard behavior on auth, question free text, and diary edit.
- Touch targets at least 48 dp.
- Korean text overflow on small Android devices.
- Offline/network failure states for auth, question, diary, U-Map, Signature.
- No paywall or Star UI blocks the core loop.

## Release Build Validation Plan

After Flutter SDK installation:

```powershell
cd mobile\fi_you
flutter create . --platforms=android,ios --org com.fiyou
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

Android release items:

- Confirm `applicationId` as `com.fiyou.app`.
- Configure adaptive icon and splash.
- Configure release signing outside repo.
- Verify AAB on internal testing track.
- Confirm no debug banner, dev endpoint, service role key, or verbose personal-data logging.

## Remaining Risks Before Release

- Flutter SDK is not installed or not on PATH in the current environment, so analyze/test/build could not run yet.
- Android platform folders are not generated until `flutter create .` is run inside `mobile/fi_you`.
- Current Supabase repository still uses some direct table access; RPC contracts should replace this before production hardening.
- Email OTP is a placeholder auth path; confirm Google OAuth/email policy for first Android release.
- Legal text is placeholder copy and needs final Product/Legal approval.
- U-Map and Signature generation are read-only on the client; backend/AI must generate production rows.
