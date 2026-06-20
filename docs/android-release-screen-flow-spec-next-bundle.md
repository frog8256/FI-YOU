# FI-YOU Android Release Screen Flow Spec - Next Bundle

Last updated: 2026-06-19

Owner: Product Concept & UX Flow Lead

Scope: Android-first release UX specification for the next bundle of screens:

- Question answer
- Question completion / clue feedback
- Diary write detail
- U-Map detail
- Insight / clue detail
- Star / Store
- My / Settings detail
- Empty, loading, and error states

FI-YOU is not a personality type, diagnosis, counseling, therapy, compatibility, or treatment app. FI-YOU is a record-based self-discovery app that helps users notice current clues, flows, and reflected patterns through Question, Diary, U-Map, and Signature.

## 1. Product Language Standard

### Preferred Words

- 단서
- 흐름
- 기록
- 반영
- U-Map
- Signature
- 자기이해 여정
- 현재 기록
- 오늘 남긴 답변
- 조금 더 선명해짐
- 아직 데이터가 부족함
- 다음 질문으로 이어짐

### Avoid Words

- 진단
- 검사
- 분석 정확도
- 성격유형
- 고정 유형
- 궁합
- 치료
- 상담
- 처방
- 정답
- 정상 / 비정상
- 완벽한 나
- 진짜 나
- 당신은 이런 사람입니다

### Global Safety Copy Pattern

Use this meaning across insight surfaces:

> FI-YOU의 U-Map과 단서는 현재까지의 답변과 Diary 기록을 바탕으로 한 자기이해 참고 자료입니다. 고정된 유형이나 진단이 아니며, 앞으로의 기록에 따라 달라질 수 있습니다.

Short version:

> 현재 기록에서 보이는 흐름이에요. 더 기록할수록 달라질 수 있습니다.

## 2. Launch Priority Scale

P0:

- Required for Android 1차 출시 core loop.

P1:

- Important shortly after launch or if implementation already exists.

P2:

- Later improvement; do not block 1차 출시.

## 3. Question Answer Screen

Priority: P0

### Purpose

The Question screen starts real exploration from Home / Today. It should feel like a gentle reflection prompt, not a test or assessment.

The screen collects:

- selected answer clue
- optional written context
- enough structured data to update U-Map and next-question flow

### Entry Paths

- Home / Today primary CTA: `오늘 질문 시작`
- U-Map CTA: `다음 단서 질문 보기`
- Signature CTA: `다음 질문으로 이어가기`
- Empty U-Map state CTA: `질문에 답하고 시작`

### Exit Paths

- Successful save -> Question completion / clue feedback screen
- Back -> previous screen, usually Home / Today
- Save failure -> stay on screen and preserve draft

### UI Structure

- Header:
  - overline: `오늘의 질문`
  - title: question prompt
  - subtitle: why this question is being asked, if available
- Answer area:
  - supports choice-only
  - supports text-only
  - supports choice + optional text
- Progress context:
  - light indicator such as `자기이해 여정 2번째 기록`
  - do not use score or test progress
- Bottom CTA:
  - primary button: `답변 저장`

### Answer Type Rules

#### 선택형

Use when the app needs structured signal.

UI:

- 2-5 choices
- radio-style for single choice
- checkbox-style only if multi-select is required by backend
- selected choice should feel like "closest clue", not "correct answer"

CTA enabled when:

- one required option is selected

Safe helper copy:

> 정답을 고르는 화면이 아니에요. 오늘의 나와 가장 가까운 쪽을 골라주세요.

#### 서술형

Use when nuance matters more than categorical signal.

UI:

- text area
- optional suggested starter line
- character count only if needed

CTA enabled when:

- body passes minimum text rule, if required

Safe helper copy:

> 길게 쓰지 않아도 괜찮아요. 지금 떠오르는 한두 문장이 단서가 될 수 있습니다.

#### 복합형

Recommended default for Android 1차 출시.

UI:

- required closest choice
- optional text field under choices

CTA enabled when:

- selected choice exists
- optional text may be empty

Safe helper copy:

> 선택은 흐름의 방향을 잡고, 짧은 문장은 그 이유를 남겨줍니다.

### CTAs

Primary:

- `답변 저장`
- after save: routes to clue feedback

Secondary:

- `나중에 답하기`
- `Diary 먼저 쓰기` only if the user entered from Diary/Home and product allows it

### Empty / Loading / Error

Loading:

- `질문을 준비하고 있어요`

No question:

- title: `지금은 이어갈 질문이 없어요`
- body: `Diary를 남기면 다음 질문을 더 자연스럽게 이어갈 수 있어요.`
- CTA: `Diary 쓰기`

Save failure:

- title: `답변을 저장하지 못했어요`
- body: `입력한 내용은 그대로 두었어요. 연결 상태를 확인하고 다시 시도해주세요.`
- CTA: `다시 저장`

### Safe Copy

Use:

- `가까운 답`
- `오늘의 단서`
- `현재 기록에 반영`
- `다음 질문으로 이어짐`

Avoid:

- `검사 시작`
- `분석 시작`
- `정확한 유형 확인`
- `결과 보기`
- `진단하기`

## 4. Question Completion / Clue Feedback Screen

Priority: P0

### Purpose

After answering, the user needs a small sense of progress. The screen should not look like instant personality analysis. It should say that a clue was saved and reflected in U-Map.

### Entry Paths

- Question answer save success

### Exit Paths

- `Diary에 이어쓰기` -> Diary write detail
- `U-Map 반영 보기` -> U-Map detail
- `오늘은 여기까지` -> Home / Today

### UI Structure

- Confirmation icon or soft motion
- Main message:
  - `오늘의 단서가 저장됐어요`
- Small summary:
  - selected answer label
  - optional text excerpt
- Reflection note:
  - `이 답변은 U-Map의 흐름에 조용히 반영됩니다.`
- Next recommended action:
  - Diary write prompt

### CTA Priority

Primary:

- `Diary에 이어쓰기`

Secondary:

- `U-Map 반영 보기`
- `홈으로 돌아가기`

### Safe Copy

Use:

- `단서 발견`
- `U-Map에 반영됨`
- `오늘 답변이 기록에 더해졌어요`
- `아직 결론이 아니라, 다음 기록의 재료예요`

Avoid:

- `분석 완료`
- `성격 결과 생성`
- `정확도 상승`
- `당신은 OO형`

## 5. Diary Write Detail Screen

Priority: P0

### Purpose

The Diary detail screen lets the user add context from Diary Home or directly after Question completion. It should reduce writing pressure and reinforce that short records are useful.

### Entry Paths

- Diary Home CTA: `새 Diary 쓰기`
- Question completion CTA: `Diary에 이어쓰기`
- Home secondary CTA: `오늘 기록 남기기`
- Diary detail edit: existing entry edit

### Exit Paths

- Save success -> Diary save feedback or Home
- Save success after question -> U-Map reflection prompt
- Back with unsaved text -> confirmation

### UI Structure

- Header:
  - title: `오늘의 기록`
  - date
- Optional context card:
  - if entered from question, show answered question and selected clue
- Emotion tags:
  - multi-select chips
  - examples: `차분함`, `긴장`, `기대`, `답답함`, `가벼움`, `혼란`, `고마움`, `피곤함`
  - tags are labels for the user's record, not emotional diagnosis
- Body:
  - multiline text field
  - placeholder: `오늘 남기고 싶은 장면이나 마음을 적어보세요. 한 문장도 괜찮아요.`
- Optional title:
  - P1, not required for first release
- Save button:
  - sticky bottom CTA recommended

### CTAs

Primary:

- `Diary 저장`

Secondary:

- `임시 저장` P1
- `삭제` for edit mode only

After Save:

- `U-Map 반영 보기`
- `다음 질문 보기`
- `Diary 목록으로`

### Empty / Loading / Error

Empty body:

- Keep CTA disabled if body is required.
- If body can be empty with tags only, CTA says `태그만 저장`.

Save failure:

- Preserve text.
- Message: `기록을 저장하지 못했어요. 작성한 내용은 그대로 두었어요.`

Network error:

- `연결이 불안정해요. 다시 시도하면 이어서 저장할 수 있어요.`

### Safe Copy

Use:

- `기록`
- `장면`
- `마음`
- `단서`
- `U-Map에 반영`

