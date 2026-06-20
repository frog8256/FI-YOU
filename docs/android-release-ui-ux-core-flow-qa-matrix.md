# FI-YOU Android Release UI/UX + Core Flow QA Matrix

Date: 2026-06-19
Owner: QA / Android Release Validation Lead
Scope: Android official release QA for UI/UX, core user flow, Android behavior, Play review risk, and cross-lead handoff criteria
Current build assumption: Flutter screen skeleton exists, but the app is still mock-centered. Auth/Onboarding, Supabase live connection, Insight detail persistence, U-Map evidence detail, Google Play Billing, and Settings real actions are not yet release-complete.

Current release decision: **Release Hold**

## 1. QA Principles

FI-YOU release QA is not MVP smoke QA. Production approval requires the user to complete the self-discovery loop on a real Android install, with live backend behavior, safe language, and Play-compliant privacy/payment handling.

Core release loop:

1. First launch and Auth.
2. Onboarding.
3. Home.
4. Explore question answer.
5. Clue discovery.
6. Diary write/edit/delete.
7. U-Map detail and evidence.
8. Insight detail and user controls.
9. Store/Star, if visible.
10. My/Settings, legal, deletion, logout.

Language guardrail:

- Allowed: 기록, 단서, 흐름, 반영, 현재 기록, 선명도, 참고 자료, 달라질 수 있음.
- Blocked: 진단, 상담, 치료, 처방, 정확도, 고정 유형, 성격유형, 궁합, 진짜 나, 정답, 정상/비정상, 결제하면 더 정확.

## 2. Current Implementation Readiness Snapshot

| Area | Current observed state | Release QA judgment |
| --- | --- | --- |
| App entry | `MaterialApp` opens `AppShell` directly. No Auth or Onboarding gate is present in current screen skeleton. | P0 gap for official release if accounts/personal data are required. |
| Navigation | `IndexedStack` tabs: Home, Diary, Explore, U-Map, My. Store and Settings open via pushed routes. | Good skeleton, but Android back behavior and deep flow restoration need testing. |
| Home | Mock Home UI exists with U-Map card, today clue, next question, activity. | Needs live data, empty/loading/error/session states, and copy review. |
| Explore / Question | Explore launches `QuestionFlowScreen`; answers are local mock state. | Needs Supabase save, offline/session handling, and clue generation pipeline. |
| Clue discovery | Result screen and Home modal show mock clues and controls. | Needs persisted insight detail, source evidence, report/feedback route. |
| Diary | Local in-memory create/edit/delete exists; detail write screen exists. | Needs Supabase CRUD, deletion confirmation, offline/save recovery, app restart persistence. |
| U-Map | Mock graph, axis cards, modal detail, loading/error/empty examples exist. | Needs live 8-axis data, evidence sources, low-data behavior, no accuracy framing. |
| Store/Star | Store is explicitly mock and says Google Play Billing is not connected. | P0 if Store is visible in production without real Billing. |
| My/Settings | Mock settings, deletion/download/logout/legal placeholders. | P0 until real privacy/legal/deletion/logout/session handling is connected. |
| Supabase | Current `pubspec.yaml` has no Supabase dependency in this skeleton. | P0 backend integration gap. |
| Billing | Current `pubspec.yaml` has no `in_app_purchase` dependency in this skeleton. | P0 if paid features ship or Store remains visible. |

## 3. Android Release QA Full Checklist

### Build And App Identity

| Check | Acceptance criteria | Severity if failed | Evidence |
| --- | --- | --- | --- |
| Package name | Final AAB uses `com.fiyou.app`. | P0 | AAB inspection / Play upload metadata |
| App name | Launcher and Play listing show `FI-YOU`. | P0 | Device screenshot |
| Release build | No debug banner, no mock-only copy, no local-only fake data in production. | P0 | Release install video |
| Versioning | `versionName` and `versionCode` match release plan and increment per upload. | P0 | Build log |
| Target API | Meets current Google Play target API requirement. | P0 | Gradle config / Play Console |
| Analyzer/test | `flutter analyze` and `flutter test` pass on final release branch. | P1 | Terminal log |

### UI/UX Release Quality

