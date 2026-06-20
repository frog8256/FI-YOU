# FI-YOU Release UI System Worklist

## 0. 목적

이 문서는 FI-YOU Flutter Android 앱의 UI 완성도를 출시 기준으로 끌어올리기 위한 Visual/UI System 작업 리스트다. 속도보다 완성도가 중요하며, 모든 항목은 Flutter App Lead가 바로 구현 우선순위를 잡을 수 있도록 P0/P1/P2로 분류한다.

현재 전제:

- Home / Diary / Explore / U-Map / My / Store / Settings / Question Flow 골격은 존재한다.
- Auth/Onboarding, Insight 상세, 공통 상태 화면, 상세/수정/삭제 플로우, Store/Settings 실제 상태 UI는 부족하다.
- 탐구 아이콘은 Spark / 별빛 방향을 유지한다.
- FI-YOU는 진단/성격유형 앱이 아니라 기록 기반 self-discovery 앱이다.

## 1. 출시용 UI Baseline

### 1.1 Visual Principles

- 다크 네이비 기반 유지
- premium, calm, usable
- 과한 우주/판타지 금지
- Signal / Node / Discovery / Map 감각 유지
- Glow는 active, CTA, Star, 저장 성공 같은 기능 강조에만 사용
- Spark 아이콘은 “탐구/발견” 의미로 쓰되, Star 재화와 혼동되지 않도록 색상과 문맥을 분리한다.

### 1.2 Color Baseline

| Token | Hex | 사용 |
| --- | --- | --- |
| `background.base` | `#050714` | 앱 전체 배경 |
| `background.depth` | `#070B1A` | 화면 하단/스크롤 깊이 |
| `surface.base` | `#0B1020` | 기본 카드 |
| `surface.elevated` | `#11182B` | 주요 카드 |
| `surface.map` | `#0D1326` | U-Map / 지도 |
| `surface.insight` | `#10172A` | Insight / 단서 |
| `surface.action` | `#0B1722` | 질문 / CTA |
| `surface.compact` | `#0C1222` | 리스트 / 상태 |
| `surface.modal` | `#10172A` | bottom sheet / dialog |
| `surface.nav` | `#070B18` | bottom nav |
| `border.subtle` | `#1A2440` | 기본 border |
| `border.visible` | `#273556` | 주요 card border |
| `text.primary` | `#FFFFFF` | 제목 |
| `text.secondary` | `#B7C0D7` | 본문 |
| `text.muted` | `#7F8AA6` | 보조 정보 |
| `primary.purple` | `#8B5CF6` | U-Map, active |
| `accent.cyan` | `#7DD3FC` | 질문, signal |
| `accent.gold` | `#F7C948` | Star 재화 |
| `accent.spark` | `#F8D878` | 탐구 spark, 발견된 단서 |
| `accent.mint` | `#6EE7B7` | 저장 성공, 반영됨 |
| `accent.red` | `#FB7185` | 오류, 삭제 |

Spark와 Star 분리:

- Star 재화: gold coin/badge, `accent.gold`, 숫자/잔액 중심
- 탐구 Spark: 작고 가벼운 별빛 표시, `accent.spark`, 단서/발견 맥락
- 같은 카드 안에서 Star와 Spark를 동시에 쓰지 않는다.

### 1.3 Card Baseline

P0 기준:

- 모든 카드 radius, padding, border, fill을 토큰화한다.
- 밝은 회색 glass box 금지. white overlay는 3-6% 이내.
- 카드 역할별 surface variant 필수:
  - `map`
  - `insight`
  - `action`
  - `compact`
  - `modal`
  - `danger`

권장:

- Primary card radius: 24dp
- Secondary card radius: 20dp
- Compact/list card radius: 16-18dp
- Card padding: 16-20dp
- Border: `border.subtle` 50-80%, primary card는 `border.visible`

### 1.4 Button Baseline

