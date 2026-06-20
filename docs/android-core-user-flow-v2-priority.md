# FI-YOU Android Core User Flow v2 Priority

Last updated: 2026-06-19

Owner: Product Concept & UX Flow Lead

Audience:

- PM
- Flutter App Lead
- UI/QA
- Backend
- Store/Billing
- Safety

Goal:

Define the next implementation round so FI-YOU feels like record-based self-discovery, not diagnosis, typing, testing, counseling, or paid self-analysis.

## 1. v2 Product Rule

The user-facing app must always communicate:

- 질문은 무료 핵심 탐구 흐름이다.
- Diary는 짧아도 기록이 된다.
- U-Map은 현재 기록에서 보이는 흐름이다.
- Insight는 AI의 최종 판단이 아니라 사용자가 검토하고 수정/숨김/신고할 수 있는 단서다.
- Store/Star는 핵심 루프 밖의 선택 기능이다.
- Settings는 실제 법무/개인정보/삭제/탈퇴 통제 화면이다.

Forbidden v2 impressions:

- 질문을 시작하려면 Star가 필요하다.
- 결제하면 더 정확한 나를 알 수 있다.
- U-Map 축이 성격/심리 진단처럼 보인다.
- 답변 후 사용자가 다음 행동을 모른다.
- 앱을 재실행하면 세션이 사라져 Auth로 돌아간다.
- 개인정보/삭제/탈퇴가 준비중으로만 보인다.

## 2. Core User Flow v2

### Flow Map

`First Launch -> Auth -> Onboarding -> Home -> Explore -> Question -> Clue Found -> Diary / U-Map -> Insight Detail -> Settings`

### 1. First Launch

User sees:

- FI-YOU identity
- record-based self-discovery positioning
- login entry
- terms/privacy links

Expected feeling:

- "내 기록을 안전하게 쌓는 앱이구나."

Must not show:

- Store
- Star purchase
- analysis result
- personality type language

### 2. Auth

v2 requirement:

- Mock login may remain only for internal/dev build.
- Release build must support real Auth or a clearly release-approved account path.
- Session must persist after app restart.

Primary CTA:

- `Google로 계속하기` or release-approved sign-in method

Secondary:

- `이용약관`
- `개인정보처리방침`

P0:

- Reopening app after completed onboarding must go to Home, not Auth.

### 3. Onboarding

v2 requirement:

- Short expectation setting:
  - Question
  - Diary
  - U-Map
  - non-diagnostic caveat
- Complete onboarding once and persist state.

Primary CTA:

- `첫 질문으로 시작하기`

Safe copy:

- `FI-YOU는 사람을 단정하지 않고, 남긴 기록에서 현재 보이는 단서와 흐름을 보여줍니다.`

### 4. Home

v2 role:

- Home is the loop hub, not a store dashboard.

Priority order:

1. Next Question
2. Today Clue
3. U-Map current state
4. Diary shortcut
5. My / Settings
6. Reports / Store as tertiary

Primary CTA:

- `오늘 질문 시작`

Secondary:

- `Diary 쓰기`
- `U-Map 보기`
- `오늘 발견된 단서 보기`

P0:

- Remove fake or hardcoded-looking progress in release mode.
- Remove any question/Explore Star cost from Home.
- Prevent bottom nav overlap with scroll content and sticky CTAs.

### 5. Explore

v2 role:

- Explore is a free question entry surface.

Primary CTA:

- `오늘 질문 시작하기`

Secondary:

- `다른 질문 보기`
- `Diary 먼저 쓰기`

P0:

- Remove Star price badges from question cards.
- Remove Star deduction history for starting questions.
- If Star is shown, explain it belongs to optional expanded features only.

Safe copy:

- `질문은 정답을 찾는 과정이 아니라 오늘의 단서를 남기는 기록입니다.`

### 6. Question

v2 role:

- Capture choice/text/mixed answer.
- Keep it reflective, not test-like.

Primary CTA:

- `답변 저장`

Validation:

- Choice: one option
- Text: allow short answer; do not over-require length
- Mixed: choice required, reason optional or lightly required