| Check | Acceptance criteria | Severity if failed | Evidence |
| --- | --- | --- | --- |
| Korean rendering | No mojibake, clipped Hangul, mixed broken encoding, or awkward button truncation. | P0/P1 | Screenshots |
| Small screen | 360x640-class layout has no overflow, clipped CTA, or bottom nav overlap. | P1 | Device screenshots |
| Large text | Android font size large does not break key flows. | P1 | Screenshots |
| Keyboard | Text inputs remain visible; primary CTA can be reached. | P1 | Screen recording |
| Safe area | Status/nav bars do not cover content or bottom nav. | P1 | Device screenshots |
| Back button | System back exits/dismisses/returns predictably and preserves drafts. | P1 | Screen recording |
| App restart | Session, saved records, and unfinished purchase/answer states recover correctly. | P0/P1 | Screen recording |

### Product Safety

| Check | Acceptance criteria | Severity if failed | Evidence |
| --- | --- | --- | --- |
| No diagnostic framing | No screen implies diagnosis, therapy, counseling, treatment, or mental health assessment. | P0 | Copy scan |
| No fixed type | No "OO형", "성격유형", "당신은 이런 사람" framing. | P0 | Copy scan |
| No accuracy claim | No "정확도", "더 정확한 분석", "신뢰도" as result quality. | P0 | Copy scan |
| Paid copy safe | Paid features do not promise better truth, diagnosis, or required progress. | P0 | Store screenshots |
| AI limitation | AI/insight screens explain output can be incomplete and record-based. | P0 | Screenshots |
| Report/feedback | Harmful/inaccurate AI-generated content can be reported in-app. | P0 | Flow evidence |

### Data / Supabase

| Check | Acceptance criteria | Severity if failed | Evidence |
| --- | --- | --- | --- |
| Auth | Sign-in, sign-out, session restore, expired session, and account state work. | P0 | Test account video |
| Data persistence | Answers, Diary, U-Map, Insight, Star, and Settings data persist after restart. | P0 | DB and app evidence |
| RLS isolation | User A cannot read/write/delete User B data. | P0 | Two-user RLS test |
| Deletion | User can request or execute account/data deletion. Post-deletion access is denied. | P0 | DB and app evidence |
| Offline/retry | Failed saves preserve user input and retry safely. | P1 | Screen recording |

### Store / Billing

| Check | Acceptance criteria | Severity if failed | Evidence |
| --- | --- | --- | --- |
| Play Billing only | Android digital goods use Google Play Billing only. No Paddle/web checkout. | P0 | Code scan / screenshots |
| Product loading | Product IDs load from Play Console with Play-provided prices. | P0 | Internal test device |
| Purchase success | Server verifies token before Star/report entitlement. | P0 | Backend log |
| Pending/cancel/fail | No entitlement is granted before verified purchase. | P0 | Billing test log |
| Restore | Purchases restore after reinstall/new device without duplicate grants. | P0 | Internal test evidence |
| Refund/revoke | Revocation process is documented and tested where possible. | P1 | Backend/process evidence |

## 4. Core User Flow QA Scenarios

### 4.1 First Launch / Auth / Onboarding

| Scenario | Steps | Expected result | Severity |
| --- | --- | --- | --- |
| Fresh install opens Auth | Install release build, open app. | User sees Auth, not mock Home. No debug/mock language. | P0 |
| Google sign-in success | Tap Google login, complete account picker, return to app. | Session created, profile bootstrap succeeds, onboarding gate opens if incomplete. | P0 |
| Email/OTP flow if shipped | Enter valid email, complete OTP/magic link. | Session is established and deep link returns to app. | P0 |
| Auth cancel | Start Google login, cancel. | App returns to Auth with calm retry copy; no crash. | P1 |
| Auth failure/offline | Disable network and attempt login. | Error is understandable; no infinite spinner. | P1 |
| Onboarding complete | Enter display name, complete required prompts. | Profile saved to Supabase; Home opens with user name. | P0 |
| Onboarding keyboard | Open keyboard on name field/small screen. | CTA remains reachable; no overflow. | P1 |
| Onboarding restart | Kill app mid-onboarding and reopen. | Session and onboarding state recover correctly. | P1 |

