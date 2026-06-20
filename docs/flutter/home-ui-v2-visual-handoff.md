# FI-YOU Home UI v2 Visual Handoff

## 1. 핵심 변경점

FI-YOU Home v2는 기록 기반 self-discovery 앱이라는 정체성을 유지하되, 이전 시안에서 밝게 떠 보였던 카드/박스 색상을 더 깊고 정교한 다크 네이비 계열로 재조정한다. 목표는 MBTI/진단 앱처럼 결과를 단정하는 화면이 아니라, 사용자가 질문과 기록을 쌓아가며 U-Map이 선명해지는 과정을 조용히 따라갈 수 있는 Android-first Home이다.

이전 Home의 구조는 유지한다.

- Header
- Greeting
- U-Map Progress
- Today Insight
- Next Question
- Daily Activity
- Bottom Navigation

수정의 중심은 카드 색상이다. 기존 카드가 배경보다 너무 밝거나, 회색 유리판처럼 떠 보이거나, 모든 카드가 같은 톤으로 반복되는 느낌이 있었다면 v2에서는 카드의 역할별로 표면 색을 나눈다.

- U-Map Progress: 가장 깊고 프리미엄한 `map surface`
- Today Insight: 읽기 좋은 `insight surface`
- Next Question: 시안 액센트가 은은히 도는 `action surface`
- Daily Activity: 정보 밀도가 높은 `compact surface`
- Bottom Navigation: 배경과 분리되지만 떠 보이지 않는 `nav surface`

우주 컨셉은 줄인다. 장식적 orbit/glow는 최소화하고, 얇은 선, 점, 노드, 신호 흐름으로 Discovery / Map / Signal 감각을 만든다.

## 2. 색상 수정안

### Core Tokens

| Token | Hex | 용도 |
| --- | --- | --- |
| `background.base` | `#050714` | 앱 전체 최상위 배경 |
| `background.depth` | `#070B1A` | 스크롤 배경 하단, 화면 깊이 |
| `background.signal` | `#0A1022` | 아주 약한 radial wash |
| `surface.base` | `#0B1020` | 기본 카드 표면 |
| `surface.elevated` | `#11182B` | 일반 glass card 상단 |
| `surface.map` | `#0D1326` | U-Map 주요 카드 |
| `surface.insight` | `#10172A` | Today Insight 카드 |
| `surface.action` | `#0B1722` | Next Question 카드, cyan 계열 액션 영역 |
| `surface.compact` | `#0C1222` | Daily Activity 카드 |
| `surface.nav` | `#070B18` | Bottom Navigation |
| `border.subtle` | `#1A2440` | 기본 카드 border |
| `border.visible` | `#273556` | 주요 카드 border |
| `border.active` | `#7C5CFF` | active, CTA, progress edge |
| `text.primary` | `#FFFFFF` | 주요 제목 |
| `text.secondary` | `#B7C0D7` | 본문 |
| `text.muted` | `#7F8AA6` | 보조 정보 |
| `primary.purple` | `#8B5CF6` | Home active, U-Map progress |
| `primary.soft` | `#C4B5FD` | 선택 강조 텍스트 |
| `accent.cyan` | `#7DD3FC` | 질문, signal, action CTA |
| `accent.gold` | `#F7C948` | Star, 발견된 단서 |
| `accent.mint` | `#6EE7B7` | 분석 업데이트 |

### Alpha / Overlay Rules

Flutter에서 카드 색을 단순 solid로만 쓰면 답답해질 수 있으므로, 다음처럼 미세한 overlay를 사용한다.

| Layer | 권장값 |
| --- | --- |
| Card base fill | token color 92-96% opacity |
| Top glass highlight | white 3-6% opacity |
| Primary glow | purple 8-14% opacity |
| Cyan glow | cyan 8-12% opacity |
| Gold glow | gold 10-14% opacity |
| Card border | visible card 70-100%, subtle card 50-70% |
| Divider | `border.subtle` 65-80% |

주의: 카드 내부 배경에 `Colors.white.withOpacity(0.10)` 이상을 넓게 깔지 않는다. 이전 시안에서 박스가 밝게 떠 보인 원인이다.

## 3. 카드별 색상 적용 기준

### Header

- 배경 없음. 전체 background 위에 직접 배치한다.
- 로고 마크는 purple 중심이나, pink/orange gradient를 강하게 쓰지 않는다.
- 아이콘 버튼:
  - fill: `#11182B` 70%
  - border: `#273556` 70%
  - icon: `#B7C0D7`
  - profile dot: `#C4B5FD`

### Greeting

