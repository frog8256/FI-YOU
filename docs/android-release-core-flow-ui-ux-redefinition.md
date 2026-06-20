# FI-YOU Android Release Core Flow UI/UX Redefinition

Last updated: 2026-06-19

Owner: Product Concept & UX Flow Lead

Audience:

- PM
- Flutter App Lead
- UI Design / Visual System Lead
- Backend / Supabase Lead
- Release QA

Scope:

- Android 1차 출시 기준 핵심 사용자 여정
- 화면별 목적, CTA, 뒤로가기, 복귀 흐름
- 미구현 화면과 완성도 부족 화면
- 빈 상태, 로딩, 오류 상태
- 핵심 루프를 방해하는 UX 리스크
- P0/P1/P2 구현 우선순위

FI-YOU is an Android-first, record-based self-discovery app. It is not a diagnosis, counseling, therapy, fixed personality type, compatibility, or treatment app.

## 1. Product Principle

FI-YOU의 핵심 가치는 사용자가 답변과 Diary 기록을 남기고, 그 기록에서 현재 보이는 단서와 흐름을 U-Map과 Signature로 다시 바라보는 데 있다.

Core loop:

`First Launch -> Auth -> Onboarding -> Home -> Explore Question -> Answer -> Clue Found -> U-Map Reflected -> Diary -> Home / Next Question -> My / Settings`

Every UX decision must protect this loop.

### Must Feel Like

- 기록을 남기는 앱
- 오늘의 단서를 발견하는 앱
- U-Map으로 흐름을 확인하는 앱
- 다음 질문으로 자기이해 여정을 이어가는 앱

### Must Not Feel Like

- 성격유형 검사 앱
- 진단 앱
- 상담/치료 앱
- 궁합/관계 판정 앱
- 결제를 해야 나를 더 정확히 알 수 있는 앱

### Safe Product Vocabulary

Use:

- 단서
- 흐름
- 기록
- 반영
- U-Map
- Signature
- 자기이해 여정
- 현재 기록
- 오늘의 질문
- 조금 더 선명해짐
- 다음 질문으로 이어짐

Avoid:

- 진단
- 검사
- 분석 정확도
- 성격유형
- 고정 유형
- 궁합
- 치료
- 상담
- 처방
- 정상 / 비정상
- 진짜 나
- 완벽한 나

## 2. Android 1차 출시 핵심 사용자 여정 맵

### Journey A. First Launch

1. Splash / App start
2. Auth
3. Onboarding
4. Home initial state
5. Explore first question
6. Answer question
7. Clue found feedback
8. Diary write prompt
9. U-Map low-data or first reflected state
10. Home return with next action

Goal:

- 사용자가 첫 실행 후 결제나 리포트가 아니라 첫 질문과 첫 기록을 경험한다.

Success criteria:

- 사용자는 3분 안에 첫 질문을 시작할 수 있다.
- 답변 후 "다음에 무엇을 해야 하는지"가 명확하다.
- U-Map은 빈 상태라도 고장처럼 보이지 않는다.

### Journey B. Returning User

1. App start
2. Home
3. Current next question
4. Answer or Diary
5. Clue found / U-Map reflected
6. U-Map detail or Signature
7. Next question

Goal:

- 사용자가 매번 하나의 기록을 남기고, 하나의 단서를 확인하고, 다음 질문으로 이어간다.

Success criteria:

- Home은 항상 다음 행동을 하나 이상 제안한다.
- Reports/Store/Star는 핵심 CTA보다 앞서지 않는다.

### Journey C. Diary-First User

1. Home or Diary tab
2. Diary list / empty state
3. Diary write
4. Save
5. U-Map reflected feedback
6. Suggested question

Goal:

- 질문보다 자유 기록을 선호하는 사용자도 루프에 들어온다.

Success criteria:

- Diary 저장 후 U-Map과 질문 흐름으로 자연스럽게 연결된다.

### Journey D. Settings / Privacy / Account Control

1. My / Settings
2. Profile and account controls
3. Privacy / legal / AI limitation
4. Data deletion or account deletion
5. Logout

Goal:

- Play 출시 기준의 신뢰, 개인정보, 계정 제어가 명확하다.

Success criteria:

- 사용자는 개인정보처리방침과 데이터 삭제 경로를 쉽게 찾는다.
- 계정 삭제가 요청인지 즉시 삭제인지 명확하다.