Release blockers:

- App opens directly into mock Home for new user.
- Onboarding completion is local only.
- Session restore fails after restart.
- OAuth redirect does not return to app.

### 4.2 Home

| Scenario | Steps | Expected result | Severity |
| --- | --- | --- | --- |
| Home with live data | Login after onboarding. | Home shows user-specific next question, U-Map preview, clue/Insight, Diary/activity counts, Star balance. | P0 |
| Home low-data | New account with no records. | Clear empty states; primary action starts first question. | P0 |
| Home loading | Simulate slow API. | Skeleton/loading copy appears; no layout jump or stuck spinner. | P1 |
| Home error/offline | Disable network. | Retry state appears; cached data behavior is clear. | P1 |
| Home clue tap | Tap `오늘 발견된 단서`. | Insight detail opens with source evidence and controls. | P0 if clue visible |
| Home next question | Tap `질문 시작하기`. | Opens Explore/Question flow and back behavior works. | P0 |
| Home copy review | Scan Home text. | No diagnosis, accuracy, fixed type, or payment pressure. | P0 |

Special current-code risk:

- Home has mock counts, mock Star, mock clue, and "분석 업데이트" style activity copy. Before release, replace or justify with safe wording such as "U-Map 반영".

### 4.3 Explore Question Answer

| Scenario | Steps | Expected result | Severity |
| --- | --- | --- | --- |
| Choice question | Select one option, continue/save. | Answer saves to backend and appears in clue feedback. | P0 |
| Text question | Enter valid text and continue. | Minimum text rule is clear and not punitive. | P1 |
| Mixed question | Select option plus short reason. | Both structured and free text data save. | P0 |
| Empty submit | Tap continue without required input. | Inline error appears; draft preserved. | P1 |
| Slow save | Throttle network and submit. | Button shows saving state, duplicate submit blocked. | P1 |
| Save failure | Force API failure. | Draft remains; user can retry. | P0 |
| Session expired | Expire token and submit. | User is prompted to sign in again; draft is preserved. | P0 |
| Back during draft | Press Android back. | User confirms discard or draft is preserved. | P1 |

Release blockers:

- Answers are only in memory.
- Save success appears before backend confirmation.
- "분석 완료", "정확도", "유형 확정" appears after save.

### 4.4 Clue Discovery

| Scenario | Steps | Expected result | Severity |
| --- | --- | --- | --- |
| Post-answer clue | Complete final question step. | Shows provisional clue: "현재 기록에서 보이는 흐름". | P0 |
| Source evidence | Open clue detail. | Shows source answer/Diary/date/axis relation. | P0 |
| User disagrees | Tap `동의하지 않음`. | Feedback is stored; clue is deprioritized or marked. | P1 |
| Hide clue | Tap `숨기기`. | Home no longer highlights clue; source record remains. | P1 |
| Edit/correction | Tap `수정하기`. | User can edit source record or add correction note. | P1 |
| Report AI content | Tap report/feedback for unsafe output. | Report goes to moderation/support queue. | P0 |

Release blockers:

- Clue appears with no evidence.
- User cannot report harmful/inaccurate AI output.
- Clue copy defines the user or claims certainty.

### 4.5 Diary Write / Edit / Delete

| Scenario | Steps | Expected result | Severity |
| --- | --- | --- | --- |
| Create Diary | Write body, choose mood/tag, save. | Entry saves to Supabase and appears in list after restart. | P0 |
| Minimum text validation | Try saving too-short body. | Clear helper text; draft preserved. | P1 |
| Edit Diary | Edit existing entry and save. | Updated record persists after restart. | P0 |
| Delete Diary | Delete entry with confirmation. | Entry removed from app/backend; linked U-Map recalculates or marks stale. | P0 |
| Cancel delete | Open delete confirmation, cancel. | Record remains unchanged. | P1 |
| Offline save | Disable network and save. | User sees queued/retry or failure with draft preserved. | P1 |
| Keyboard/small screen | Edit long body on small screen. | Text area and CTA remain usable. | P1 |
| Back with unsaved draft | Press Android back. | Confirm discard or preserve draft. | P1 |

