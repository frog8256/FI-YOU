# FI-YOU P0 UI Fix Guidance

## 0. 목적

이 문서는 Flutter App Lead가 다음 수정 라운드에서 바로 적용할 수 있는 UI 수정 지시문이다.

현재 최종 검수 판정은 보류다. 이유는 다음과 같다.

- `p0_core_flow` 스크린샷 PNG가 손상되어 육안 검수가 불가하다.
- Auth, Explore, Store, Settings에 `Mock`, `출시 전`, `준비 상태`, `예시` 같은 개발자 문구가 노출된다.
- Home, Diary, U-Map, My, Settings에서 bottom nav가 마지막 콘텐츠를 가리는 문제가 반복된다.
- 720x1280 작은 Android 화면에서 마지막 카드와 CTA가 nav 뒤로 들어간다.
- Store 패키지 카드가 Billing 미연동 상태에서도 clickable로 보인다.
- Settings 하단 법무/삭제 항목이 화면 끝 또는 navigation 영역에 걸린다.

이번 수정의 목표는 새 기능 추가가 아니라 출시 가능한 기본 사용성 확보다.

## 1. Bottom Padding / Safe Area / Scroll Layout 지시

### 1.1 App Shell 기본 원칙

- Bottom Navigation은 화면 위에 떠 있는 overlay로 취급한다.
- Bottom Navigation이 있는 모든 탭 화면은 nav 높이만큼 콘텐츠 하단 여백을 반드시 확보한다.
- 콘텐츠 화면은 `SafeArea(top: true, bottom: false)`를 기본으로 하고, bottom safe area는 nav와 scroll padding에서 명시적으로 처리한다.
- Bottom Navigation 자체는 `SafeArea(top: false)` 안에 둔다.
- 작은 Android 화면 기준으로 마지막 콘텐츠와 nav 상단 사이에 최소 24dp의 빈 공간이 보여야 한다.

### 1.2 권장 치수

공통 상수로 관리한다.

```dart
const double kFiYouHorizontalPadding = 22;
const double kFiYouBottomNavHeight = 78;
const double kFiYouBottomNavMargin = 14;
const double kFiYouBottomContentGap = 28;
```

스크롤 화면의 bottom padding은 다음 기준을 사용한다.

```dart
final bottomSafe = MediaQuery.viewPaddingOf(context).bottom;
final bottomPadding =
    kFiYouBottomNavHeight +
    kFiYouBottomNavMargin +
    kFiYouBottomContentGap +
    bottomSafe;
```

720x1280에서 여전히 가려지면 `kFiYouBottomContentGap`을 40까지 올린다.

### 1.3 Scroll View 지시

- 모든 탭 루트 화면은 `ListView`, `CustomScrollView`, 또는 `SingleChildScrollView`에 위 bottom padding을 적용한다.
- `padding: EdgeInsets.fromLTRB(22, top, 22, bottomPadding)` 형태로 통일한다.
- 마지막 콘텐츠 뒤에 임의의 `SizedBox(height: 80)`를 화면마다 따로 붙이지 않는다. 공통 scroll wrapper에서 해결한다.
- `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag`를 유지한다.

### 1.4 Sticky CTA / Keyboard 지시

- Diary Write, Question Text, Onboarding Name처럼 키보드가 열리는 화면은 `resizeToAvoidBottomInset: true`를 유지한다.
- sticky CTA가 필요한 경우 `AnimatedPadding(bottom: MediaQuery.viewInsetsOf(context).bottom)`로 키보드 inset을 반영한다.
- 키보드가 열린 상태에서 CTA가 nav 또는 keyboard 뒤에 들어가면 P0다.
- 작은 화면에서는 sticky CTA보다 scroll 내부 CTA가 더 안전하다. 입력 화면은 가능한 한 CTA를 scroll content의 마지막 요소로 둔다.

### 1.5 Modal / Bottom Sheet 지시

