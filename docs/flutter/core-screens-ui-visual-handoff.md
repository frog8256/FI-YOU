# FI-YOU Core Screens UI / Visual System Handoff

## 0. 목적

이 문서는 FI-YOU Android 앱의 Home 이후 핵심 화면 묶음을 Flutter App Lead가 바로 구현할 수 있도록 정리한 UI Design / Visual System 명세다.

FI-YOU는 MBTI, 성격유형, 진단 앱이 아니다. 모든 화면은 사용자를 정의하거나 판정하지 않고, 사용자의 질문 답변과 Diary 기록에서 발견되는 단서, 흐름, U-Map 반영 과정을 보여준다.

## 1. 전체 시각 방향

### Product Tone

- Dark navy 기반 premium AI self-discovery
- 보라, 시안, 골드 포인트
- Glass card, 절제된 glow
- 과도한 우주/판타지 장식 금지
- Signal / Node / Discovery / Map 느낌
- 분석 결과처럼 단정하지 않고, 기록 기반의 조심스러운 관찰 톤 유지

### Core Tokens

Home v2 토큰을 그대로 사용한다.

| Token | Hex | 용도 |
| --- | --- | --- |
| `background.base` | `#050714` | 앱 전체 배경 |
| `background.depth` | `#070B1A` | 스크롤 하단 깊이 |
| `surface.base` | `#0B1020` | 기본 카드 |
| `surface.elevated` | `#11182B` | 주요 카드 상단 |
| `surface.map` | `#0D1326` | U-Map / Map 관련 카드 |
| `surface.insight` | `#10172A` | Insight / 단서 카드 |
| `surface.action` | `#0B1722` | 질문 / CTA 카드 |
| `surface.compact` | `#0C1222` | 요약 / 리스트 카드 |
| `surface.nav` | `#070B18` | Bottom navigation |
| `border.subtle` | `#1A2440` | 기본 border |
| `border.visible` | `#273556` | 주요 카드 border |
| `text.primary` | `#FFFFFF` | 제목 |
| `text.secondary` | `#B7C0D7` | 본문 |
| `text.muted` | `#7F8AA6` | 보조 정보 |
| `primary.purple` | `#8B5CF6` | U-Map, active |
| `primary.soft` | `#C4B5FD` | active text |
| `accent.cyan` | `#7DD3FC` | 질문, action, signal |
| `accent.gold` | `#F7C948` | Star, 발견된 단서 |
| `accent.mint` | `#6EE7B7` | 저장 완료, 반영됨 |
| `accent.red` | `#FB7185` | 오류, 삭제, 숨김 |

### Typography

| Role | Size | Weight | Line height | Usage |
| --- | --- | --- | --- | --- |
| Screen title | 24-28sp | 800-900 | 1.22 | 화면 상단 제목 |
| Section title | 18-20sp | 800 | 1.3 | 카드/섹션 제목 |
| Card title | 17-19sp | 700-800 | 1.35 | 카드 내부 제목 |
| Question text | 22-26sp | 600-700 | 1.42 | 질문 본문 |
| Body | 15-16sp | 400-500 | 1.55 | 설명, 기록 |
| Caption | 12-13sp | 500-700 | 1.45 | 메타, 상태 |
| Button | 15-16sp | 800 | 1.2 | CTA |

한국어 긴 문구는 `height` 1.45 이상을 기본으로 한다. 카드 안에서 큰 제목과 본문이 동시에 있을 때는 제목은 2줄, 본문은 3줄까지 허용하고 이후는 상세 화면으로 보낸다.

### Spacing

| Item | Value |
| --- | --- |
| Screen horizontal padding | 20-22dp |
| Screen top padding after safe area | 16-22dp |
| Card radius | 20-24dp |
| Compact card radius | 16-18dp |
| Card padding | 16-20dp |
| Section gap | 18-22dp |
| Card internal gap | 10-14dp |
| Button height | 48-54dp |
| Icon touch target | 44-48dp |

### Card Hierarchy

1. Primary map/action card: `surface.map` or `surface.action`, 24dp radius, visible border, subtle glow.
2. Insight card: `surface.insight`, 20-24dp radius, low glow, readable text.
3. Compact list card: `surface.compact`, 16-20dp radius, minimal glow.
4. Inline chip: transparent surface + border, no shadow.