P0:

- Save failure preserves input.
- Back with draft asks before discard.

### 7. Question Complete / Clue Found

v2 role:

- Confirm answer saved.
- Show a safe clue.
- Give a clear next step.

Primary CTA:

- `Diary에 이어쓰기`

Secondary CTAs:

- `U-Map 반영 보기`
- `다른 질문 이어가기`
- `홈으로`

Required message:

- `오늘의 답변이 단서로 저장됐어요.`
- `이 단서는 U-Map에 조용히 반영됩니다.`
- `앞으로의 기록에 따라 달라질 수 있어요.`

P0:

- Diary CTA must be present after answer completion.

### 8. Diary

v2 role:

- Let the user add context with low writing pressure.

Primary CTA:

- `Diary 저장`

P0:

- Remove hard 50-character minimum.
- Accept short entries.
- If quality guidance is needed, use helper text, not blocking validation.

Recommended validation:

- Minimum: non-empty body OR at least one mood tag + short note.
- Better: allow draft or "짧은 기록 저장".

Safe copy:

- `한 문장도 단서가 될 수 있어요.`

Privacy copy for people field:

- `실명 대신 관계나 상황만 적어도 괜찮아요.`

### 9. U-Map

v2 role:

- Show 8 axes as record-based flows.
- Explain source records.
- Avoid clinical or fixed-trait language.

P0 axis language:

Use these 8 axes:

1. 에너지 리듬
2. 감정 인식
3. 가치 기준
4. 선택 방식
5. 관계 흐름
6. 긴장과 회복
7. 성장 동기
8. 삶의 방향

Replace:

- `불안 신호` -> `긴장과 회복`
- `몰입 패턴` -> only if approved; otherwise align to one of 8 axes
- `성장 단서` -> `성장 동기`

P0:

- Low-data CTA must navigate to Explore/Question, not only show a SnackBar.
- Axis detail must show:
  - definition
  - source count
  - recent source
  - representative clue
  - non-diagnostic caveat

### 10. Insight Detail

v2 role:

- Let users inspect, correct, hide, disagree with, or report a clue.

Action meanings:

- `수정`: User adds their own wording or correction note. It does not directly edit the AI output unless product supports that.
- `동의하지 않음`: User says the clue does not feel right. Future summaries should reduce or mark that clue.
- `숨김`: Remove clue from Home / visible surfaces. Underlying records stay intact.
- `신고`: Harmful, unsafe, offensive, privacy-risk, or clearly wrong generated content. This must be routed for review.

P0:

- Add `신고하기` or `문제가 있어요` action.
- Differentiate `동의하지 않음` from `신고`.
- Explain that hidden clue does not delete the original Diary/answer.

Safe copy:

- `이 단서는 현재 기록에서 보이는 임시 흐름입니다. 다르게 느껴진다면 수정하거나 숨길 수 있어요.`

### 11. Store / Star

v2 role:

- Optional expansion only.

P0:

- Remove Star cost from Question/Explore.
- Store must say core exploration continues without purchase.
- Mock billing must never appear as a live purchase in release build.

Allowed uses:

- Expanded reports
- optional history views
- optional convenience features

Forbidden uses:

- starting questions
- continuing core loop
- unlocking basic U-Map
- "more accurate analysis"

### 12. Settings

v2 role:

- Real control surface.

P0:

- Terms link
- Privacy link
- Data deletion flow
- Account deletion / withdrawal flow
- Logout
- App version

Deletion policy must be explicit:

- request-based deletion, or
- immediate authenticated deletion

Release copy cannot say only:

- `출시 전 연결 예정`
- `준비 상태입니다`

It must describe the actual release behavior.

## 3. P0 UX Priorities

### P0-1. Remove Star Cost From Core Exploration

Owner: Flutter App Lead + Store/Billing

Required changes:

- Remove Star pill from question start cards if it implies cost.
- Remove mock history rows like `오늘 질문 시작 -10`.
- Ensure `오늘 질문 시작`, `자유탐구 시작`, and basic Question flow never spend Star.