Release blockers:

- Diary records are only in memory.
- Deletion has no confirmation or backend effect.
- Stored Diary from another user is visible.

### 4.6 U-Map Detail

| Scenario | Steps | Expected result | Severity |
| --- | --- | --- | --- |
| New user low-data | Open U-Map before records. | Low-data state explains how to start. | P0 |
| Live data | Complete answers/Diary and open U-Map. | 8 axes reflect backend data; counts/evidence match source records. | P0 |
| Axis detail | Tap each axis card. | Detail modal/screen shows label, description, record count, recent source, representative clue. | P0 |
| Locked/paid area | Open locked Growth/Relation map. | If visible, copy is safe and does not imply better accuracy. | P1/P0 if paid |
| Loading/error | Simulate API delay/failure. | Specific loading/error state appears and retry works. | P1 |
| Copy scan | Scan every axis. | No fixed type, diagnosis, score-as-accuracy, normal/abnormal. | P0 |

Release blockers:

- U-Map shows mock snapshot in production.
- Axis progress is labeled as accuracy/reliability.
- U-Map lacks source evidence or low-data fallback.

### 4.7 Insight Detail

| Scenario | Steps | Expected result | Severity |
| --- | --- | --- | --- |
| Open Insight from Home | Tap insight/clue card. | Detail opens with title, body, data basis, U-Map linkage. | P0 |
| Evidence visibility | Review source section. | Only the user's own records are shown. | P0 |
| Controls | Test edit/hide/disagree/report. | Each action works or is clearly disabled before release. | P0/P1 |
| Unsafe content report | Report harmful or inaccurate AI output. | Report confirmation and backend/support record exist. | P0 |
| Back/dismiss | Dismiss bottom sheet or press back. | Returns to prior screen with no state loss. | P1 |

Release blockers:

- Insight detail is a static mock only.
- No report/feedback action for AI-generated content.
- Evidence leaks another user's content.

### 4.8 Store / Star

| Scenario | Steps | Expected result | Severity |
| --- | --- | --- | --- |
| Store visible in production | Open Store. | Real Google Play product loading or safe unavailable state. No mock purchase CTA. | P0 |
| Product details | Load product list. | Product IDs and prices come from Play Billing. | P0 |
| Purchase success | Buy Star/report product with license tester. | Backend verifies token; Star/entitlement appears once. | P0 |
| Cancel/failure | Cancel or decline purchase. | No entitlement; calm retry state. | P0 |
| Pending | Use pending purchase test path. | No entitlement until purchased. | P0 |
| Restore | Reinstall and restore. | Existing entitlements restore without duplicate Star grants. | P0 |
| Store copy | Scan all CTAs. | No "more accurate analysis" or payment-gated core loop. | P0 |

Release blockers:

- Store remains mock in production.
- Android digital goods link to web/Paddle checkout.
- Client grants Star before server verification.

### 4.9 My / Settings

| Scenario | Steps | Expected result | Severity |
| --- | --- | --- | --- |
| Profile | Open My/Settings. | Shows real signed-in user and app version. | P1 |
| Notification toggles | Toggle reminders. | Runtime permission and setting persistence behave correctly if notifications ship. | P1 |
| Privacy link | Tap privacy policy. | Final policy opens without login. | P0 |
| Terms link | Tap terms. | Final terms open without login. | P0 |
| AI limitation | Open AI limitation/disclaimer. | Explains FI-YOU is not diagnosis, counseling, treatment, emergency support. | P0 |
| Data deletion | Request data deletion. | User sees scope, confirmation, and request/execution result. | P0 |
| Account deletion | Delete account or request deletion. | Backend process starts/completes; session signs out; data inaccessible. | P0 |
| Logout | Tap logout. | Session clears and app returns to Auth. | P0 |

Release blockers:

- Settings legal/deletion/logout remain mock.
- Privacy/terms/deletion URL missing from Play Console.
- Deletion copy implies immediate deletion when only a request is created.

## 5. Screen State Test Matrix