Card fill은 밝은 회색처럼 보이지 않아야 한다. 넓은 white overlay는 3-6%만 사용한다.

## 2. 공통 컴포넌트

### `FiYouScaffold`

- `AppBackground`
- `SafeArea`
- scrollable body
- optional bottom navigation
- keyboard-safe bottom inset

### `FiYouHeader`

- overline chip optional
- title
- subtitle
- trailing icon buttons
- 큰 화면 설명은 최대 2줄

### `FiYouGlassCard`

- role 기반 surface variant:
  - `map`
  - `insight`
  - `action`
  - `compact`
  - `danger`
- props:
  - `padding`
  - `onTap`
  - `selected`
  - `disabled`
  - `semanticLabel`

### `SignalIconPanel`

- rounded square or circle
- color variant: purple, cyan, gold, mint, red
- icon + subtle inner glow

### `FiYouPill`

- small metadata chip
- no large shadows
- max 1 line, ellipsis

### `PrimaryCta`

- 48-54dp height
- rounded 14-16dp or pill
- label + optional trailing arrow

### `RoundCta`

- question start / next action
- 56-68dp
- cyan or purple radial fill

### `StateBlock`

- Empty / Loading / Error / Save failed 공통
- card or centered block
- icon, title, body, action

## 3. 화면별 명세

## 3.1 질문 답변 화면

질문 답변은 FI-YOU의 가장 중요한 입력 화면이다. 사용자가 평가받는 느낌이 아니라, 오늘의 단서를 하나 남기는 느낌이어야 한다.

### 공통 레이아웃

상단에서 하단 순서:

1. Header
   - overline: `오늘의 질문`
   - title: 질문 카테고리 또는 짧은 맥락
   - subtitle: `정답을 고르는 화면이 아니라, 지금 가장 가까운 쪽을 남기는 화면이에요.`
2. Progress strip
   - `질문 1/3`
   - estimated time
   - small linear progress
3. Question card
4. Answer area
5. Optional note area
6. Bottom sticky action

### 선택형

Question card:

- surface: `surface.action`
- border: cyan 22-30%
- icon: question / signal node
- question text 22-26sp

Choice list:

- vertical list
- item height 최소 56dp
- unselected:
  - fill `surface.compact`
  - border `border.subtle`
  - text `text.secondary`
- selected:
  - fill cyan 8-10%
  - border cyan 45%
  - left radio selected icon cyan
  - optional small signal hint chip

CTA:

- disabled: `text.muted`, border subtle
- enabled: cyan/purple gradient
- label: `이 답변 남기기`

카피 예시:

- 질문: `갈등 상황에서 나는 어떤 반응을 보일까?`
- 선택지:
  - `잠시 거리를 두고 생각을 정리한다`
  - `바로 대화해서 풀고 싶어진다`
  - `상대의 감정을 먼저 살핀다`
  - `내 입장을 분명히 말하려 한다`

### 서술형

레이아웃:

- Question card
- Text input card
- Reflection helper chips
- Sticky save CTA

Input:

- minLines 6
- maxLines 12
- fill `surface.compact`
- focused border cyan 45%
- placeholder는 부담을 낮추는 문장

카피:

- placeholder: `떠오르는 장면이나 감정을 짧게 적어도 괜찮아요.`
- helper: `한 문장도 충분해요.`
- CTA: `기록으로 남기기`

### 복합형

선택형 + 서술형을 한 화면에 넣되, 작은 Android 화면에서 overflow가 나지 않게 단계형으로 배치한다.

권장 구조:

1. 선택 카드 3-4개
2. `조금 더 적어볼까요?` optional text area
3. bottom CTA

서술 입력은 접힌 상태로 시작 가능:

- collapsed label: `이유를 덧붙이고 싶어요`
- expanded input: 4-6 lines

## 3.2 단서 발견 피드백 화면

답변 또는 Diary 저장 후 보여주는 짧은 피드백 화면이다. 결과 발표처럼 보이면 안 된다. “방금 남긴 기록에서 이런 단서가 보였어요” 톤을 유지한다.

### 레이아웃

1. Success signal
   - mint or gold icon
   - small pulse, no large celebration