- 모든 bottom sheet는 `SafeArea(top: false)`를 적용한다.
- destructive sheet는 하단 padding을 `viewPadding.bottom + 20` 이상 확보한다.
- bottom sheet 내부 버튼은 최소 48dp 높이를 유지한다.

## 2. 사용자용 카피 교체안

개발자 문구는 release UI에서 전부 제거한다. 필요한 경우 debug banner 또는 internal QA flag로만 노출한다.

| 현재 문구 | 출시용 대체 문구 |
| --- | --- |
| `Mock 계정으로 계속하기` | `계속하기` |
| `Mock 계정` | `체험 계정` 또는 숨김 |
| `user@fi-you.mock` | `계정 정보 준비 중` |
| `Google Play Billing 연결 전 준비 화면입니다.` | `지금은 구매를 진행할 수 없어요.` |
| `실제 결제는 아직 실행하지 않아요.` | `잠시 후 다시 확인해 주세요.` |
| `결제 실패 상태 예시` | `결제를 완료하지 못했어요.` |
| `출시 전에는 준비 상태입니다.` | `구매 복원을 사용할 수 없어요.` |
| `현재 패키지는 준비 상태이며...` | `현재 이 패키지는 선택할 수 없어요.` |
| `Mock 결제` | `구매 확인` |
| `준비 내역` | `사용 내역` |

### 2.1 Auth 권장 카피

- Title: `FI-YOU`
- Body: `기록이 쌓일수록 나를 이해하는 지도가 선명해져요.`
- Primary CTA: `계속하기`
- Secondary/Legal: `계속하면 이용약관과 개인정보처리방침에 동의한 것으로 간주됩니다.`
- Error title: `연결을 확인하지 못했어요.`
- Error body: `잠시 후 다시 시도해 주세요. 입력한 내용은 사라지지 않아요.`

### 2.2 Explore 권장 카피

- Mock notice는 제거한다.
- Star 안내가 꼭 필요하면 다음 문구만 사용한다.
  - Title: `Star 사용 안내`
  - Body: `일부 심화 질문은 Star를 사용해 이어갈 수 있어요. 사용 내역은 Store에서 확인할 수 있습니다.`

### 2.3 Store 권장 카피

- Balance title: `150 Star`
- Disabled package label: `현재 이용 불가`
- Disabled helper: `구매 기능을 사용할 수 없어요. 잠시 후 다시 확인해 주세요.`
- Failure title: `결제를 완료하지 못했어요.`
- Failure body: `결제 상태를 확인한 뒤 다시 시도해 주세요. Star는 차감되지 않았습니다.`
- Restore disabled title: `구매 복원을 사용할 수 없어요.`
- Restore disabled body: `구매 기능을 사용할 수 있을 때 복원할 수 있습니다.`

### 2.4 Settings 권장 카피

- Account fallback: `로그인 후 계정 정보가 표시됩니다.`
- Data delete title: `데이터 삭제를 요청할까요?`
- Data delete body: `요청 후 기록과 U-Map 데이터 처리 범위를 확인하는 절차로 이어집니다.`
- Account delete title: `계정 삭제를 요청할까요?`
- Account delete body: `요청 후 되돌리기 어려울 수 있어요. 삭제 범위를 확인한 뒤 진행합니다.`

## 3. Store Disabled Card Visual Style

Billing 미연동 상태의 패키지 카드는 절대 clickable처럼 보이면 안 된다.

### 3.1 Disabled Package Card

- `onTap: null`
- Ink ripple 없음
- cursor/pressed/hover 상태 없음
- Fill: `surface.compact` 70-78%
- Border: `border.subtle` 45-55%
- Icon: gold alpha 40-50%
- Price: `textMuted`
- Main text: `textSecondary`
- CTA 위치에는 버튼 대신 상태 chip 사용

권장 구조:

```text
[Star icon muted]  50 Star
                   심화 질문을 이어갈 때 사용돼요.
                              [현재 이용 불가]
```

