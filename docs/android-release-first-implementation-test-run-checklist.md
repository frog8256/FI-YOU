# FI-YOU Android Release First Implementation Test Run Checklist

Date: 2026-06-19
Owner: QA / Android Release Validation Lead
Purpose: Flutter App Lead의 1차 핵심 사용자 플로우 + UI 완성도 구현이 끝난 직후, QA가 바로 실행할 Android 릴리즈 관점 검수 순서표.

Current expected scope:

- First implementation may still use mock/local state for some flows.
- QA must distinguish **UI behavior pass**, **mock/local limitation accepted for this implementation pass**, and **release blocker**.
- Code changes are out of scope for this checklist. This document defines the test run only.

Current release gate after this test run: **Release Hold unless all P0 release blockers below are explicitly cleared or documented as not-in-release-scope.**

Latest pre-run observation on 2026-06-19:

- `flutter test`: passed.
- `flutter analyze`: currently fails because `lib/app/app_bootstrap.dart` references missing `package:fi_you/screens/auth_screen.dart` and `package:fi_you/screens/onboarding_screen.dart`.
- QA should not begin visual/device validation until Flutter App Lead either adds those screens or removes the unresolved imports. This is a first-pass implementation readiness blocker, separate from product release blockers.

## 0. Test Run Setup

### Required Build / Device Matrix

| Item | Required for first implementation QA | Evidence |
| --- | --- | --- |
| Flutter static checks | Run `flutter analyze`. Must pass before UI QA starts. | Terminal log |
| Widget/unit tests | Run `flutter test`. Must pass before UI QA starts. | Terminal log |
| Debug install | Install on Android emulator or device for UI pass. | Device name + screenshot |
| Small screen | 360x640 or similar compact emulator/device. | Screenshots |
| Modern screen | Pixel 7/8 class or similar modern device/emulator. | Screenshots |
| Network controls | Ability to test offline/slow network, or document not available. | Notes |
| Screen recording | Capture full happy path and at least one error/back/keyboard case. | Video path |

### Commands

Run from:

```powershell
cd C:\Users\frog8\Desktop\project\Fi-You\mobile\fi_you
C:\Users\frog8\development\flutter\bin\flutter.bat analyze
C:\Users\frog8\development\flutter\bin\flutter.bat test
```

Optional debug run:

```powershell
C:\Users\frog8\development\flutter\bin\flutter.bat run
```

### Evidence Naming

Use this format for screenshots/videos:

```text
qa-first-pass-YYYYMMDD-##_screen_state_device.png
qa-first-pass-YYYYMMDD-core-flow-device.mp4
```

## 1. Triage Legend

| Result | Meaning |
| --- | --- |
| Pass | Works as expected for this implementation pass. |
| Pass with mock note | UI works, but release dependency is still mock/local/unconnected. |
| P0 | Blocks Play release or blocks core flow. |
| P1 | Must fix before production, can continue first QA if documented. |
| P2 | Polish or later improvement. |

## 2. Release Hold Criteria For This Test Run

Keep **Release Hold** if any item below is true:

- App can enter core personal-data Home without required Auth/Onboarding when Auth/Onboarding is intended for release.
- Auth/Onboarding exists visually but cannot complete into Home.
- Question answer save shows success while data is neither persisted nor clearly marked mock/local.
- Clue/Insight uses forbidden certainty language: 진단, 상담, 치료, 정확도, 고정 유형, 성격유형, 궁합, 진짜 나, 결제하면 더 정확.
- Home Insight Detail lacks user controls: edit/hide/disagree/report or clear placeholder treatment.
- Diary create/edit/delete loses draft unexpectedly or cannot recover from save failure.
- U-Map Axis Detail frames values as personality score, accuracy, diagnosis, or fixed type.
- Store shows mock purchase UI in a production-like path without a clear Google Play Billing 미연동 warning.
- Store enables any non-Play checkout for Android digital goods.
- Settings deletion/logout/legal actions remain mock without clear warning.
- Android back causes data loss without confirmation.
- Small screen, keyboard, safe area, or bottom navigation makes a P0/P1 flow unusable.
- `flutter analyze` or `flutter test` fails.

## 3. Test Run Order

Run in this exact order so failures can be mapped to the user journey.

### Phase A. Build Sanity