| Type | 용도 | 기준 |
| --- | --- | --- |
| Primary CTA | 저장, 질문 시작, 구매 | 52dp height, 14-16dp radius, strong label |
| Secondary CTA | 보기, 더보기 | outline or tonal, 48dp height |
| Text action | 숨김, 나중에 | no card, muted text |
| Danger action | 삭제, 계정 삭제 | red text/outline, full red fill 금지 |
| Round CTA | 다음 질문 | 56-68dp, cyan/purple signal |

### 1.5 Input Baseline

- TextField fill: `surface.compact`
- focused border: cyan 40-50%
- error border: red 45%
- label: `text.secondary`
- hint: `text.muted`
- multiline input은 min height를 명확히 둔다.
- 키보드가 bottom CTA를 가리지 않도록 inset 대응 필수.

### 1.6 Chip Baseline

- 28-34dp height
- pill radius 999
- single-line only
- selected chip은 fill 10-14%, border 30-45%
- 긴 한국어는 줄바꿈하지 않고 축약 문구를 사용한다.

### 1.7 Modal / Bottom Sheet Baseline

- Android 기준 bottom sheet 우선
- background: `surface.modal`
- top handle
- radius top 24dp
- destructive action은 2-step confirmation
- keyboard 대응 필수

### 1.8 Bottom Navigation Baseline

- tabs: Home / Explore / Diary / U-Map / My
- active: chip + icon/text color + subtle glow
- inactive: muted
- nav fill: `surface.nav`
- height: 72-78dp
- SafeArea 적용

### 1.9 Header Baseline

- screen title 24-28sp
- subtitle 15-16sp, max 2 lines
- icon button 44-48dp
- trailing actions는 최대 2개

### 1.10 State Card Baseline

- Empty: 시작 상태처럼 표현
- Loading: skeleton + 짧은 copy
- Error: 재시도 CTA
- Save failed: 작성 내용 보존 안내 필수

## 2. P0 / P1 / P2 우선순위

### P0: 출시 전 필수

- Auth/Onboarding 정상 한국어 UI와 브랜드 첫인상 정리
- 공통 Empty / Loading / Error / Save failed 상태 통일
- Diary 작성/상세/수정/삭제 플로우 완성
- Question Flow 선택형/서술형/복합형 overflow 방지
- Store 결제 중/실패/복원/사용 내역 상태 UI
- Settings 로그아웃/계정삭제/데이터삭제 confirmation UI
- Insight 상세에서 수정/숨김/동의하지 않음 제공
- Android 작은 화면, 키보드, bottom CTA 겹침 QA
- 모든 한국어 문구 mojibake 제거

### P1: 출시 완성도

- U-Map 8축 상세와 축별 기록 흐름 UI
- Explore/Insight 리스트와 상세 연결성 개선
- Home 카드 색상/계층 최종 polish
- Bottom Navigation active/inactive 상태 정리
- Star와 Spark 시각 의미 분리
- 리스트 empty state와 skeleton loading 확장
- 상세 화면 header/back/overflow 메뉴 패턴 통일

### P2: 출시 후 또는 polish

- U-Map 축 transition micro motion
- 단서 피드백 success motion
- Store 패키지 추천 badge 실험
- Settings profile card polish
- Insight feedback reason chips 고도화
- accessibility label 세부 개선

## 3. 화면별 UI 요구사항

## 3.1 Home

현재 골격은 유지한다.

부족 항목:

- 카드/박스 색상이 밝게 뜨거나 단조로운 경우 surface variant 적용
- Star badge와 spark icon 의미 분리
- 작은 Android 화면에서 U-Map card가 과도하게 길어지는 문제 점검
- Today Insight 일부가 bottom nav에 가려지는지 확인

요구사항:

- U-Map Progress는 `surface.map`
- Today Insight는 `surface.insight`
- Next Question은 `surface.action`
- Daily Activity는 `surface.compact`
- Home copy는 단정 금지, `단서`, `흐름`, `선명도` 중심