Avoid:

- `감정 분석`
- `심리 상태 진단`
- `정상 범위`
- `위험 신호`

## 6. U-Map Detail Screen

Priority: P0

### Purpose

U-Map shows the user's current self-discovery map based on answers and Diary records. It is not a personality radar chart, diagnostic profile, or fixed score.

### Entry Paths

- Home U-Map card
- Question completion `U-Map 반영 보기`
- Diary save feedback
- Signature screen
- Bottom navigation U-Map tab

### Exit Paths

- `다음 질문 보기` -> Question
- `Diary 쓰기` -> Diary write
- `Signature 보기` -> Signature
- Back -> Home or previous screen

### 8 U-Map Axes

1. 에너지 리듬
   - How the user's energy rises, drops, and recovers in current records.
2. 감정 인식
   - How the user notices, names, and handles emotions.
3. 가치 기준
   - What values appear to guide choices and priorities.
4. 선택 방식
   - How the user tends to decide, hesitate, or confirm direction.
5. 관계 흐름
   - How the user experiences closeness, distance, comfort, or tension in relationships.
6. 긴장과 회복
   - What creates pressure and what helps the user recover.
7. 성장 동기
   - What appears to move the user forward or make effort meaningful.
8. 삶의 방향
   - What the user seems to want to build, protect, or move toward.

### UI Structure

- Header:
  - `U-Map`
  - subtitle: `현재 기록에서 보이는 자기이해 흐름이에요.`
- U-Map visualization:
  - show clarity / signal presence, not accuracy
- Axis list:
  - axis name
  - current clarity
  - based-on count: `질문 3개 · Diary 2개`
  - recent clue excerpt
  - next recommended question area
- Data basis section:
  - `이 축에 반영된 기록`
  - answer and Diary references
- Safety note:
  - fixed near bottom or info area

### CTAs

Primary:

- `다음 질문 보기`

Secondary:

- `Diary 쓰기`
- `Signature 보기`
- `단서 자세히 보기`

### Data Accumulation Display

Use:

- `질문 답변에서 2개 단서`
- `Diary에서 1개 단서`
- `아직 이 축은 기록이 적어요`
- `최근 기록에서 조금 더 선명해졌어요`

Avoid:

- `정확도 82%`
- `성격 점수`
- `위험도`
- `정상/비정상`
- `결핍`

### Empty / Low Data State

Title:

- `아직 U-Map을 그릴 기록이 부족해요`

Body:

- `질문에 답하거나 짧은 Diary를 남기면 U-Map의 축들이 조금씩 채워집니다.`

CTA:

- `첫 질문에 답하기`

### Safe Copy

Use:

- `선명도`
- `현재 기록에서 보이는 흐름`
- `반영된 기록`
- `더 기록하면 달라질 수 있음`

Avoid:

- `검사 결과`
- `분석 결과`
- `당신의 성격`
- `정확한 유형`

## 7. Insight / Clue Detail Screen

Priority: P0 if Home shows "오늘 발견된 단서"

### Purpose

When the user taps `오늘 발견된 단서` from Home, the detail screen explains what record-based clue was found, what data it came from, and gives the user control.

The screen must not frame the clue as a final conclusion.

### Entry Paths

- Home `오늘 발견된 단서`
- U-Map axis clue
- Signature evidence item
- Report preview item

### Exit Paths

- Back -> previous screen
- `U-Map에서 보기` -> U-Map detail
- `Diary에 이어쓰기` -> Diary write
- `다음 질문 보기` -> Question

### UI Structure

- Header:
  - overline: `오늘 발견된 단서`
  - title: clue title
- Clue summary:
  - 1-3 sentences
  - tentative language
- Based-on data:
  - source question
  - selected answer
  - Diary excerpt
  - date/time
- Reflected area:
  - U-Map axis names
  - Signature relation if applicable
- User control actions:
  - `수정하기`
  - `숨기기`
  - `동의하지 않음`
  - `신고하기` or `피드백 보내기`

### CTAs

Primary:

- `U-Map에서 보기`

Secondary:

- `Diary에 이어쓰기`
- `다음 질문 보기`

Control actions:

- `수정하기`
- `숨기기`
- `동의하지 않음`