| ID | Test | Steps | Expected | Severity if failed |
| --- | --- | --- | --- | --- |
| A1 | Static analysis | Run `flutter analyze`. | No issues found. | P1/P0 if build blocked |
| A2 | Tests | Run `flutter test`. | All tests pass. | P1/P0 if app cannot be trusted |
| A3 | Launch | Install/run app. | App opens without crash or debug visual artifacts beyond debug build indicator. | P0 |
| A4 | Console warnings | Watch terminal during launch. | No repeated runtime exceptions, overflow spam, asset errors. | P1 |

### Phase B. First Launch / Auth / Onboarding / Home Entry

| ID | Test | Steps | Expected | Severity |
| --- | --- | --- | --- | --- |
| B1 | Fresh launch route | Clear app data, open app. | Release-intended first screen appears. If Auth/Onboarding is not implemented, mark P0 release gap but continue UI QA. | P0 release gap |
| B2 | Auth screen visual | If Auth exists, inspect title, CTAs, legal copy, keyboard on email. | No overflow; Korean text readable; Google/email CTA accessible. | P1 |
| B3 | Auth failure/offline | Turn network off, attempt sign-in. | Error is calm; no infinite spinner; user can retry. | P1 |
| B4 | Onboarding complete | Complete display name/questions. | Home opens; user name appears if supported. | P0 if route blocks |
| B5 | Onboarding keyboard | Open keyboard on every text input. | CTA remains visible or scrollable; no bottom nav overlap. | P1 |
| B6 | Home entry | Arrive at Home. | Home primary content loads: greeting, U-Map preview, Insight/Clue, next question, activity. | P0 |
| B7 | Mock/local disclosure | If Home uses mock/local state, inspect disclosure. | Mock/local limitation is visible in internal build or documented as first-pass limitation. | P1/P0 for release |

### Phase C. Home -> Insight Detail

| ID | Test | Steps | Expected | Severity |
| --- | --- | --- | --- | --- |
| C1 | Open Insight Detail | Tap Home `오늘 발견된 단서` / Insight card. | Detail modal/screen opens without layout jump. | P0 if Home exposes clue |
| C2 | Detail content | Read title/body/source area. | Insight is provisional and record-based; no fixed type/diagnosis/accuracy. | P0 |
| C3 | Source evidence | Inspect `기반 데이터` / source section. | Shows what records the clue came from, or clearly says mock source. | P0/P1 |
| C4 | User controls | Tap edit, hide, disagree, report if present. | Action works or shows clear placeholder; no crash. Report action is P0 for release. | P0/P1 |
| C5 | Dismiss/back | Use Android back and drag/close. | Returns to Home; no state corruption. | P1 |
| C6 | Small screen detail | Repeat C1-C5 on small screen. | Modal content scrolls; controls fit. | P1 |

### Phase D. Home/Explore -> Question Answer -> Clue Found -> U-Map Reflection

| ID | Test | Steps | Expected | Severity |
| --- | --- | --- | --- | --- |
| D1 | Home CTA | From Home, tap next question / start explore. | Opens Explore or Question flow. | P0 |
| D2 | Explore CTA | From Explore, tap primary question CTA. | Question Answer Flow opens. | P0 |
| D3 | Choice answer | Select a choice and continue. | Selection visible; can continue. | P0 |
| D4 | Text/mixed answer | Enter long Korean text; continue. | Keyboard usable; text not hidden; validation clear. | P1 |
| D5 | Empty submit | Try continue with missing required input. | Inline error; draft preserved. | P1 |
| D6 | Multi-step progress | Complete all steps. | Progress indicator and labels are readable; no test/diagnosis wording. | P1 |
| D7 | Clue Found | Finish flow. | Shows clue found screen with provisional language. | P0 |
| D8 | U-Map reflection | Tap `U-Map에서 보기` or equivalent. | Navigates to U-Map or shows reflection 안내. | P0 |
| D9 | Back with draft | Start a question, type text, press Android back. | Confirm discard or preserve draft; no silent loss. | P1/P0 if severe |
| D10 | Save failure state | If failure simulation exists, trigger it. | Draft preserved; retry available. If not implemented, mark missing state. | P1 |
| D11 | Offline | Disable network during submit. | No false success unless explicitly mock; state explains limitation. | P1/P0 release |

### Phase E. Diary Home -> Write -> Save -> Detail -> Delete / Empty