## 3.2 Explore

부족 항목:

- Explore가 단순 목록이면 Home과 역할 차이가 약하다.
- Insight, 질문, U-Map 탐구 경로가 섞이면 사용자가 다음 행동을 알기 어렵다.

요구사항:

- 상단에 `오늘 이어볼 탐구` section
- Insight feed
- Question recommendation
- U-Map unclear axes shortcuts
- list item은 source/date/tag를 표시

컴포넌트:

- ExploreHeader
- ExplorePathCard
- InsightFeedCard
- AxisShortcutChip
- ContinueQuestionCard

## 3.3 Question Flow

부족 항목:

- 선택형/서술형/복합형 상태별 레이아웃 통일 필요
- 선택지 긴 한국어 overflow 위험
- 저장 실패/임시 저장 상태 부족

P0 요구사항:

- Question progress strip
- Question card
- Answer area
- Optional note
- Sticky bottom CTA
- Save failed inline card

카피:

- `정답이 아니라, 지금 가장 가까운 쪽을 남겨주세요.`
- `한 문장도 충분해요.`
- `이 답변을 기록에 반영할게요.`

## 3.4 Diary

부족 항목:

- 상세/수정/삭제 플로우 부족
- 긴 글 입력 시 keyboard와 CTA 충돌 가능
- 저장 실패 시 작성 내용 보존 안내 필요

P0 요구사항:

- Diary list empty
- Diary detail
- Diary edit
- Delete confirmation sheet
- Save failed state

Diary detail:

- title/date
- body
- tags
- linked question
- reflected insights
- actions: edit, delete

Diary edit:

- title optional
- body required
- helper prompt
- save CTA
- draft preserved behavior

삭제:

- bottom sheet
- `이 기록을 삭제할까요?`
- body: `삭제하면 이 기록에서 연결된 단서도 다시 계산될 수 있어요.`

## 3.5 U-Map

부족 항목:

- 8개 축 상세와 축별 기록 근거 흐름 필요
- 단정적 점수 UI처럼 보일 위험
- 축별 “왜 이렇게 보이는지” 확인 경로 필요

P1 요구사항:

- Overview map
- 8 axis grid/list
- Axis detail
- Evidence / record flow
- Next question suggestion

8개 축:

- 에너지 리듬
- 회복 방식
- 관계 거리
- 감정 신호
- 선택 기준
- 몰입 조건
- 갈등 반응
- 성장 방향

축 상세:

- clarity
- recent signals
- related diary/answers
- timeline
- `다음에 살펴볼 질문`

## 3.6 Insight

부족 항목:

- Insight 상세 화면 필요
- 기반 데이터 확인 부족
- AI 해석에 대한 사용자 통제권 부족

P0 요구사항:

- Insight detail
- Based data
- U-Map reflected axes
- 수정하기
- 숨기기
- 동의하지 않음

카피:

- `이 단서는 확정된 판단이 아니에요.`
- `기록과 다르게 느껴진다면 조정할 수 있어요.`
- `동의하지 않음으로 표시하면 다음 분석에서 참고해요.`

## 3.7 Store

부족 항목:

- 구매/실패/복원 상태 UI 부족
- 사용 내역 부족
- Star와 탐구 spark 의미 혼동 가능

P0 요구사항:

- balance card
- package cards
- purchase verifying
- purchase failed
- purchase success
- restore purchases
- usage history
- mock payment state in dev only

Star 표현:

- 재화는 gold coin/badge 중심
- 발견 spark는 card decoration 또는 insight marker로만 사용
- Store에서는 spark 장식 최소화

상태 카피:

- `Google Play 결제를 확인하는 중이에요.`
- `결제가 완료됐어요. Star가 반영됐습니다.`
- `결제를 확인하지 못했어요. 다시 시도해주세요.`
- `구매 내역을 복원했어요.`