### User Control Behavior

수정하기:

- User can edit the underlying Diary or add a correction note.
- Do not allow editing AI text directly unless product supports user notes.

숨기기:

- Hide this clue from Home.
- Keep underlying record unless user deletes it.

동의하지 않음:

- Record feedback.
- Optional prompt: `어떤 부분이 다르게 느껴졌나요?`

신고하기:

- For harmful, unsafe, offensive, or clearly inaccurate AI output.

### Safe Copy

Use:

- `이 단서는 현재 기록에서 임시로 보이는 흐름이에요.`
- `다르게 느껴진다면 숨기거나 피드백을 남길 수 있어요.`
- `기록이 늘어나면 표현이 달라질 수 있습니다.`

Avoid:

- `AI가 판단한 당신`
- `이것이 당신의 진짜 모습`
- `반드시 인정해야 하는 결과`

## 8. Star / Store Screen

Priority: P1 if paid launch is active; P0 if Store is visible in launch build

### Purpose

Star / Store manages optional paid expansion. It must not block Question, Diary, basic U-Map, Signature, or next-question loop.

Before Google Play Billing is fully connected, the UI may be mock, but it must clearly behave as a non-final or unavailable state in internal builds.

### Entry Paths

- My / Settings: `Star / Store`
- Reports locked card: `확장 리포트 열기`
- Optional Home tertiary entry: `Star 관리`

### Exit Paths

- Back -> previous screen
- Purchase success -> Reports or Store balance refresh
- Purchase cancel/failure -> Store with safe message

### UI Structure

- Star balance:
  - current balance
  - last update
- Purchase packages:
  - Star packs
  - report unlock products
  - optional Plus subscription if PM approves
- Usage history:
  - earned / purchased / spent / refunded
- Billing status:
  - connected / unavailable / mock / pending verification

### Mock UI Before Google Play Billing

Internal build copy:

> Google Play Billing 연결 전 확인용 화면입니다. 실제 결제는 진행되지 않습니다.

Production build rule:

- Do not show mock purchase CTA in production.
- If billing is unavailable, show retry or hide product purchase buttons.

### CTAs

Primary:

- `Google Play로 구매`

Secondary:

- `구매 복원`
- `사용 내역 보기`
- `문의하기`

### Safe Purchase Copy

Use:

- `확장 리포트 열기`
- `기록을 더 길게 정리해보기`
- `Star는 선택 기능에만 사용돼요`
- `질문과 기본 자기탐색은 계속 이어갈 수 있어요`

Avoid:

- `더 정확한 나를 확인`
- `진짜 나를 잠금 해제`
- `결제해야 계속 가능`
- `분석 정확도 상승`

### Error States

Product load failure:

- `Google Play 상품 정보를 불러오지 못했어요.`
- CTA: `다시 시도`

Purchase canceled:

- `구매가 취소됐어요. 언제든 다시 선택할 수 있어요.`

Pending:

- `구매 확인이 진행 중이에요. 완료되면 Star와 권한이 반영됩니다.`

Verification failure:

- `구매 확인에 시간이 걸리고 있어요. 구매 복원 또는 문의하기를 이용해주세요.`

## 9. My / Settings Detail

Priority: P0

### Purpose

My / Settings is the control surface for account, profile, notifications, privacy, data deletion, legal documents, and logout.

It should not become a second Store page.

### Entry Paths

- Bottom navigation My
- Home profile icon
- Store / Reports back path

### Exit Paths

- Back -> previous screen or Home
- Logout -> Auth
- Data deletion -> deletion confirmation / request submitted
- Legal links -> in-app legal or web policy page

### UI Structure

Profile:

- display name
- email if available
- avatar if available
- edit profile P1

Notification settings:

- question reminder toggle
- Diary reminder toggle
- marketing toggle only if legally approved

Privacy / data:

- privacy policy
- data deletion
- account deletion
- AI limitations / disclaimer

Legal:

- terms
- privacy policy
- disclaimer
- refund policy if paid features ship

Account:

- logout
- app version

### CTAs

Primary:

- none; Settings is not a conversion screen

Important actions:

- `개인정보처리방침`
- `데이터 삭제 요청`
- `계정 삭제`
- `로그아웃`