카드는 사용하지 않는다. Home이 대시보드가 아니라 개인화된 시작 화면처럼 느껴지도록 배경 위에 텍스트를 직접 둔다.

카피:

- `안녕하세요, 지우님 ✨`
- `오늘도 나를 발견하는 하루 되세요.`

Star badge:

- fill: `#1B1720`
- border: `#F7C948` 35%
- text/icon: `#F7C948`
- glow: gold 12%, blur 18-24

### U-Map Progress Card

Home의 핵심 카드다. 가장 크고 깊어야 하지만, 이전처럼 밝은 회색 박스처럼 보이면 안 된다.

색상:

- fill gradient:
  - top-left: `#141B30`
  - bottom-right: `#0A1020`
- border: `#273556`
- inner highlight: white 4%
- background node/orbit line: `#C4B5FD` 6-8%
- progress base ring: white 7%
- progress active ring: `#8B5CF6` to `#C4B5FD`
- progress head dot: `#EDE9FE`

카피:

- `오늘의 U-Map 선명도`
- `14%`
- `Lv. 2 탐험가`
- `아직 발견되지 않은 나의 지도가 많이 남았어요.`
- `질문하고, 기록하고, 더 깊이 이해할수록 U-Map은 선명해집니다.`
- CTA: `U-Map 보기`

레이아웃:

- 390dp 이상: 원형 progress와 텍스트를 좌우 배치
- 360dp 이하: 세로 배치 허용
- 이전 캡처처럼 작은 Android 폭에서 U-Map 카드가 과도하게 커질 수 있으므로, progress ring은 160-176dp 범위로 제한한다.

### Today Insight Card

U-Map보다 한 단계 낮은 표면이어야 한다. 밝은 유리판 대신 읽기 좋은 분석 카드 느낌.

색상:

- fill: `#10172A`
- top overlay: white 3%
- border: `#1A2440`
- icon panel fill: purple 10%
- icon border: purple 18%
- tag fill: purple 10%
- tag text: `#C4B5FD`

카피:

- 제목: `오늘 발견된 단서 ✨`
- action: `인사이트 더보기`
- 본문: `혼자 생각을 정리하는 시간이 회복에 중요한 역할을 하는 것으로 보여요.`
- tag: `관계지향`, `감정패턴`
- meta: `기반 데이터: 12개`

### Next Question Card

다음 행동을 유도하는 카드다. U-Map보다 작지만 cyan signal이 분명해야 한다.

색상:

- fill gradient:
  - top-left: `#0E1A26`
  - bottom-right: `#0A1020`
- border: `#1D3A4D`
- icon panel fill: cyan 10-14%
- icon border: cyan 22%
- circular CTA fill: radial `#0E2A33` to `#0B1020`
- circular CTA border: cyan 55%
- CTA glow: cyan 16%

카피:

- 제목: `다음 질문`
- 질문: `갈등 상황에서 나는 어떤 반응을 보일까?`
- 보조: `예상 소요 시간 3-5분`
- CTA label: `질문 시작하기`

### Daily Activity Card

상태 요약 카드다. 색보다 정보 정렬이 중요하다.

색상:

- fill: `#0C1222`
- border: `#1A2440`
- vertical divider: `#1A2440` 70%
- item icon circles:
  - 질문: purple 12%, icon `#8B5CF6`
  - 기록: cyan/blue 12%, icon `#7DD3FC`
  - 발견된 단서: gold 12%, icon `#F7C948`
  - 분석 업데이트: mint 12%, icon `#6EE7B7`

카피:

- 제목: `오늘의 탐구 현황`
- action: `자세히 보기`
- 질문: `3개`
- 기록: `2개`
- 발견된 단서: `1개`
- 분석 업데이트: `방금 전`

### Bottom Navigation

색상이 너무 밝게 떠 보이지 않게 한다. 탭 영역은 앱 배경의 일부처럼 낮게 깔고, active만 분명히 한다.

색상:

- fill: `#070B18` 96%
- border: purple 20%
- active chip: purple 22%
- active glow: purple 24%, blur 18
- inactive icon/text: `#7F8AA6`
- active icon/text: `#C4B5FD`

탭:

- `홈`
- `발견`
- `기록`
- `U-Map`
- `MY`

## 4. Home 화면 구조

### 전체 레이아웃

- Android-first scroll screen
- 좌우 padding: 20-22dp
- 상단 safe area 이후 18-22dp
- 카드 간격: 16-18dp
- Bottom Navigation 높이: 72-78dp
- Bottom padding: navigation height + 24dp

### 권장 컴포넌트 분리