### 3.2 Enabled Package Card

Billing 연결 후에만 enabled 스타일을 사용한다.

- Fill: `surface.insight` 또는 `surface.elevated`
- Border: gold 22-30%
- Price: gold 또는 textPrimary
- Trailing CTA: `구매`
- Tap target: 전체 카드 또는 CTA 중 하나로만 통일

### 3.3 Disabled 상태의 금지 사항

- disabled 카드에 glow를 강하게 넣지 않는다.
- disabled 카드에 `구매 준비중`처럼 곧 가능한 것처럼 보이는 문구를 쓰지 않는다.
- disabled 카드를 탭했을 때 bottom sheet를 열지 않는다.
- 결제 실패 예시 화면을 사용자가 직접 열 수 있게 하지 않는다.

## 4. 정상 PNG 스크린샷 캡처 기준

### 4.1 저장 경로

새 캡처는 기존 손상 파일을 덮지 말고 새 폴더에 저장한다.

```text
mobile/fi_you/screenshots/p0_core_flow_v2/720x1280/
mobile/fi_you/screenshots/p0_core_flow_v2/1080x2400/
```

### 4.2 필수 화면 목록

작은 화면 720x1280과 일반 화면 1080x2400에서 모두 캡처한다.

```text
01_auth_launch.png
02_onboarding_name.png
03_home_top.png
04_home_bottom.png
05_explore_top.png
06_question_choice.png
07_question_text_keyboard.png
08_clue_found.png
09_diary_home.png
10_diary_write_keyboard.png
11_diary_detail_delete_sheet.png
12_umap_overview.png
13_umap_axis_detail.png
14_umap_empty.png
15_my.png
16_settings_bottom.png
17_store_disabled.png
18_store_failure.png
19_common_save_failed.png
```

### 4.3 캡처 방식

PowerShell binary redirection으로 `adb exec-out screencap -p > file.png`를 사용하지 않는다. 현재 손상 파일은 이 방식 때문에 UTF-16처럼 변형된 것으로 보인다.

권장 방식:

```powershell
adb shell screencap -p /sdcard/fi_you_capture.png
adb pull /sdcard/fi_you_capture.png mobile/fi_you/screenshots/p0_core_flow_v2/720x1280/01_auth_launch.png
```

캡처 후 PNG 헤더를 검증한다.

```powershell
python - <<'PY'
from pathlib import Path
for p in Path("mobile/fi_you/screenshots/p0_core_flow_v2").rglob("*.png"):
    ok = p.read_bytes()[:8] == b"\x89PNG\r\n\x1a\n"
    print("OK " if ok else "BAD", p)
PY
```

`BAD`가 하나라도 있으면 검수 불가다.

## 5. 화면별 Nav Overlap 방지 체크포인트

### 5.1 Home

- Daily Activity 카드가 nav 뒤에 들어가면 P0다.
- Home bottom 캡처에서 마지막 카드 하단과 nav 상단 사이에 최소 24dp가 보여야 한다.
- U-Map 카드가 화면 높이를 과도하게 먹으면 내부 그래픽을 줄이고 카드 높이를 고정하지 않는다.
- Header/Greeting/U-Map/Insight/Question/Activity가 모두 스크롤로 접근 가능해야 한다.

### 5.2 Explore

- 추천 질문 카드 하단 CTA 또는 Star pill이 nav에 가리면 P0다.
- 하단 Mock notice는 제거하거나 사용자용 Star 안내로 대체한다.
- Spark 아이콘은 nav active 상태에서도 Star 잔액 배지처럼 보이지 않아야 한다.
- 720x1280에서 Explore mode grid의 3열 카드 텍스트가 잘리면 2열 또는 세로 리스트로 전환한다.

### 5.3 U-Map