Acceptance:

- A tester can complete Home -> Explore -> Question -> Clue -> Diary/U-Map without seeing a payment/cost requirement.

### P0-2. Add Diary CTA After Answer Completion

Owner: Flutter App Lead

Required changes:

- In Question complete screen, make `Diary에 이어쓰기` primary or equal-primary.
- Keep `U-Map 반영 보기` as secondary.

Acceptance:

- After saving an answer, user immediately understands:
  - write Diary
  - view U-Map
  - continue question

### P0-3. Relax Diary Minimum Length

Owner: Flutter App Lead + UX

Required changes:

- Remove 50-character blocker.
- Allow short Diary record.
- Keep helper copy that longer context can help U-Map.

Acceptance:

- User can save a short but meaningful entry.
- Save failure only appears for actual technical failure or empty invalid state.

### P0-4. Normalize U-Map 8 Axes

Owner: Flutter App Lead + Safety

Required changes:

- Use approved 8-axis list.
- Remove clinical-looking axis labels.
- Update mock data and UI chips to match.

Acceptance:

- U-Map never reads like a mental-health or personality assessment.

### P0-5. Define Insight Actions

Owner: Flutter App Lead + Safety + Backend

Required changes:

- Add separate report action.
- Keep edit/disagree/hide/report semantically distinct.
- Store local/mock state now; prepare backend fields later.

Acceptance:

- User can say:
  - "I would word this differently."
  - "I disagree."
  - "Hide this."
  - "This is harmful/wrong/unsafe."

### P0-6. Persist Local Session / Onboarding State

Owner: Flutter App Lead + Backend

Required changes:

- Mock/local should persist profile and onboarding across app restart for demo.
- Supabase release path must restore real session.

Acceptance:

- Complete onboarding, close app, reopen app -> Home.

### P0-7. Settings Legal / Deletion / Withdrawal Real Flow

Owner: Flutter App Lead + Backend + PM

Required changes:

- Replace "coming soon" legal copy with real links or in-app legal pages.
- Implement deletion request or immediate deletion behavior.
- Make account withdrawal copy explicit.

Acceptance:

- Tester can open Terms/Privacy.
- Tester can start data deletion/account deletion flow and see exact consequence.

### P0-8. Fix Bottom Navigation Overlap

Owner: Flutter App Lead + UI

Required changes:

- Ensure all scrollable screens have bottom padding greater than nav height.
- Sticky CTAs must sit above nav or scroll fully above it.

Acceptance:

- Last content and buttons are tappable on emulator and real device.

## 4. P1 UX Priorities

### P1-1. U-Map Low Data Direct Navigation

Change SnackBar-only guidance into direct navigation to Explore/Question.

### P1-2. Insight Source Record Detail

`근거 기록 보기` should open a real source list or source detail, not only a SnackBar.

### P1-3. Diary Privacy Helper

Add helper text around people/context fields to avoid unnecessary third-party personal data.

### P1-4. My Screen Store Weight

Reduce Store/Report prominence if it competes with Settings/privacy/core loop.

### P1-5. Store Mock/Real Mode Separation

Make build-mode behavior explicit:

- internal mock visible
- release mock hidden
- real Google Play Billing only in release purchase CTA

### P1-6. Empty States For Fresh Mock Account

Add a true no-record demo state:

- no Diary
- low U-Map
- no today clue
- first question

This helps QA verify first-user clarity.

## 5. Flutter App Lead Flow Modification Instructions

### Instruction A. Core Explore Is Free

Remove all UI that implies starting or continuing Question/Explore costs Star.

Affected surfaces:

- Home next question
- Explore recommended question
- Explore free/custom question
- Question flow header
- Star history mock rows

Replacement:

- If Star must appear, move it to My/Store only.
- Copy: `기본 질문과 U-Map은 결제 없이 이어갈 수 있어요.`

### Instruction B. Question Completion Must Branch To Diary

Update Question completion screen:

Primary:

- `Diary에 이어쓰기`

Secondary:

- `U-Map 반영 보기`
- `다른 질문 이어가기`
- `홈으로`

Behavior:

- Diary route receives optional source question/answer context if possible.
- If not, Diary opens normally with helper copy.

### Instruction C. Diary Must Accept Short Records

Change validation:

- Empty body: block or allow draft.
- Short body: allow save.
- Remove "50자 이상" hard gate.

Copy:

- `한 문장도 단서가 될 수 있어요.`
- `조금 더 적으면 U-Map이 더 섬세해질 수 있어요.`

### Instruction D. U-Map Axis Data Must Match Product Definition

Use approved 8-axis list in mock data and screen labels.

Remove:

- clinical labels
- diagnostic labels
- locked axis that looks like paid or unavailable core map unless intentionally explained as low-data

### Instruction E. Insight Control Semantics

Use four action types:

- Edit note
- Disagree
- Hide
- Report

Each action must show a different confirmation message.

Example:

- Edit: `내 표현을 저장했어요.`
- Disagree: `이 단서를 동의하지 않음으로 표시했어요.`
- Hide: `홈에서 이 단서를 숨겼어요. 원본 기록은 유지됩니다.`
- Report: `신고가 접수됐어요. 안전 검토에 사용됩니다.`

### Instruction F. Settings Must Be Release-Real

Replace coming-soon settings actions with release behavior:

- Terms
- Privacy
- AI limitation
- Data deletion
- Account withdrawal
- Logout

Until backend is connected:

- Internal mock may show "local demo".
- Release UI must not say "출시 전 연결 예정".

### Instruction G. Navigation Trust

Add enough bottom padding to every `FiYouPageScroll` screen.

Minimum:

- bottom nav height + 24 px

Validate:

- Auth
- Onboarding
- Home
- Explore
- Question Flow
- Diary
- Diary Write
- U-Map
- Insight Detail
- My
- Settings
- Store

## 6. Happy Path Demos Before Release

### Happy Path 1. First User Core Loop

Purpose:

- Prove first-time user understands FI-YOU without diagnosis or payment pressure.

Steps:

1. Fresh install / cleared local state
2. Auth
3. Onboarding
4. Home
5. Tap `오늘 질문 시작`
6. Answer question
7. See `오늘 발견된 단서`
8. Tap `Diary에 이어쓰기`
9. Save short Diary
10. View U-Map reflected state
11. Return Home

Pass criteria:

- No Star cost appears.
- No diagnosis/type/test copy appears.
- User always has a clear next CTA.

### Happy Path 2. Returning User Insight Control

Purpose:

- Prove user can review and control AI/reflection output.

Steps:

1. Reopen app after prior onboarding
2. Land on Home, not Auth
3. Tap `오늘 발견된 단서`
4. Open Insight Detail
5. View source records
6. Add edit note
7. Mark disagree
8. Hide clue
9. Report clue
10. Return Home

Pass criteria:

- Edit/disagree/hide/report have distinct meanings.
- Hidden clue no longer dominates Home.
- Original records are not deleted by hide.

### Happy Path 3. Settings Trust And Recovery

Purpose:

- Prove release trust surfaces are usable.

Steps:

1. Open My
2. Open Settings
3. Open Terms
4. Open Privacy
5. Open AI limitation
6. Start data deletion flow, cancel
7. Start account withdrawal flow, cancel
8. Logout
9. Sign back in
10. Confirm onboarding/session behavior is correct

Pass criteria:

- Legal/deletion surfaces are real, not "coming soon".
- Deletion consequence is clear.
- Logout returns to Auth.
- Normal relaunch after completed onboarding returns to Home.

## 7. PM Summary

v2 implementation should prioritize trust in the core loop over breadth.

The next round is successful when:

- Questions are clearly free.
- Answer completion naturally invites Diary.
- Diary accepts small records.
- U-Map uses safe 8-axis language.
- Insight controls are meaningful.
- Local/session state survives demo restart.
- Settings is release-real.
- Bottom nav never blocks content.

Only after this should Store, paid Reports, and Star packages receive more visual weight.