## 3. Global Navigation Model

Recommended Android 1차 출시 bottom navigation:

1. Home
2. Explore
3. Diary
4. U-Map
5. My

Secondary screens:

- Auth
- Onboarding
- Question Answer
- Clue Found
- Diary Write
- Diary Detail
- U-Map Detail
- Insight / Clue Detail
- Signature
- Reports
- Store
- Settings Detail
- Legal / Privacy / Deletion

Navigation rule:

- Home is the loop hub.
- Explore is the question entry.
- Diary is the record entry.
- U-Map is the reflection map.
- My is account/control.
- Store is never a primary tab for Android 1차 출시.

## 4. Screen Specifications

## 4.1 Splash / App Start

Priority: P0

Purpose:

- Restore session.
- Check whether user needs Auth, Onboarding, or Home.

Entry:

- App launch

Exit:

- No session -> Auth
- Signed in, onboarding incomplete -> Onboarding
- Signed in, onboarding complete -> Home

Primary CTA:

- None

Loading state:

- `기록을 준비하고 있어요`

Error state:

- If session restore fails, route to Auth with calm retry.

Risk:

- Do not show marketing or paywall here.

## 4.2 Auth

Priority: P0

Purpose:

- Let the user enter FI-YOU with minimal friction.
- Establish account identity for private records and deletion controls.

Entry:

- First launch with no session
- Logout
- Expired session

Exit:

- Auth success -> Onboarding if incomplete
- Auth success -> Home if onboarding complete

Primary CTA:

- `Google로 계속하기`
- Optional: `이메일로 계속하기`

Secondary CTA:

- `개인정보처리방침`
- `이용약관`

Back behavior:

- Android back exits app from Auth.

Empty state:

- Not applicable.

Loading:

- `로그인 중이에요`

Error:

- `로그인하지 못했어요. 잠시 후 다시 시도해주세요.`

Safety copy:

- `FI-YOU는 기록 기반 자기이해 앱입니다. 진단이나 상담을 제공하지 않습니다.`

P0 requirements:

- Auth must not mention personality type, diagnosis, therapy, or compatibility.
- Legal links must be visible before account creation or sign-in.

## 4.3 Onboarding

Priority: P0

Purpose:

- Explain the self-discovery loop.
- Set non-diagnostic expectation.
- Collect only launch-critical setup.

Entry:

- First successful Auth for users without completed onboarding
- Reset onboarding only if supported later

Exit:

- Complete -> Home

Primary CTA:

- `첫 질문 시작하기`

Secondary CTA:

- `나중에 이어하기` only if product allows incomplete onboarding.

Back behavior:

- Back should not lose already entered onboarding fields.
- If user exits, next app launch returns to onboarding.

UI:

- 2-4 short pages or one compact setup screen.
- Explain:
  - Question
  - Diary
  - U-Map
  - Signature
  - "고정 유형이 아님"

Empty:

- Not applicable.

Loading:

- `설정을 저장하고 있어요`

Error:

- Save failure preserves inputs.

Safety copy:

- `U-Map은 현재 기록에서 보이는 흐름입니다. 앞으로의 답변과 Diary에 따라 달라질 수 있습니다.`

P0 requirements:

- Do not ask the user to choose a personality type.
- Do not promise accurate self-analysis.

## 4.4 Home

Priority: P0

Purpose:

- Show the user's next best action.
- Keep the core loop moving.
- Reflect recent clue, U-Map state, Diary state, and next question.

Entry:

- App launch after onboarding
- Bottom nav Home
- Return from Question, Diary, U-Map, My

Exit:

- Primary -> Question
- Secondary -> Diary Write
- Secondary -> U-Map
- Tertiary -> Insight Detail, Reports, My

Primary CTA:

- `오늘 질문 시작`
- If question already answered today: `다음 질문 보기`

Secondary CTA:

- `Diary 쓰기`
- `U-Map 보기`
- `오늘 발견된 단서 보기`

Tertiary CTA:

- `Reports`
- `Star 관리`
- `Settings`

Back behavior:

- Android back from Home exits app or asks for exit confirmation depending platform convention.

UI:

- Greeting / app identity
- Next question card
- Today clue card
- U-Map summary card
- Diary shortcut
- Optional Signature summary
- Quiet Star balance, if needed

Empty:

- No records:
  - Title: `첫 단서를 남겨볼까요?`
  - Body: `질문 하나 또는 짧은 Diary 하나로 U-Map이 시작됩니다.`
  - CTA: `첫 질문 시작`

Loading:

- Skeleton cards.
- `오늘의 흐름을 불러오고 있어요`

Error:

- If full Home fails:
  - `홈을 불러오지 못했어요`
  - CTA: `다시 시도`
- If partial modules fail:
  - Show available modules and local retry.

Safety copy:

- `현재 기록에서 보이는 흐름이에요. 더 기록할수록 달라질 수 있습니다.`

P0 requirements:

- No fake progress.
- No hardcoded question, U-Map clarity, Star balance, or activity counts.
- Store/Reports must not visually outrank Question.

## 4.5 Explore

Priority: P0

Purpose:

- Provide a question-oriented entry point.
- Let users understand why the next question is useful.

Entry:

- Bottom nav Explore
- Home CTA
- U-Map next question CTA

Exit:

- Start question -> Question Answer
- Back/Home -> Home

Primary CTA:

- `질문에 답하기`

Secondary CTA:

- `Diary 먼저 쓰기`

Back behavior:

- Back returns to Home or previous screen.

UI:

- Next question preview
- Why this question
- Related U-Map axis if available
- Estimated time: `약 1-3분`

Empty:

- No question:
  - `지금은 이어갈 질문이 없어요`
  - CTA: `Diary 쓰기`

Loading:

- `질문을 준비하고 있어요`

Error:

- Retry.

Safety:

- Do not use "test", "assessment", or "result".

## 4.6 Question Answer

Priority: P0

Purpose:

- Capture structured and/or written response.
- Feed the record-based loop.

Entry:

- Explore
- Home
- U-Map
- Signature

Exit:

- Save success -> Clue Found
- Back -> Explore or previous

Primary CTA:

- `답변 저장`

Secondary CTA:

- `나중에 답하기`

Back behavior:

- If no input, back normally.
- If input exists, confirm discard.

UI:

- Question prompt
- Optional why-this-question copy
- Answer type:
  - 선택형
  - 서술형
  - 복합형
- Optional text field
- Save CTA

Empty:

- No question state from provider:
  - route back to Explore empty state.

Loading:

- `질문을 불러오고 있어요`

Error:

- Load failure: retry.
- Save failure: preserve input.

Safety:

- `정답이 있는 질문이 아니에요. 오늘의 나와 가까운 쪽을 골라주세요.`

P0 requirements:

- Must support selected choice plus optional text for launch.
- Save must invalidate Home, U-Map, Signature, Diary-related state where appropriate.

## 4.7 Clue Found / Question Complete

Priority: P0

Purpose:

- Confirm answer saved.
- Give safe, non-analytical feedback.
- Tell the user what to do next.

Entry:

- Question Answer save success

Exit:

- `Diary에 이어쓰기` -> Diary Write
- `U-Map 반영 보기` -> U-Map
- `홈으로` -> Home

Primary CTA:

- `Diary에 이어쓰기`

Secondary CTA:

- `U-Map 반영 보기`
- `홈으로 돌아가기`

Back behavior:

- Back returns to Home or Explore, not unsaved answer.

UI:

- Confirmation: `오늘의 단서가 저장됐어요`
- Selected answer preview
- Optional written excerpt
- U-Map reflection note
- Next action card

Empty:

- Not applicable.

Loading:

- If saving and generating reflection:
  - `기록에 반영하고 있어요`

Error:

- If feedback generation fails after answer save:
  - show answer saved state and skip generated copy.
  - CTA remains available.

Safety:

- Use `단서`, `반영`, `기록`.
- Avoid `분석 완료`, `결과 생성`, `유형 확인`.

## 4.8 Diary Home

Priority: P0

Purpose:

- Show user's records.
- Invite new Diary writing.

Entry:

- Bottom nav Diary
- Home Diary shortcut

Exit:

- New -> Diary Write
- Existing entry -> Diary Detail
- Home -> bottom nav

Primary CTA:

- `새 Diary 쓰기`

Secondary CTA:

- `질문에 답하기`

Back behavior:

- Back to Home if pushed; otherwise app nav behavior.

UI:

- Diary list
- Date grouping optional
- Entry cards with title/excerpt/date/tags
- Floating or header add button

Empty:

- `아직 남긴 Diary가 없어요`
- `한 문장도 괜찮아요. 지금 떠오르는 장면이나 마음을 남기면 U-Map의 단서가 됩니다.`
- CTA: `첫 Diary 쓰기`