| Screen | Empty | Loading | Error | Offline | Session expired |
| --- | --- | --- | --- | --- | --- |
| Auth | No account state is normal; show sign-in methods. | Show login progress and block duplicate taps. | Show provider-specific error safely. | Explain connection issue. | If session invalid, return to Auth. |
| Onboarding | New user starts with blank fields. | Saving profile shows progress. | Preserve entered name/answers. | Preserve draft; retry. | Re-auth then resume onboarding. |
| Home | New user sees first-question CTA. | Skeleton or calm "records loading". | Retry and avoid broken cards. | Use cached data only if clearly marked. | Return to Auth with no data loss. |
| Explore/Question | No question: guide to Diary or retry. | Question loading state. | Preserve draft. | Preserve draft; no false save. | Re-auth and restore draft. |
| Clue discovery | No clue: explain low data. | "단서를 정리하는 중". | No fabricated clue; retry. | Show source unavailable state. | Re-auth before showing personal clue. |
| Diary | No entries: first Diary CTA. | List/detail loading. | Preserve edit state. | Draft preserved or queued. | Re-auth and return to draft/list. |
| U-Map | Low-data U-Map state. | Axis/snapshot loading. | Retry; no stale certainty. | Show cached/limited state. | Re-auth before personal map. |
| Insight detail | Missing insight: fallback and Home. | Detail/evidence loading. | Retry and hide unsafe partial output. | No source evidence leak. | Re-auth before detail. |
| Store/Star | No products: unavailable/retry. | Product loading. | Billing error with help/retry. | Disable purchase CTA. | Re-auth before entitlement display. |
| My/Settings | Signed-out redirect. | Settings/profile loading. | Retry or support path. | Legal links may still open if web available. | Return to Auth. |

## 6. Android-Specific QA Matrix

| Area | Test cases | Acceptance criteria | Severity |
| --- | --- | --- | --- |
| Small screen | 360x640, 393x851, compact emulator. | No RenderFlex overflow, clipped nav, hidden CTA, unreadable charts. | P1 |
| Keyboard | Auth, onboarding, question text, Diary, Settings deletion reason. | Keyboard does not cover active field or required CTA. | P1 |
| Back button | Root tabs, pushed Store/Settings, bottom sheets, question draft, Diary draft, purchase sheet return. | Predictable navigation; destructive exits confirm. | P1 |
| Safe area | Gesture nav, 3-button nav, display cutout, landscape if supported. | Content and bottom nav avoid status/nav bars. | P1 |
| App relaunch | Cold start, warm resume, kill during draft, kill during purchase verification. | Session and data recover; unfinished actions are safe. | P0/P1 |
| Slow network | 2G/3G throttle for save/load/purchase. | No duplicate submit; clear progress and retry. | P1 |
| Network loss | Disable during save/purchase/auth. | No false success; input/token recoverable. | P0 |
| Large font | Android display/font size large. | Critical Korean copy and CTAs fit. | P1 |
| Accessibility | Touch targets, semantics labels, contrast. | Main actions are discoverable and tappable. | P1 |

Minimum device matrix:

- Small/low-end Android phone, API 26-29 if supported.
- Modern Android phone, API 34-36.
- Play Store emulator image signed in as license tester.
- Optional Samsung device with gesture navigation.

## 7. Play Store Review Risk Matrix

| Risk | Why it matters | Severity | Required mitigation |
| --- | --- | --- | --- |
| Mock app submitted | Production build exposes mock data, mock Store, mock legal actions, or direct Home without Auth. | P0 | Release build must use live backend or safe unavailable states; no mock purchase flow. |
| User data/Data Safety mismatch | App collects answers, Diary, AI insights, auth IDs, billing data but Play form/privacy policy does not match. | P0 | Complete data inventory and align Data Safety + privacy policy. |
| Missing account deletion | Account-based app must provide deletion path and Play Console deletion URL. | P0 | In-app deletion/request and public deletion URL with evidence. |
| AI-generated content reporting missing | AI insight surfaces need user reporting/feedback path for unsafe/inaccurate content. | P0 | Add report action and backend/support handling. |
| Health/medical/counseling implication | Self-discovery copy can be mistaken for mental health diagnosis/counseling. | P0 | Avoid forbidden copy; include AI limitation/non-medical disclaimer. |
| Billing policy violation | Android digital goods use non-Play checkout or grant entitlement before verification. | P0 | Use Google Play Billing only; server verification required. |
| Closed testing requirement not met | New personal developer accounts may need defined closed testing. | P0 | Prepare tester list, 14-day plan if applicable, evidence. |
| Store screenshots not matching app | Play listing screenshots show future/non-current UI. | P1 | Capture screenshots from final release build only. |
| App access missing | Reviewers cannot login or reach gated features. | P0 | Provide reviewer account and instructions. |
| Target API / technical quality | Build does not meet Play requirements or crashes in pre-launch report. | P0 | Confirm target SDK, AAB, pre-launch report, crash/ANR. |