| ID | Test | Steps | Expected | Severity |
| --- | --- | --- | --- | --- |
| E1 | Diary Home | Tap bottom nav Diary. | Diary list/home loads; empty or existing state clear. | P0 |
| E2 | Write entry | Open write detail. Enter Korean long body, situation, people, sentence, mood. | Keyboard and scroll are usable. | P1 |
| E3 | Short body validation | Save below minimum. | Error appears; input preserved. | P1 |
| E4 | Save success | Save valid entry. | Save feedback appears; returns to Diary or detail as designed. | P0 |
| E5 | Detail/list presence | Confirm saved entry appears in list/detail. | New entry visible with title, date, mood, preview. | P0 |
| E6 | Edit | Edit saved entry from Diary Home if supported. | Changes persist within current session; release requires backend persistence. | P1/P0 release |
| E7 | Delete | Delete entry. | Confirmation appears before destructive delete; entry removed. | P0 if no confirm for release |
| E8 | Empty state | Delete all entries or use empty account. | Empty state gives first Diary CTA; no broken list. | P1 |
| E9 | Relaunch limitation | Kill/restart app. | If mock/local state resets, limitation is documented; release persistence remains P0. | P0 release gap |
| E10 | Back with unsaved text | Type Diary and press Android back. | Confirm discard or preserve draft. | P1 |

### Phase F. U-Map Detail -> Axis Detail -> Data 부족 상태

| ID | Test | Steps | Expected | Severity |
| --- | --- | --- | --- | --- |
| F1 | Open U-Map | Tap bottom nav U-Map or flow CTA. | U-Map screen opens; graph fits screen. | P0 |
| F2 | Axis grid | Review all axis cards. | 8 axes or release-approved set; Korean labels fit. | P1 |
| F3 | Axis detail | Tap each axis card. | Detail opens with description, record count/source, clue, safety note. | P0 |
| F4 | Data 부족 | Trigger or inspect low-data state. | Explains more records needed; CTA to question/Diary. | P0 |
| F5 | Loading state | Inspect loading placeholder if shown. | Specific loading text; no "진단/분석 중". | P1 |
| F6 | Error/offline state | Trigger if possible. | Retry available; no stale certainty. | P1 |
| F7 | Back/dismiss | Android back from modal/screen. | Returns predictably. | P1 |
| F8 | Copy scan | Read all U-Map text. | No accuracy/fixed type/personality diagnosis wording. | P0 |

### Phase G. Store / Star Mock UI

| ID | Test | Steps | Expected | Severity |
| --- | --- | --- | --- | --- |
| G1 | Open Store | From My/Star or relevant route, open Store. | Store opens without crash. | P1 |
| G2 | Billing disclosure | Inspect top and purchase modal. | Clearly states Google Play Billing is not connected and actual payment is not run. | P0 if mock in production |
| G3 | Package tap | Tap each Star package. | Mock bottom sheet appears; no real non-Play checkout. | P0 if web checkout |
| G4 | Restore mock | Tap restore mock. | Clear mock/unavailable state. | P1 |
| G5 | Purchase copy scan | Read all Store CTAs. | No "더 정확", "진짜 나", "결제해야 계속". | P0 |
| G6 | Back behavior | Android back from Store and bottom sheet. | Returns to My/previous screen. | P1 |
| G7 | Release risk marking | Confirm QA notes mark Store as release hold until Billing connected or hidden. | Required. | P0 release gate |

### Phase H. My / Settings -> Notification / Legal / Data Delete / Logout

| ID | Test | Steps | Expected | Severity |
| --- | --- | --- | --- | --- |
| H1 | Open My | Tap My tab. | Profile/settings screen opens. | P1 |
| H2 | Settings detail | Tap settings row. | Settings detail opens. | P1 |
| H3 | Notification toggles | Toggle daily question and Diary reminder. | Toggle state changes; if not persisted, mock/local limitation documented. | P1 |
| H4 | Legal links | Tap Terms/Privacy. | Opens final document or clear placeholder. Release requires real links. | P0 release |
| H5 | Data delete | Tap data deletion. | Shows scope and confirmation or clear placeholder. Release requires real process. | P0 release |
| H6 | Logout | Tap logout. | For first pass: shows mock if unconnected; release requires session clear and Auth route. | P0 release |
| H7 | Account withdrawal | Tap 탈퇴 if present. | Shows confirmation/scope; release requires deletion path. | P0 release |
| H8 | Back behavior | Android back from Settings to My, then root. | Predictable; no unexpected app exit from nested screen. | P1 |

### Phase I. Global State Cases