Loading:

- `Diary를 불러오고 있어요`

Error:

- `Diary를 불러오지 못했어요`
- CTA: `다시 시도`

Safety:

- Do not judge writing quality.

## 4.9 Diary Write

Priority: P0

Purpose:

- Capture freeform record and emotion tags.

Entry:

- Diary Home
- Clue Found
- Home

Exit:

- Save success -> Diary Save Feedback or U-Map reflection
- Back -> previous

Primary CTA:

- `Diary 저장`

Secondary CTA:

- `삭제` for edit mode

Back behavior:

- Unsaved text triggers discard confirmation.

UI:

- Date
- Emotion tags
- Body text area
- Optional related question context
- Save button

Empty:

- Body empty:
  - keep Save disabled unless tag-only save is allowed.

Loading:

- `Diary를 저장하고 있어요`

Error:

- `기록을 저장하지 못했어요. 작성한 내용은 그대로 두었어요.`
- CTA: `다시 저장`

Safety:

- Emotion tags are user labels, not diagnosis.

## 4.10 Diary Save Feedback

Priority: P1, but recommended for clarity

Purpose:

- Confirm save.
- Link Diary to U-Map and next question.

Entry:

- Diary Write save success

Exit:

- `U-Map 반영 보기`
- `다음 질문 보기`
- `Diary 목록`

Primary CTA:

- `U-Map 반영 보기`

Secondary CTA:

- `다음 질문 보기`

Back:

- Back returns to Diary Home.

Copy:

- `Diary가 저장됐어요`
- `이 기록은 U-Map의 흐름에 반영됩니다.`

## 4.11 U-Map Summary

Priority: P0

Purpose:

- Let users see their current 8-axis self-discovery map.

Entry:

- Bottom nav U-Map
- Home U-Map card
- Clue Found
- Diary feedback

Exit:

- Axis detail -> U-Map Detail
- Next question -> Question
- Signature -> Signature

Primary CTA:

- `다음 질문 보기`

Secondary CTA:

- `축별 단서 보기`
- `Diary 쓰기`

Back:

- Back to Home or previous.

UI:

- U-Map visualization
- Overall clarity as "선명도", not accuracy
- 8 axis cards
- Low-data state

Empty / Low Data:

- `U-Map을 그릴 기록이 조금 더 필요해요`
- CTA: `질문에 답하기`

Loading:

- `U-Map에 기록을 반영하고 있어요`

Error:

- Retry with safe fallback.

Safety:

- `선명도는 정확도가 아니라 현재 기록의 충분함을 뜻합니다.`

## 4.12 U-Map Detail / Axis Detail

Priority: P0

Purpose:

- Explain how each axis has accumulated data.
- Show evidence and next direction.

Entry:

- U-Map axis card
- Insight detail

Exit:

- Back -> U-Map summary
- Source record -> Diary Detail or Question response view if supported
- Next question -> Question

Primary CTA:

- `이 축의 다음 질문 보기`

Secondary CTA:

- `관련 Diary 보기`
- `단서 숨기기 / 동의하지 않음` if insight-level control is present

UI:

- Axis name
- Definition
- Current clarity
- Based-on records:
  - Question count
  - Diary count
  - Recent excerpts
- What is clear
- What is still unclear
- Suggested next question

8 axes:

1. 에너지 리듬
2. 감정 인식
3. 가치 기준
4. 선택 방식
5. 관계 흐름
6. 긴장과 회복
7. 성장 동기
8. 삶의 방향

Empty:

- Axis-specific low data:
  - `이 축은 아직 기록이 적어요`
  - CTA: `관련 질문 보기`

Loading:

- `축의 단서를 불러오고 있어요`

Error:

- `이 축의 기록을 불러오지 못했어요`

Safety:

- Do not present axis as trait score.
- Do not use normal/abnormal.

## 4.13 Insight / Clue Detail

Priority: P0 if Home shows today clue

Purpose:

- Let users inspect source data behind a clue.
- Give control: edit, hide, disagree, report.

Entry:

- Home today clue
- U-Map axis clue
- Signature evidence

Exit:

- U-Map
- Diary Write / Edit
- Question
- Back

Primary CTA:

- `U-Map에서 보기`

Secondary CTA:

- `Diary에 이어쓰기`
- `다음 질문 보기`