Official references checked on 2026-06-19:

- Google Play target API level: https://developer.android.com/google/play/requirements/target-sdk
- Google Play Data Safety: https://support.google.com/googleplay/android-developer/answer/10787469
- Google Play AI-generated content policy: https://support.google.com/googleplay/android-developer/answer/14094294
- Google Play Payments policy: https://support.google.com/googleplay/android-developer/answer/10281818
- New personal developer account testing requirements: https://support.google.com/googleplay/android-developer/answer/14151465

## 8. Release Hold P0 / P1 / P2 Criteria

### P0 - Release Blockers

- App starts without required Auth/Onboarding for account-based personal data.
- Supabase live save/load/delete is missing for answers and Diary.
- RLS isolation is not proven for user-owned data.
- Account deletion/data deletion path is missing or only mock.
- Google Play Billing is not live-verified while Store/paid digital goods are visible.
- Android app uses web checkout/Paddle for digital goods.
- Star/report entitlement can be granted without server verification.
- AI insight report/feedback path is missing.
- Shipped copy implies diagnosis, counseling, treatment, exact accuracy, fixed type, or compatibility.
- Privacy, terms, deletion URL, Data Safety, app access, or AI declaration is missing/mismatched.
- Final production AAB is not built/uploaded/installed through Play internal testing.

### P1 - Must Resolve Before Production, May Enter Internal QA With Owner Approval

- Small-screen or large-font layout issues in non-blocking secondary views.
- Back navigation surprises that do not cause data loss.
- Non-critical empty/error states are generic but functional.
- Store screenshots/listing copy not final.
- Notification settings are mock while notifications are not shipped.
- Performance jank in U-Map graph that does not block use.
- Missing analytics/crash monitoring if PM accepts manual launch monitoring temporarily.

### P2 - Post-Launch / Cleanup

- Minor visual polish.
- Advanced insight edit UX.
- U-Map history timeline.
- Data export if deletion path is already compliant.
- Rich report formatting.
- Accessibility refinements beyond core tap targets/contrast/labels.
- Flutter path/dev-machine convenience tasks.

## 9. QA Matrix For Flutter App Lead

| Deliverable | Flutter acceptance criteria | QA evidence |
| --- | --- | --- |
| Auth/Onboarding gate | New user cannot bypass to mock Home; session restore works. | Fresh install video |
| Home live state | Replaces mock counts/clues/Star with repository state and empty/loading/error states. | Screenshots under data states |
| Question flow | Saves through repository; preserves draft on error/back; no duplicate submit. | Slow/offline save video |
| Clue detail | Shows source evidence, edit/hide/disagree/report controls. | Interaction video |
| Diary CRUD | Create/edit/delete with confirmation and persistence after restart. | App restart video |
| U-Map detail | 8 axes, evidence, low-data, loading, error; no accuracy wording. | Axis screenshots |
| Store | Production Store disabled unless Play Billing is connected; no mock CTA in release. | Release screenshot |
| Settings | Real legal links, logout, deletion/request flow, app version. | Settings flow video |
| Android UX | Small screen, keyboard, safe area, back, relaunch pass. | Device matrix report |

Flutter release test commands:

```powershell
cd C:\Users\frog8\Desktop\project\Fi-You\mobile\fi_you
C:\Users\frog8\development\flutter\bin\flutter.bat analyze
C:\Users\frog8\development\flutter\bin\flutter.bat test
C:\Users\frog8\development\flutter\bin\flutter.bat build appbundle --release `
  --dart-define=APP_ENV=production `
  --dart-define=SUPABASE_URL=<production-url> `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<production-key>