### Data Deletion Copy

If request-based:

> 계정과 개인 데이터 삭제를 요청합니다. 답변, Diary, U-Map, Signature, 리포트, 관계 기록이 삭제 대상에 포함될 수 있습니다. 처리 전 본인 확인 또는 보존 의무 확인이 필요할 수 있습니다.

If immediate deletion:

> 계정과 개인 데이터가 삭제됩니다. 이 작업은 되돌릴 수 없습니다.

PM must choose one policy before Play submission.

### Safe Copy

Use:

- `내 기록 관리`
- `데이터 삭제`
- `AI 요약의 한계`
- `개인정보`

Avoid:

- `분석 초기화로 정확도 개선`
- `성격 데이터 삭제`
- `진단 기록`

## 10. Empty / Loading / Error State Standard

Priority: P0

### Question None

Title:

- `지금은 이어갈 질문이 없어요`

Body:

- `오늘의 기록을 조금 더 남기면 다음 질문을 자연스럽게 이어갈 수 있어요.`

CTA:

- `Diary 쓰기`
- `다시 불러오기`

### Diary None

Title:

- `아직 남긴 Diary가 없어요`

Body:

- `한 문장도 괜찮아요. 지금 떠오르는 장면이나 마음을 남기면 U-Map의 단서가 됩니다.`

CTA:

- `첫 Diary 쓰기`

### U-Map Low Data

Title:

- `U-Map을 그릴 기록이 조금 더 필요해요`

Body:

- `질문 답변과 Diary가 쌓이면 8개 축의 흐름이 천천히 채워집니다.`

CTA:

- `질문에 답하기`
- `Diary 쓰기`

### Network Error

Title:

- `연결이 불안정해요`

Body:

- `기록을 불러오지 못했어요. 잠시 후 다시 시도해주세요.`

CTA:

- `다시 시도`

### Save Failure

Title:

- `저장하지 못했어요`

Body:

- `작성한 내용은 그대로 두었어요. 연결 상태를 확인하고 다시 저장해주세요.`

CTA:

- `다시 저장`

### Loading

Use calm, specific loading labels:

- `질문을 준비하고 있어요`
- `Diary를 불러오고 있어요`
- `U-Map에 기록을 반영하고 있어요`
- `Star 정보를 확인하고 있어요`

Avoid:

- `분석 중`
- `진단 중`
- `성격 계산 중`

## 11. Android 1차 출시 Priorities

### P0 - Must Ship

- Question answer screen with choice/text/combined support
- Question save and clue feedback screen
- Diary write detail with emotion tags and save
- U-Map detail with 8 axes and low-data state
- Insight/clue detail if Home exposes clue cards
- My/Settings with privacy, deletion, legal, logout
- Empty/loading/error states
- Safe copy across all AI/reflection surfaces

### P1 - Ship If Paid/Secondary Scope Is Active

- Star / Store with Google Play Billing states
- Star usage history
- Purchase restore
- Report unlock return flow
- Insight hide / disagree / feedback actions
- Notification settings

### P2 - Defer

- Advanced insight editing
- Rich U-Map history timeline
- Complex relation graph
- Social sharing
- Friend invite
- Compatibility features
- Gamified streak pressure
- Advanced report marketplace

## 12. QA Checklist

- A user can start a real question from Home.
- Answer UI does not look like a test.
- Saving an answer shows clue feedback, not instant diagnosis.
- Diary can be written from Diary Home and after Question completion.
- U-Map shows 8 axes as record-based flows.
- U-Map low-data state is clear and not broken.
- Insight detail shows source records and user control.
- Star/Store does not block the core loop.
- Settings includes privacy, deletion, legal, logout.
- All save failures preserve input.
- No screen says diagnosis, type, compatibility, therapy, treatment, or accuracy.

## 13. PM Report Summary

This screen bundle should strengthen the core FI-YOU loop by making every action feel like:

1. leave a record,
2. notice a clue,
3. see it reflected in U-Map,
4. continue the self-discovery journey.

The launch UX should not over-explain AI or over-sell paid features. Android 1차 출시 should prioritize reliable flow, honest empty states, safe language, and user control over clues.