Control actions:

- `수정하기`
- `숨기기`
- `동의하지 않음`
- `신고하기`

Back:

- Back to source screen.

UI:

- Clue title
- Current clue summary
- Source records
- U-Map reflected axes
- User control actions
- Safety note

Empty:

- If clue deleted/hidden:
  - `이 단서는 더 이상 표시되지 않아요`
  - CTA: `U-Map으로 돌아가기`

Loading:

- `단서의 기반 기록을 불러오고 있어요`

Error:

- `단서를 불러오지 못했어요`
- CTA: `다시 시도`

Safety:

- `이 단서는 현재 기록에서 임시로 보이는 흐름입니다. 다르게 느껴진다면 숨기거나 피드백을 남길 수 있어요.`

## 4.14 Signature

Priority: P1 for detailed screen; P0 if exposed on Home

Purpose:

- Summarize current recurring flow.
- Avoid fixed type naming.

Entry:

- Home Signature card
- U-Map
- My / Settings

Exit:

- Next question
- U-Map
- Back

Primary CTA:

- `다음 질문 보기`

Secondary:

- `U-Map 보기`
- `근거 기록 보기`

Empty:

- `Signature를 만들 기록이 조금 더 필요해요`

Safety:

- Signature is not a type name.
- Copy must say it can change as records grow.

## 4.15 My

Priority: P0

Purpose:

- Account and profile hub.
- Access Settings, privacy, Star, Reports.

Entry:

- Bottom nav My
- Home profile icon

Exit:

- Settings
- Store
- Reports
- Legal
- Logout

Primary CTA:

- None

Secondary CTA:

- `Settings`
- `개인정보`
- `Star / Store`

Back:

- Back to Home or app nav behavior.

UI:

- Profile summary
- Record summary
- Settings row
- Privacy/legal rows
- Optional Star balance

Risk:

- My must not become Store-first.

## 4.16 Settings

Priority: P0

Purpose:

- Real account, privacy, notification, data deletion, legal, logout control.

Entry:

- My
- Home profile icon

Exit:

- Back -> My or Home
- Logout -> Auth
- Deletion -> deletion flow

Primary CTA:

- None

Important actions:

- `알림 설정`
- `개인정보처리방침`
- `데이터 삭제 요청`
- `계정 삭제`
- `이용약관`
- `로그아웃`

Back:

- Back returns to My.

UI:

- Profile
- Notifications
- Data and privacy
- Legal
- Account
- App version

Empty:

- Not applicable.

Loading:

- Only for row-level actions.

Error:

- Legal link failure:
  - `문서를 열지 못했어요`
- Deletion request failure:
  - preserve user on settings and retry.
- Logout failure:
  - retry.

Safety:

- Deletion must clearly say request-based or immediate.

## 4.17 Store / Star

Priority: P1; P0 if visible in release build

Purpose:

- Optional paid expansion.
- Manage Star balance and purchase products.

Entry:

- My
- Reports locked card
- Optional Home tertiary link

Exit:

- Back -> source
- Purchase success -> source or Store balance
- Cancel/failure -> Store

Primary CTA:

- `Google Play로 구매`

Secondary:

- `구매 복원`
- `사용 내역 보기`

Back:

- Back returns to previous surface.

UI:

- Star balance
- Packages
- Usage history
- Billing connection state

Mock state before real billing:

- Internal builds only:
  - `Google Play Billing 연결 전 확인용 화면입니다. 실제 결제는 진행되지 않습니다.`
- Production must hide mock purchase actions.

Empty:

- No products:
  - `표시할 상품이 없어요`
  - CTA: `다시 시도`

Loading:

- `Google Play 상품 정보를 확인하고 있어요`

Error:

- Product load failure
- Purchase canceled
- Pending purchase
- Verification failure

Safety:

- Store must never say paid features are required to continue self-discovery.

## 4.18 Reports

Priority: P1

Purpose:

- Optional expanded reading of existing records.

Entry:

- My
- Home tertiary
- Store return

Exit:

- Report detail
- Store if locked
- Question / Home

Primary CTA:

- Unlocked: `리포트 읽기`
- Locked: `확장 리포트 열기`

Secondary:

- `질문 계속하기`

Back:

- Back to source.

Empty:

- `아직 준비된 리포트가 없어요`
- `답변과 Diary가 쌓이면 더 긴 기록 정리를 볼 수 있어요.`