```

## 10. QA Matrix For Supabase Lead

| Deliverable | Supabase acceptance criteria | QA evidence |
| --- | --- | --- |
| Auth | Google/email auth, session restore, expired-token handling. | Test account logs |
| Profile/onboarding | Profile and onboarding state persist per user. | DB rows |
| Answers | Create/read answer by current user; cross-user denied. | Two-user RLS test |
| Diary | CRUD with owner-only policies and deletion evidence. | DB + app video |
| U-Map | Snapshot/axis data generated from user records. | Before/after records |
| Insight | Insight stores source evidence and user feedback controls. | DB rows |
| Deletion | Request or immediate deletion is implemented and documented. | Deletion runbook/log |
| Data Safety | Data inventory includes auth, answers, Diary, insights, billing, logs, AI provider. | Data inventory sheet |

Required two-user RLS test:

- User A creates answer, Diary, U-Map/Insight data.
- User B attempts direct/API read and write.
- Expected: denied or empty result.
- User A deletes account/data.
- Expected: personal records removed or queued per policy; old session cannot access data.

## 11. QA Matrix For Store Lead

| Deliverable | Store acceptance criteria | QA evidence |
| --- | --- | --- |
| Product IDs | Play Console, Flutter constants, backend allowlist match exactly. | Product parity table |
| Product details | Prices/titles come from Play Billing. | Internal test screenshot |
| Purchase verify | Backend verifies Google token before granting. | Function logs |
| Star ledger | Star grants are idempotent and auditable. | Ledger rows |
| Report entitlement | Paid reports unlock once and restore correctly. | DB + UI evidence |
| Pending/cancel/fail | No grant until verified purchased state. | Billing test logs |
| Restore | Reinstall/new device restores active entitlements only. | Screen recording |
| Refund/revoke | Revocation handling and support process documented. | Runbook |

Store production rule:

- If Play Billing is not complete, Store must be hidden or shown as unavailable in production. A mock purchase bottom sheet is a P0 blocker.

## 12. QA Matrix For Safety Lead

| Deliverable | Safety acceptance criteria | QA evidence |
| --- | --- | --- |
| Copy scan | No forbidden terms outside disclaimers/legal context. | Copy export |
| AI limitation | Visible near insight/U-Map/report surfaces. | Screenshots |
| Report action | User can report unsafe/inaccurate AI output. | Report flow video |
| Insight tone | Uses provisional, record-based language. | Sample review |
| Relationship safety | Does not judge other person, predict future, or imply compatibility. | Sample review |
| Paid safety | Paid reports do not imply better accuracy or truth. | Store/report copy |
| Crisis fallback | If free text can trigger unsafe content, fallback is documented and tested. | Safety test log |

Minimum safety copy:

> FI-YOU의 U-Map과 단서는 현재까지의 답변과 Diary 기록을 바탕으로 한 자기이해 참고 자료입니다. 고정된 유형이나 진단이 아니며, 앞으로의 기록에 따라 달라질 수 있습니다.

## 13. PM Launch Gate

Current gate: **Release Hold**

Move to internal testing only when:

- Auth/Onboarding exists and is connected.
- Supabase live core loop works for one real test user.
- Diary CRUD persists after restart.
- U-Map/Insight detail has real data or safe low-data states.
- Settings legal/deletion/logout are not mock.
- Store is hidden/unavailable unless Play Billing is ready.
- `flutter analyze` and `flutter test` pass.
- No P0 safety copy appears.

Move to closed testing only when:

- Internal testing completes core loop on Play-installed build.
- Two-user Supabase/RLS/deletion evidence is captured.
- Billing sandbox/internal purchases pass if Store is visible.
- Play Console forms, links, app access, and screenshots are final.
- Android small-screen/keyboard/back/safe-area/network matrix passes.

Move to production only when:

- No P0 remains.
- P1 list is either resolved or explicitly accepted by PM/Release/Safety.
- Final AAB hash, release notes, screenshots, reviewer credentials, support path, rollback/hotfix plan, and post-launch monitoring are recorded.