Flutter App Lead는 다음 단위로 분리한다.

- `HomeScreen`
- `HomeHeader`
- `GreetingSection`
- `UMapProgressCard`
- `TodayInsightCard`
- `NextQuestionCard`
- `DailyActivityCard`
- `FiYouBottomNavigation`
- `FiYouGlassCard`
- `SignalIconPanel`
- `UMapProgressRing`

### 카피 기준

Home v2는 사용자를 평가하거나 판정하지 않는다.

권장 톤:

- `발견`
- `단서`
- `흐름`
- `선명해집니다`
- `지금까지의 기록`
- `다음 질문`

피해야 할 톤:

- `당신은 이런 사람입니다`
- `진단 결과`
- `유형 확정`
- `정답`
- `등급`

## 5. Flutter 구현 시 주의사항

- 이번 단계에서는 기존 Flutter App Layer를 그대로 전제하지 말고, 새 App Layer에서도 재사용 가능한 디자인 기준으로 구현한다.
- `ThemeData`에 색상 토큰을 먼저 고정하고 화면에서 임의 hex를 반복하지 않는다.
- 카드 fill은 너무 밝은 white overlay를 피한다. 카드가 떠 보이면 surface token을 더 어둡게 하고 border/inner highlight로 분리한다.
- `withOpacity` 대신 최신 Flutter에서는 `withValues(alpha: ...)` 사용을 권장한다.
- 한국어 긴 문구는 `maxLines`와 `softWrap`을 고려한다. CTA 버튼 안 텍스트는 1줄로 유지하고 필요하면 `FittedBox`가 아니라 문구/폭을 조정한다.
- 터치 타깃은 최소 44dp, Android 기준 권장 48dp 이상.
- U-Map progress ring은 CustomPainter로 구현하되, 작은 화면에서 ring이 카드 전체를 압도하지 않게 `LayoutBuilder`로 크기를 제한한다.
- Bottom Navigation은 실제 앱 하단 safe area와 겹치지 않게 `SafeArea(top: false)` 내부에 둔다.
- Home preview용 mock data는 가능하지만, 출시 코드에서는 repository/provider에서 실제 summary data로 연결할 수 있어야 한다.
- 접근성 label은 정상 한국어로 별도 지정한다. 화면 텍스트와 semantics 텍스트가 깨지지 않도록 UTF-8 저장을 확인한다.

## 6. 재사용 가능한 것과 버려야 할 것

### 재사용 가능

- Home 정보 구조: Header / Greeting / U-Map / Insight / Question / Activity / Bottom Nav
- U-Map 원형 progress 아이디어
- Star badge 패턴
- 다음 질문의 원형 CTA 패턴
- Daily Activity 4-column 요약 구조
- `Figure Yourself` 철학과 기록 기반 discovery copy

### 수정해서 재사용

- Glass card: 유지하되 fill을 더 어둡게 조정
- Orbit line: 유지하되 장식량 50% 이상 축소
- Glow: active, CTA, star에만 제한
- U-Map card layout: 작은 화면에서 세로로 과도하게 길어지지 않도록 ring 크기와 breakpoint 재설계

### 버려야 할 것

- 밝은 회색 glass box처럼 보이는 카드 색
- 모든 카드가 같은 밝기/같은 표면으로 반복되는 구조
- 과한 우주 배경, 별/점 장식 과다 사용
- 보라색 glow가 화면 전체를 지배하는 처리
- MBTI/진단 앱처럼 결과를 확정하는 문구
- 구현 중 깨진 한국어 문자열을 임시로 방치하는 방식

## 7. Flutter App Lead 전달 요약

Home v2의 핵심은 “더 어두운 박스, 더 명확한 계층, 더 적은 장식”이다.

구현 우선순위:

1. 색상 토큰부터 정리한다.
2. `FiYouGlassCard`의 fill/border/elevation 규칙을 만든다.
3. U-Map Progress Card를 가장 먼저 구현해 Home의 기준 밀도를 잡는다.
4. Insight / Question / Activity 카드를 역할별 surface로 분리한다.
5. Bottom Navigation active 상태를 보라색 glow로만 과하게 처리하지 말고 chip + icon/text color로 함께 표현한다.
6. Android 작은 화면에서 텍스트 줄바꿈과 CTA 터치 영역을 QA한다.

최종 시각 목표:

프리미엄 AI 서비스처럼 차분하지만, 기록이 쌓이며 신호가 선명해지는 느낌이 있어야 한다. FI-YOU는 사람을 분류하지 않고, 사용자가 자기 흐름을 발견하도록 돕는 앱이다.