Safety:

- Reports are deeper organization, not more accurate truth.

## 5. Not Yet Implemented / Missing Screens

P0 missing or likely incomplete:

- Auth final release UX
- Onboarding final release UX
- Clue Found / Question Complete screen
- Insight / Clue Detail screen
- U-Map Axis Detail with evidence
- Data deletion / account deletion detail flow
- AI insight report/feedback flow
- Common empty/loading/error components applied consistently across all screens

P1 missing or likely incomplete:

- Diary Save Feedback screen
- Store purchase restore and usage history
- Report detail
- Notification settings
- Signature evidence detail

P2 missing:

- U-Map history timeline
- Advanced insight editing
- Relation graph / complex relationship flows
- Social sharing

## 6. Existing But Not Release-Complete Screens

Home:

- Must replace mock/hardcoded values with real provider data.
- Must keep Question as primary CTA.

Diary:

- Needs polished empty/error/save feedback.
- Needs clear U-Map reflection after save.

Explore / Question:

- Needs answer type completeness and save feedback.
- Must avoid test/diagnosis language.

U-Map:

- Needs 8-axis definitions and evidence per axis.
- Must show low-data state.

My / Settings:

- Needs real deletion policy and action handling.
- Needs legal/privacy/deletion clarity.

Store:

- Needs explicit mock vs real billing behavior.
- Needs restore purchase if paid launch is active.

Reports:

- Needs stronger optional/expanded-reading framing.
- Must not imply accuracy upgrade.

## 7. Common State Definitions

### Empty States

Question none:

- `지금은 이어갈 질문이 없어요`
- CTA: `Diary 쓰기`

Diary none:

- `아직 남긴 Diary가 없어요`
- CTA: `첫 Diary 쓰기`

U-Map low data:

- `U-Map을 그릴 기록이 조금 더 필요해요`
- CTA: `질문에 답하기`

Insight unavailable:

- `아직 보여줄 단서가 충분하지 않아요`
- CTA: `질문에 답하기`

Reports none:

- `아직 준비된 리포트가 없어요`
- CTA: `질문 계속하기`

Store no products:

- `표시할 상품이 없어요`
- CTA: `다시 시도`

### Loading States

- `기록을 불러오고 있어요`
- `질문을 준비하고 있어요`
- `Diary를 저장하고 있어요`
- `U-Map에 기록을 반영하고 있어요`
- `Google Play 상품 정보를 확인하고 있어요`

Avoid:

- `분석 중`
- `진단 중`
- `성격 계산 중`

### Error States

Network:

- `연결이 불안정해요`
- CTA: `다시 시도`

Save failure:

- `저장하지 못했어요`
- `작성한 내용은 그대로 두었어요.`
- CTA: `다시 저장`

Load failure:

- `기록을 불러오지 못했어요`
- CTA: `다시 시도`

Purchase failure:

- `구매 확인에 시간이 걸리고 있어요`
- CTA: `구매 복원`

Legal link failure:

- `문서를 열지 못했어요`
- CTA: `다시 시도`

## 8. UX Risks That Can Break The Core Loop

P0 risks:

- Home emphasizes Store/Star before Question.
- User answers a question and does not know the next step.
- U-Map appears as diagnosis or score.
- Insight appears as final AI judgment.
- Paid report appears more accurate than free self-discovery.
- Store blocks or pressures the core loop.
- Account deletion/privacy path is unclear for Play review.
- Save failure loses user input.
- Empty states look broken.

P1 risks:

- Relations appears like compatibility.
- Signature looks like fixed type.
- Star balance creates scarcity pressure.
- Reports become a main navigation item before the loop is understood.

P2 risks:

- Too much explanation makes the app feel like a document instead of a tool.
- Gamified progress makes self-discovery feel like performance.

## 9. Implementation Priority

### P0 - Launch Blockers

1. Finalize Auth and Onboarding.
2. Make Home use real data and prioritize next question.
3. Complete Question Answer flow.
4. Add Clue Found screen after answer save.
5. Complete Diary Write and save handling.
6. Complete U-Map Summary and Axis Detail with 8-axis definitions.
7. Add Insight / Clue Detail if Home shows clues.
8. Add My / Settings real privacy, deletion, legal, logout flows.
9. Apply common empty/loading/error states.
10. Remove or replace all diagnosis/type/accuracy/counseling/therapy copy.
11. Ensure Store does not block core loop.