## 3.8 My

부족 항목:

- My가 Settings와 섞이면 정보 구조가 흐려진다.
- 개인 탐구 기록 요약과 앱 설정을 분리해야 한다.

요구사항:

- profile summary
- U-Map / Signature shortcuts
- Star balance
- recent insights
- account/settings entry

## 3.9 Settings

부족 항목:

- 계정삭제/로그아웃/데이터삭제 confirmation 부족
- 약관/개인정보/면책 문서 상태 부족
- 알림 권한 상태 UI 부족

P0 요구사항:

- settings section cards
- notification toggle / permission state
- privacy/legal links
- logout confirmation
- account deletion request
- data deletion notice

계정삭제:

- destructive bottom sheet
- red outline action
- body는 명확하게:
  - `계정과 기록 삭제 요청을 보낼까요?`
  - `요청 후 처리 과정에서 되돌리기 어려울 수 있어요.`

## 3.10 Auth / Onboarding

부족 항목:

- 출시 첫인상 화면인데 현재 완성도가 부족하면 앱 신뢰가 떨어진다.
- 로그인 실패/권한/로딩/약관 동의 UI 필요
- Onboarding에서 FI-YOU가 진단 앱이 아님을 분명히 해야 한다.

P0 요구사항:

Auth:

- brand mark
- title: `FI-YOU`
- subtitle: `기록이 쌓이면 나를 이해하는 지도가 선명해져요.`
- email / Google login
- loading
- error
- legal agreement

Onboarding:

- 3-step 또는 single scroll
- `사람은 정의하는 것이 아니라 발견하는 것이다.`
- U-Map preview
- name input
- notification opt-in optional
- start CTA

## 4. 새로 필요한 화면 구성안

### 4.1 Auth / Onboarding

P0:

- AuthScreen
- AuthErrorState
- OnboardingIntro
- OnboardingNameStep
- OnboardingComplete

구성:

- dark background
- compact brand area
- primary auth card
- legal links
- error inline card

### 4.2 Insight 상세

P0:

- InsightDetailScreen
- BasedDataSection
- RelatedAxisSection
- InsightActionSheet
- DisagreeReasonSheet

구성:

- insight main card
- 기반 데이터 list
- U-Map 반영 axes
- 수정 / 숨김 / 동의하지 않음

### 4.3 Diary 상세 / 수정 / 삭제

P0:

- DiaryDetailScreen
- DiaryEditScreen
- DiaryDeleteSheet
- SaveFailedCard

구성:

- read mode
- edit mode
- delete confirmation
- linked insight preview

### 4.4 U-Map 축 상세 / 근거 상세

P1:

- UMapAxisDetailScreen
- AxisEvidenceTimeline
- EvidenceDetailSheet
- NextQuestionSuggestion

구성:

- selected axis header
- clarity
- records timeline
- related signals
- next question

### 4.5 Store 구매 / 실패 / 복원

P0:

- PurchaseStatusBanner
- PurchaseFailureSheet
- RestorePurchasesRow
- UsageHistoryList
- MockPaymentStateCard

구성:

- balance card
- package cards
- status banner
- usage history

### 4.6 Settings 계정삭제 / 로그아웃 / 데이터삭제

P0:

- LogoutConfirmSheet
- AccountDeletionSheet
- DataDeletionNotice
- LegalDocumentScreen

구성:

- sectioned settings list
- destructive confirmation
- request sent success state

## 5. 공통 빈 / 로딩 / 오류 상태 규칙

### Empty

- 실패처럼 보이지 않게 한다.
- title은 시작 상태를 설명한다.
- CTA는 다음 행동 하나만 강조한다.

예:

- `아직 남긴 기록이 없어요`
- `첫 기록을 남기면 U-Map이 조금씩 선명해져요.`
- CTA: `기록 시작하기`

### Loading

- skeleton card 우선
- full-screen spinner는 초기 앱 부팅 외에는 최소화
- copy는 짧게