- 8축 리스트의 마지막 축이 nav 뒤에 들어가면 P0다.
- Data 부족 상태 카드의 CTA가 nav 뒤에 들어가면 P0다.
- Axis detail 진입 시 하단 근거/다음 질문 영역이 nav 위로 완전히 올라와야 한다.
- U-Map 그래프가 작은 화면에서 제목/설명과 겹치면 그래프 크기를 `min(width - 44, 260)` 이하로 제한한다.

### 5.4 Diary

- Diary Home의 마지막 기록 카드 또는 작성 CTA가 nav 뒤에 들어가면 P0다.
- Diary Write에서 keyboard open 시 저장 버튼이 keyboard 위에 보여야 한다.
- Diary Detail의 수정/삭제 액션이 nav 또는 gesture bar 뒤에 들어가면 P0다.
- Delete confirmation sheet의 `취소`와 `삭제` 버튼은 bottom safe area 위에 있어야 한다.

### 5.5 My

- My 하단 Settings 진입 카드가 nav 뒤에 들어가면 P0다.
- 프로필/Star/U-Map 요약 카드가 너무 커서 Settings 진입이 첫 화면에서 과도하게 멀어지면 P1이다.
- 마지막 섹션 아래에는 nav와 분리되는 빈 공간이 반드시 보여야 한다.

### 5.6 Settings

- 법무 섹션과 계정 삭제 섹션이 화면 끝/gesture area/nav 뒤에 걸리면 P0다.
- 삭제/로그아웃 confirmation sheet는 버튼까지 안전하게 보여야 한다.
- Settings는 항목이 많으므로 footer spacer를 공통 scroll padding에만 의존하지 말고 마지막 섹션 뒤 시각 여백 12-16dp를 추가해도 된다.

## 6. 출시용 스크린샷 QA 기준

### 6.1 P0 통과 기준

- 모든 지정 PNG가 정상 파일이다.
- 720x1280에서 모든 핵심 CTA가 보이고 탭 가능하다.
- keyboard open 상태에서 입력 중인 필드와 저장 CTA가 보인다.
- bottom nav가 콘텐츠, 버튼, destructive action을 가리지 않는다.
- `Mock`, `.mock`, `예시`, `출시 전`, `준비 상태` 문구가 사용자 화면에 없다.
- Store disabled package는 탭 가능한 카드처럼 보이지 않는다.
- Bottom Nav 순서는 `홈 / 다이어리 / 탐구 / U-Map / My`다.
- 탐구 Spark 아이콘은 유지하되 Star 재화와 의미가 분리되어 보인다.
- 회색 박스 느낌 없이 dark navy + premium glass tone이 유지된다.

### 6.2 P1 통과 기준

- 카드별 surface 역할이 구분된다.
- 한국어 제목은 1-2줄 안에서 자연스럽게 줄바꿈된다.
- 본문은 카드 안에서 3-4줄 이상 길어지면 상세 진입 또는 접힘 처리가 있다.
- `bodySmall` 텍스트가 실제 기기에서 읽기 어렵지 않다.
- Store/Settings 같은 정보 화면도 Home/Explore와 동일한 시각 톤을 유지한다.

## 7. 남은 시각적 리스크

- Spark와 Star가 모두 gold 계열이라 의미가 겹칠 수 있다. Spark는 탐구 시작, Star는 재화라는 문맥을 라벨/배경/크기로 분리해야 한다.
- Store disabled 카드가 너무 흐리면 오류처럼 보일 수 있다. disabled이지만 정보는 읽혀야 한다.
- bottom padding을 과도하게 늘리면 큰 화면에서 하단이 비어 보일 수 있다. 작은 화면 P0 해결 후 큰 화면에서 여백을 조정한다.
- Settings destructive action이 너무 강하면 불안감을 준다. red fill보다 red outline/text 중심으로 유지한다.
- Home card surface가 다시 회색 박스처럼 보이면 white overlay를 낮추고 border alpha를 카드 역할별로 조정한다.