2. Main card
   - title: `새 단서가 발견됐어요`
   - body: 발견된 단서 요약
   - confidence note
3. U-Map reflection strip
   - affected axis
   - small progress change
4. Actions
   - primary: `U-Map에서 보기`
   - secondary: `Diary로 이동`
   - tertiary text: `나중에 볼게요`

### 색상

- main surface: `surface.insight`
- icon: gold
- U-Map strip: `surface.map`
- 반영됨 chip: mint 12%, text mint

### 카피 예시

- `새 단서가 발견됐어요`
- `혼자 생각을 정리하는 시간이 회복에 도움이 되는 흐름이 보여요.`
- `아직 확정된 결과가 아니라, 지금까지의 기록에서 보이는 단서예요.`
- `U-Map의 회복 방식 축에 반영됐어요.`

## 3.3 Diary 작성 상세 화면

Diary는 긴 글 작성 앱처럼 무겁지 않아야 한다. 질문 답변 이후 자연스럽게 이어지는 “짧은 기록” 화면이다.

### 레이아웃

1. Header
   - title: `오늘의 기록`
   - subtitle: `정리된 글이 아니어도 괜찮아요. 지금 남는 장면을 적어주세요.`
2. Prompt memory card
   - 직전 질문/선택 표시
   - collapsible
3. Title input optional
4. Body input
5. Mood / signal chips optional
6. Save status row
7. Bottom CTA

### Input 지침

Title:

- single line
- optional
- placeholder: `제목을 붙인다면`

Body:

- min height 260dp
- max lines unlimited within scroll
- placeholder: `오늘 기억나는 장면, 감정, 대화를 그대로 적어보세요.`

### 상태

- 저장 중: bottom CTA loading + `저장하는 중이에요`
- 저장 완료: mint small toast `기록이 저장됐어요`
- 저장 실패: inline error card + retry

### 색상

- writing card: `surface.elevated`
- prompt card: `surface.action` with cyan subtle border
- save success: mint
- save failed: red, but full red card 금지

## 3.4 U-Map 상세 화면

U-Map 상세는 FI-YOU의 정체성 화면이다. 8개 축과 축별 기록 흐름을 보여주되, 사용자를 유형화하지 않는다.

### 8개 축 제안

1. 에너지 리듬
2. 회복 방식
3. 관계 거리
4. 감정 신호
5. 선택 기준
6. 몰입 조건
7. 갈등 반응
8. 성장 방향

### 레이아웃

1. Header
   - title: `U-Map`
   - subtitle: `지금까지의 기록에서 보이는 자기 이해의 지도예요.`
2. Overview map card
   - radar / radial / node map
   - overall clarity
   - `최근 반영: 방금 전`
3. Axis summary grid
   - 2 columns on wide phone, 1 column on narrow phone
   - each axis card
4. Selected axis detail
   - axis title
   - clarity
   - recent signals
   - record timeline
   - next question suggestion

### Axis Card

구성:

- icon
- axis label
- clarity percent
- one-line summary
- recent signal count

색상:

- card fill: `surface.map`
- active axis border: purple 55%
- low clarity axis border: `border.subtle`
- growth/movement indicator: mint or cyan

문구:

- `선명도 42%`
- `최근 기록 6개에서 반복적으로 보여요`
- `아직 더 살펴볼 여지가 있어요`

### Axis Timeline

축별 기록 흐름은 “증거 목록”이 아니라 “기록 흐름”으로 표현한다.

Timeline item:

- date
- source: 질문 / Diary
- short excerpt
- reflected signal chip

카피:

- `이 축에 반영된 기록`
- `최근 이 흐름을 만든 단서`
- `다음에 살펴볼 질문`

## 3.5 Insight / 단서 상세 화면

사용자가 AI 해석에 대해 통제권을 가져야 한다. 수정, 숨김, 동의하지 않음이 중요하다.

### 레이아웃

1. Header
   - title: `단서 상세`
   - subtitle: `기록에서 발견된 흐름을 확인하고 조정할 수 있어요.`
2. Insight main card
   - title
   - summary
   - confidence note
3. Based data section
   - related diary entries
   - related answers
   - date/source chips