예:

- `기록의 흐름을 불러오는 중이에요`

### Error

- 사용자 탓 금지
- retry 제공
- red는 일부만

예:

- `화면을 불러오지 못했어요`
- `연결 상태를 확인한 뒤 다시 시도해주세요.`

### Save Failed

- 작성 내용 보존 문구 필수

예:

- `저장하지 못했어요`
- `작성한 내용은 이 화면에 남아 있어요. 다시 시도해주세요.`

## 6. Android 작은 화면 기준

P0 QA 기준:

- 360dp width에서 모든 핵심 CTA 접근 가능
- keyboard open 상태에서 input과 save CTA가 가려지지 않음
- bottom nav가 스크롤 콘텐츠를 덮지 않음
- 긴 한국어 title은 최대 2줄
- body는 카드 안에서 최대 3-4줄 후 상세로 이동
- chip은 1줄, overflow 시 짧은 label로 변경
- icon button touch target 44dp 이상
- primary CTA 48dp 이상
- list row 56dp 이상

금지:

- FittedBox로 본문 전체를 억지 축소
- 버튼 텍스트가 2줄로 터지는 상태
- fixed height card에 긴 한국어를 넣어 overflow 발생
- keyboard가 닫히지 않으면 저장할 수 없는 플로우

## 7. Flutter App Lead 구현 체크리스트

### P0 Checklist

- [ ] Theme token class 정리
- [ ] `FiYouGlassCard` variants 구현
- [ ] `FiYouButton` primary/secondary/danger 구현
- [ ] `FiYouTextField` single/multiline 구현
- [ ] `FiYouChip` selected/muted 구현
- [ ] `FiYouBottomSheet` 공통 구현
- [ ] `StateBlock` Empty/Loading/Error/SaveFailed 구현
- [ ] Auth/Onboarding 출시 UI 구현
- [ ] Question Flow 3 type 구현
- [ ] Diary detail/edit/delete 구현
- [ ] Insight detail + feedback actions 구현
- [ ] Store purchase state/restore/history 구현
- [ ] Settings destructive action sheets 구현
- [ ] 작은 Android 화면 QA
- [ ] 한국어 mojibake 전수 확인

### P1 Checklist

- [ ] U-Map 8-axis detail 구현
- [ ] Axis evidence timeline 구현
- [ ] Explore feed hierarchy 정리
- [ ] Home surface polish
- [ ] Bottom nav selected state polish
- [ ] Star/Spark icon usage audit
- [ ] skeleton loading 확대 적용

### P2 Checklist

- [ ] micro motion
- [ ] accessibility label 세부 보강
- [ ] Insight feedback reason chips 고도화
- [ ] Store recommendation badge
- [ ] Settings profile polish

## 8. 구현 우선순위

1. UI baseline 토큰과 공통 컴포넌트
2. Auth/Onboarding
3. Question Flow
4. Diary 상세/수정/삭제
5. 공통 상태 화면
6. Insight 상세/피드백 액션
7. Store 결제 상태/복원/내역
8. Settings 계정 액션
9. U-Map 축 상세/근거 상세
10. Explore feed polish
11. Home/Bottom nav 최종 polish

## 9. PM 보고 요약

출시 기준 UI 완성도를 위해 가장 먼저 해야 할 일은 새 화면을 더 만드는 것이 아니라, 공통 baseline을 확정하는 것이다.

P0의 핵심:

- Auth/Onboarding 첫인상
- Question/Diary 입력 안정성
- Insight 상세와 사용자 통제권
- Store/Settings 실제 상태 UI
- Empty/Loading/Error/Save failed 통일
- 작은 Android 화면 overflow 제거

FI-YOU의 문체는 계속 조심스럽고 비단정적이어야 한다. 사용자는 “판정 결과”를 받는 것이 아니라, 자신의 기록에서 발견된 단서와 흐름을 확인한다.