| ID | Test | Steps | Expected | Severity |
| --- | --- | --- | --- | --- |
| I1 | Loading coverage | Visit Home, Question, Diary, U-Map, Store, Settings with loading state if supported. | Loading copy is specific and safe. | P1 |
| I2 | Error coverage | Force or inspect error examples. | Retry exists; user input preserved where relevant. | P1 |
| I3 | Offline coverage | Enable airplane mode or disconnect network. | Auth/save/purchase do not show false success. | P0/P1 |
| I4 | Empty coverage | Use new/cleared state or built-in examples. | Empty states guide next action. | P1 |
| I5 | Session expired | If Auth exists, expire/clear session during save. | Re-auth path appears; draft preserved. | P0 |
| I6 | App relaunch | Kill and reopen after Home, question draft, Diary save, Store. | Local/mock limitations are visible; release persistence gaps marked. | P0/P1 |

## 4. Android Visual / Layout Checklist

Run this across Home, Insight Detail, Question Flow, Diary Write, U-Map Axis Detail, Store, Settings.

| Check | Expected | Severity |
| --- | --- | --- |
| 360x640 small screen | No overflow, hidden CTA, clipped bottom nav, or unusable modal. | P1 |
| Keyboard open | Active input remains visible and scrollable. | P1 |
| Status bar safe area | Header/logo not under status bar. | P1 |
| Navigation bar safe area | Bottom nav/CTA not under system nav. | P1 |
| Bottom nav overlap | Scroll content has enough bottom padding. | P1 |
| Long Korean text | Buttons, chips, cards, titles wrap or truncate professionally. | P1 |
| Large font | Core CTAs remain reachable; no severe clipping. | P1 |
| Touch targets | Primary actions and nav are easy to tap. | P2/P1 |
| Modal height | Bottom sheets scroll and do not hide final actions. | P1 |

## 5. Copy Safety Checklist

Fail the test run as P0 if any shipped user-facing core screen uses these outside legal/disclaimer context:

- 진단
- 치료
- 상담
- 처방
- 정확도
- 신뢰도, if used as AI/result quality
- 고정 유형
- 성격유형
- OO형 / OO타입
- 궁합
- 진짜 나
- 정상 / 비정상
- 결제하면 더 정확
- 당신은 이런 사람입니다

Preferred replacements:

- 현재 기록에서 보이는 흐름
- 오늘 발견된 단서
- U-Map에 반영
- 기록이 쌓이면 달라질 수 있어요
- 자기이해 참고 자료
- 아직 데이터가 부족해요

## 6. First-Pass QA Report Template

Use this after completing the run.

```text
Build:
Device(s):
Flutter analyze:
Flutter test:
Network mode:

Summary:
- Overall result:
- Release gate:

Passed:
- 

P0:
- 

P1:
- 

P2:
- 

Mock/local limitations observed:
- 

Screenshots/videos:
- 

Flutter App Lead follow-up:
- 

Supabase/Store/Safety follow-up:
- 
```

## 7. Handoff Criteria After First Implementation QA

### To Flutter App Lead

- Fix all P0 route, layout, back, keyboard, overflow, and draft-loss issues.
- Replace any unsafe copy.
- Make mock/local limitations explicit in internal QA builds.
- Ensure Store mock UI cannot be mistaken for release-ready payment.
- Keep `flutter analyze` and `flutter test` green.

### To Supabase Lead

- Provide live Auth/Onboarding, answer save/load, Diary CRUD, U-Map/Insight data, deletion path.
- Provide session-expired and offline failure behavior contracts.
- Provide RLS evidence once live data is connected.

### To Store Lead

- Either hide Store in production or connect Play Billing.
- Provide product ID parity, purchase pending/cancel/failure/restore test plan.
- Ensure no entitlement is granted before server verification.

### To Safety Lead

- Review Home Insight, Clue Found, U-Map Axis Detail, Diary feedback, Store copy, Settings legal copy.
- Confirm AI limitation/reporting path is present or explicitly marked as release-blocking.

## 8. Final First-Pass Release Gate

First implementation can proceed to broader QA only if:

- `flutter analyze` passes.
- `flutter test` passes.
- Happy path from first launch to Home to Question to Clue to U-Map is navigable.
- Diary write/save/delete path is navigable and failure handling preserves input.
- Insight and U-Map copy remains safe.
- Store mock state is clearly marked as Google Play Billing not connected.
- Settings legal/delete/logout gaps are documented as release hold.
- Android small-screen, keyboard, safe-area, back, and bottom-nav checks have no P0/P1 blocking usability failure.

Production remains **Release Hold** until Auth/Onboarding, Supabase persistence/RLS/deletion, Google Play Billing if Store is visible, AI report path, and final Play Console evidence are complete.