4. U-Map reflected axes
5. User controls
   - `수정하기`
   - `숨기기`
   - `동의하지 않음`
6. Feedback note

### 색상

- insight card: `surface.insight`
- based data cards: `surface.compact`
- control buttons:
  - 수정: cyan outline
  - 숨김: muted outline
  - 동의하지 않음: red outline, no heavy danger fill

### 카피

- `이 단서는 확정된 판단이 아니에요.`
- `내 기록과 다르게 느껴진다면 조정할 수 있어요.`
- `동의하지 않음으로 표시하면 다음 분석에서 참고해요.`

### Interaction

수정하기:

- modal bottom sheet
- editable label/summary
- save CTA

숨기기:

- confirmation bottom sheet
- `이 단서를 홈과 U-Map 요약에서 숨길까요?`

동의하지 않음:

- reason chips optional
- `내 기록과 맞지 않아요`
- `표현이 너무 단정적이에요`
- `중요하지 않은 단서예요`

## 3.6 Star / Store 화면

Store는 과한 판매 페이지처럼 보이면 안 된다. 사용자가 필요한 만큼 확장 분석을 열어보는 도구 화면이어야 한다.

### 레이아웃

1. Header
   - title: `Star`
   - subtitle: `필요할 때 더 깊은 분석을 열어볼 수 있어요.`
2. Balance card
   - current balance
   - last update
   - use guide
3. Package list
   - Star 100
   - Star 300
   - U-Map deep report
   - Signature deep report
   - Plus option if needed
4. Mock payment status
   - loading / verifying / success / failed
5. Usage history
   - date
   - item
   - amount
   - status

### 색상

- balance card: deep gold surface
  - fill `#171420`
  - border gold 25%
  - glow gold 10%
- product card:
  - fill `surface.compact`
  - selected/recommended border purple 40%
- payment state:
  - verifying: cyan
  - success: mint
  - failed: red

### 카피

- `보유 Star`
- `더 깊은 U-Map 리포트에 사용할 수 있어요.`
- `Google Play 결제를 확인하는 중이에요.`
- `결제가 완료됐어요. Star가 반영됐습니다.`
- `결제를 확인하지 못했어요. 잠시 후 다시 시도해주세요.`

### Mock 결제 상태

개발/QA에서는 mock state를 명확히 노출한다.

- `Mock 결제 대기`
- `Mock 검증 중`
- `Mock 결제 완료`
- `Mock 결제 실패`

단, 출시 빌드에서는 mock 문구가 나오면 안 된다.

## 3.7 My / Settings 상세

설정 화면은 조용하고 신뢰감 있어야 한다. 카드가 너무 많아 보이면 피로하므로 group section 중심으로 구성한다.

### 레이아웃

1. Profile summary
   - avatar / brand mark
   - display name
   - account state
2. My discovery
   - U-Map
   - Signature
   - Insights
   - Star
3. App settings
   - 알림
   - 언어
   - 앱 정보
4. Privacy / Legal
   - 개인정보 처리방침
   - 약관
   - 주의 및 면책
5. Account actions
   - 로그아웃
   - 계정 삭제 요청

### 색상

- section card: `surface.compact`
- profile card: `surface.elevated`
- destructive action: red text only, no filled red card
- chevron / metadata: `text.muted`

### 카피

- `내 정보`
- `나의 발견 기록`
- `앱 설정`
- `개인정보와 약관`
- `로그아웃`
- `계정 삭제 요청`

### Interaction

알림:

- toggle row
- disabled state copy: `현재 이 기기에서는 알림 권한이 꺼져 있어요.`

로그아웃:

- confirmation sheet optional
- `이 기기에서 로그아웃할까요?`

계정 삭제:

- destructive confirmation
- `계정과 기록 삭제 요청을 보낼까요? 이 작업은 되돌리기 어려울 수 있어요.`

## 4. 공통 상태 UI

## 4.1 Empty

Empty는 실패가 아니라 시작 상태다.

구성:

- icon: muted signal node
- title
- body
- primary action
- optional secondary action

색상:

- card fill: `surface.compact`
- icon: muted or cyan
- CTA: outline or filled depending importance

카피 예시:

- 질문 없음: `오늘은 아직 새 질문이 없어요`
- Diary 없음: `아직 남긴 기록이 없어요`
- Insight 없음: `아직 발견된 단서가 없어요`
- U-Map 없음: `기록이 쌓이면 U-Map이 조금씩 선명해져요`

## 4.2 Loading

로딩은 premium AI 감각을 주되 과장하지 않는다.

구성:

- small progress indicator
- skeleton card 2-3개
- short copy

카피:

- `기록의 흐름을 불러오는 중이에요`
- `U-Map에 반영된 단서를 확인하고 있어요`

금지:

- 큰 전체 화면 spinner만 장시간 표시
- 과한 AI 생성 애니메이션

## 4.3 Error

사용자 탓으로 보이지 않게 한다.

구성:

- icon: warning outline
- title
- body
- retry CTA
- optional support/action

카피:

- `화면을 불러오지 못했어요`
- `연결 상태를 확인한 뒤 다시 시도해주세요.`
- CTA: `다시 시도`

색상:

- red는 icon/border 일부에만 사용
- full red background 금지

## 4.4 Save Failed

입력 화면에서는 저장 실패가 가장 중요하다. 사용자의 글이 사라졌다는 느낌을 주면 안 된다.

구성:

- inline error card above CTA
- retry
- draft preserved note

카피:

- `저장하지 못했어요`
- `작성한 내용은 이 화면에 남아 있어요. 다시 시도해주세요.`
- CTA: `다시 저장`

## 5. Flutter 전달용 구현 메모

### Data Model Binding

UI는 mock data로 먼저 구현 가능하되, 다음 데이터 구조를 염두에 둔다.

Question:

- id
- category
- prompt
- type: singleChoice / text / mixed
- choices
- optionalTextPrompt
- estimatedMinutes

Insight:

- id
- title
- summary
- sourceCount
- tags
- relatedAxes
- confidenceNote
- userFeedbackState

Diary:

- id
- date
- title
- body
- linkedQuestion
- tags
- saveStatus

UMapAxis:

- id
- label
- clarity
- summary
- recentSignals
- records
- nextQuestion

Store:

- starBalance
- products
- purchaseState
- usageHistory

### Responsive Rules

- 360dp 이하: 모든 주요 카드 1-column
- 390dp 이상: U-Map overview 내부 일부 row 허용
- 430dp 이상: axis summary 2-column 허용
- Bottom CTA는 keyboard inset에 반응
- 긴 한국어 버튼은 `maxLines: 1`, overflow ellipsis보다 문구 축약 우선

### Accessibility

- icon-only button은 tooltip/semanticsLabel 필수
- selected choice는 `selected: true`
- disabled CTA는 이유를 화면 문구로 보조
- 단서 상세의 `동의하지 않음`, `숨기기`는 destructive/feedback action임을 label에 반영

### Motion

절제된 motion만 사용한다.

- choice selected: 140-180ms color/border transition
- save success: 160ms fade + small slide
- U-Map axis selected: 180ms card border/chip transition
- loading skeleton shimmer는 아주 약하게, 또는 pulse만 사용

### QA Checklist

- 작은 Android 화면에서 keyboard가 CTA를 가리지 않는가
- 질문 선택지가 4개 이상일 때 스크롤이 자연스러운가
- Diary 긴 글 입력 시 저장 CTA가 접근 가능한가
- U-Map 8개 축이 과밀해 보이지 않는가
- Insight 상세에서 수정/숨김/동의하지 않음이 명확한가
- Store mock 상태가 출시 빌드에 노출되지 않는가
- 모든 상태 화면이 사용자를 탓하지 않는가
- 분석 표현이 단정적이지 않은가

## 6. PM 보고 요약

다음 핵심 화면 묶음에 대한 UI/Visual System 기준을 Home v2 톤에 맞춰 정리했다.

핵심 원칙:

- 진단이 아니라 기록 기반 discovery
- 결과가 아니라 단서와 흐름
- 밝은 카드가 아니라 깊은 dark navy surface hierarchy
- 과한 우주 장식이 아니라 signal/node/map 패턴
- 작은 Android 화면에서 overflow 없는 입력/상태 UX

Flutter App Lead는 이 문서를 기준으로 App Layer를 새로 구축하면 된다.