### P1 - Important Before Wider Release

1. Store real Google Play Billing states.
2. Purchase restore.
3. Star usage history.
4. Reports detail and return flow.
5. Diary save feedback.
6. Signature evidence detail.
7. Notification settings.
8. AI insight report/feedback operational path.

### P2 - Defer

1. Advanced U-Map history.
2. Advanced insight editing.
3. Relation graph.
4. Social/friend features.
5. Sharing.
6. Gamification.
7. Advanced report marketplace.

## 10. Flutter App Lead Handoff

### Build Order Recommendation

1. Route and state audit:
   - Confirm every P0 screen route exists.
   - Add missing routes for Clue Found, Insight Detail, U-Map Axis Detail, Deletion Detail if absent.

2. Core loop implementation:
   - Home -> Question -> Answer Save -> Clue Found -> Diary Write -> U-Map -> Home / Next Question.

3. Common state layer:
   - Empty
   - Loading
   - Error
   - Save failure with draft preservation

4. Evidence surfaces:
   - U-Map axis detail
   - Insight detail source records
   - Signature evidence if exposed

5. My / Settings:
   - privacy
   - deletion
   - logout
   - legal links

6. Store / Reports:
   - keep secondary
   - mock state clearly separated from production
   - Google Play Billing readiness

### Screen Route Requirements

Required P0 routes:

- `/auth`
- `/onboarding`
- `/home` or `/today`
- `/explore`
- `/question`
- `/question/complete`
- `/diary`
- `/diary/new`
- `/diary/:id`
- `/u-map`
- `/u-map/:axis`
- `/insight/:id`
- `/my`
- `/settings`
- `/settings/privacy`
- `/settings/delete-data`

P1 routes:

- `/signature`
- `/reports`
- `/reports/:id`
- `/store`
- `/store/history`
- `/settings/notifications`

### Data Contract Needs

Home needs:

- next question
- latest clue
- U-Map summary
- Diary summary
- Signature summary
- Star balance only if shown

Question needs:

- prompt
- answer type
- choices
- optional text prompt
- related axis
- why this question

Clue Found needs:

- saved answer
- reflected axes
- next recommended action

U-Map axis detail needs:

- axis definition
- clarity
- source records
- related clues
- next question

Insight detail needs:

- clue text
- source records
- reflected axes
- user feedback/hide state

Settings needs:

- profile
- legal URLs
- deletion mode
- app version

Store needs:

- product list
- Play product details
- Star balance
- ledger/history
- entitlement state

## 11. PM Decisions Needed

P0 decisions:

1. Is account deletion immediate or request-based?
2. Does Android 1차 출시 expose `오늘 발견된 단서` on Home? If yes, Insight Detail is P0.
3. Does Android 1차 출시 include active Store purchases? If yes, Store is P0, not P1.
4. Should Signature be visible on Home at launch or only under U-Map/My?
5. Should Relations be hidden from Home and kept under My/Settings only?

P1 decisions:

1. Which Star packages are active at launch?
2. Are paid Reports active or preview-only?
3. Is `fiyou_plus` draft-only or active?
4. Are push notifications included in 1차 출시?

## 12. Release Acceptance Criteria

The Android app can move toward release only when:

- First user can complete Auth -> Onboarding -> Home -> Question -> Answer -> Clue Found -> Diary -> U-Map.
- Returning user always sees a clear next action on Home.
- Question answer save never strands the user.
- Diary save never loses input on failure.
- U-Map low-data state is understandable.
- U-Map/Insight/Signature never read as diagnosis or fixed type.
- Store/Star never blocks the core loop.
- Settings includes privacy, deletion, legal, logout.
- Empty/loading/error states are implemented across P0 screens.
- No P0 screen uses mock values in production.

## 13. Summary For PM

FI-YOU Android 1차 출시는 "많은 기능"보다 "끊기지 않는 자기탐색 루프"가 중요하다.

The release-grade loop is:

1. 사용자가 들어온다.
2. 오늘의 질문을 본다.
3. 답변한다.
4. 단서를 발견한다.
5. Diary로 맥락을 남긴다.
6. U-Map에서 현재 흐름을 본다.
7. 다음 질문으로 이어간다.
8. My/Settings에서 자기 데이터와 계정을 통제한다.

Everything else, including Star, Store, Reports, and Relations, must stay secondary until this loop is reliable.
