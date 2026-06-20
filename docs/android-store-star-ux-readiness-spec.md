# FI-YOU Android Store / Star UX Readiness Spec

Last updated: 2026-06-19

Owner: Monetization / Store Systems Engineer

Scope: Android 1st release Store, Star, Google Play Billing readiness, Supabase star ledger and entitlement connection.

## 1. 출시 기준 Store / Star UX 명세

### Store / Star 역할

Store는 핵심 자기탐색 루프를 판매하는 화면이 아니다. Store는 사용자가 이미 남긴 기록을 더 넓게 정리하고 싶을 때 선택적으로 Star를 확인하고, Google Play Billing으로 Star 또는 유료 리포트 권한을 구매하고, 구매/사용 내역을 복원하거나 확인하는 보조 화면이다.

Android 1차 출시에서 Store의 우선순위는 다음 순서다.

1. Star 잔액과 사용 내역을 투명하게 보여준다.
2. Google Play Billing 연결 상태를 명확히 보여준다.
3. 구매 전후 상태를 침착하게 처리한다.
4. 유료 리포트는 더 정확한 분석이 아니라 "기록의 확장 정리"로만 설명한다.
5. 질문, Diary, 기본 U-Map, 기본 Signature 접근을 절대 막지 않는다.

### 핵심 루프 보호 원칙

- 질문 자체는 판매하지 않는다.
- Diary 작성/조회는 Star 부족으로 막지 않는다.
- 기본 U-Map과 Signature는 "기록 기반 현재 흐름"을 보여주는 핵심 기능으로 유지한다.
- Star는 확장 리포트, 추가 정리, 선택적 deep view에만 사용한다.
- Star 부족 안내는 Store로 밀어붙이는 화면이 아니라 선택지를 주는 안내여야 한다.
- Home에는 Star 잔액을 작게 보여줄 수 있지만, 결제 CTA는 핵심 CTA보다 앞서면 안 된다.

### Star 노출 기준

노출 가능:

- Home 상단의 작은 잔액 pill.
- My / Settings의 `Star / Store` 진입.
- 유료 리포트 preview 하단의 `확장 정리 열기`.
- Store 화면의 잔액, 패키지, 사용 내역.
- Star 부족 상태에서 free continuation 옵션과 함께 안내.

노출 금지:

- 질문 시작 CTA 옆 결제 유도.
- Diary 저장 전후 결제 유도.
- 기본 U-Map empty state에서 Star 구매 유도.
- "더 정확한 분석", "진짜 나", "정답", "검사 결과"와 연결된 유료 문구.
- Android 앱 안에서 Paddle checkout, 웹 결제 링크, 외부 결제 유도.

## 2. 필요한 UI 목록

### Star 잔액

- 위치: Home 작은 pill, Store header, My / Settings 요약.
- 데이터: `get_star_balance()` 또는 launch state의 `starBalance`.
- 상태: loading, loaded, unavailable.
- 문구: `150 Star`, `Star 정보를 확인하지 못했어요`.

### 구매 패키지

- 위치: Store 본문.
- 상품: Star pack, paid report unlock, optional Plus subscription.
- 가격: 반드시 Google Play Billing product details의 localized price를 사용한다.
- mock에서는 가격을 "준비 중" 또는 "Google Play 연결 후 표시"로 둔다.

### 구매 확인

- Google Play purchase sheet 진입 전 앱 자체 confirmation은 과도하게 만들지 않는다.
- 필요한 경우 bottom sheet:
  - 상품명
  - Play 제공 가격
  - "질문과 Diary는 계속 무료로 사용할 수 있어요."
  - CTA: `Google Play로 구매`

### 구매 성공

- 서버 검증 후에만 성공 상태를 표시한다.
- Star pack: `Star가 반영되었어요.`
- Report unlock: `확장 리포트 정리 권한이 열렸어요.`
- CTA: `Store로 돌아가기`, `리포트 보기`.

### 구매 실패

- 실패와 취소를 분리한다.
- 취소: `구매가 취소되었어요. 언제든 다시 선택할 수 있어요.`
- 실패: `구매를 확인하지 못했어요. 결제는 Google Play 상태를 기준으로 다시 확인할 수 있어요.`
- CTA: `다시 시도`, `구매 복원`, `문의하기`.

### 구매 복원

- Store 상단 또는 하단에 `구매 복원` 액션을 둔다.
- 앱 시작, Store 진입, 로그인 후에도 미완료 purchase token restore를 시도할 수 있어야 한다.
- restore도 서버 검증 전 권한 부여 금지.

### 사용 내역

- 위치: Store 하단 또는 separate detail.
- 항목:
  - earned: 출석, Diary, 보상
  - purchase: Google Play 구매
  - spend: 확장 리포트 사용
  - refund/revoke: 환불, 취소, 회수
- 표시: 날짜, 이유, 증감, 잔액 snapshot이 있으면 표시.

### Star 부족 안내

- 위치: paid report unlock 또는 optional deep view 접근 시.
- 우선순위:
  1. `계속 무료로 탐색하기`
  2. `Diary 쓰고 Star 받기` 또는 free earning action
  3. `Google Play로 Star 구매`
- 문구: `이 확장 정리는 Star가 필요해요. 질문과 Diary는 계속 사용할 수 있어요.`

## 3. Mock UI와 출시 전 필수 연결 항목

### Google Play Billing 연결 전 mock UI

현재 [store_screen.dart](/C:/Users/frog8/Desktop/project/Fi-You/mobile/fi_you/lib/screens/store_screen.dart)는 mock 상태로 유지 가능하다. 단, 내부 빌드에서는 다음을 명확히 보여야 한다.

- `Google Play Billing 연결 전 확인용 화면입니다. 실제 결제는 진행되지 않습니다.`
- mock CTA는 실제 결제처럼 오해되지 않게 한다.
- production build에서는 mock purchase CTA를 숨기거나 billing unavailable 상태로 대체한다.

### 출시 전 필수 연결 항목

Flutter:

- `in_app_purchase` 또는 검증된 Play Billing wrapper 연결.
- Play product details query.
- localized price 표시.
- purchase stream listener.
- pending/canceled/error/purchased/restored 상태 처리.
- purchase token을 Supabase Edge Function으로 전송.
- 서버 검증 성공 후 `completePurchase()` / acknowledgement 처리.
- restore purchases.
- backend entitlement refresh.

Backend:

- Google Play Developer API service account secret.
- Android package name `com.fiyou.app` 검증.
- product ID server allowlist.
- purchase token hash 저장.
- token replay 방지.
- `star_ledger` append-only 지급.
- `entitlements` grant.
- refund/revoke 처리.
- subscription renewal/cancel/hold/grace 처리.

## 4. Supabase Entitlement / Star Ledger 연결 플로우

### Star 구매

1. Flutter가 Play Billing product details를 표시한다.
2. 사용자가 Google Play purchase sheet에서 구매한다.
3. Flutter는 purchase token을 서버에 보낸다.
4. 서버는 사용자 JWT, package name, product ID, purchase token을 검증한다.
5. 서버는 Google Play Developer API로 구매 상태가 `PURCHASED`인지 확인한다.
6. 서버는 `provider_payment_id` 또는 token hash 기반 idempotency로 중복 지급을 차단한다.
7. 서버는 `star_ledger`에 `entry_type='purchase'`, `reason='star_purchase'`, `amount=상품별 Star`를 append한다.
8. 서버 응답 후 Flutter가 balance와 history를 refresh한다.
9. Flutter는 서버 성공 후에만 purchase complete/acknowledge를 수행한다.

### Star 사용 / paid report unlock

1. 사용자가 paid report preview에서 `확장 정리 열기`를 누른다.
2. Flutter는 서버의 현재 Star balance와 entitlement 상태를 확인한다.
3. Star가 충분하면 서버 RPC가 Star를 차감한다.
4. 서버는 같은 transaction에서 `star_ledger` spend와 `entitlements` grant를 연결한다.
5. Flutter는 entitlement refresh 후 리포트를 연다.

### Paid report 직접 구매

1. 사용자가 Google Play로 report credit 또는 report unlock 상품을 구매한다.
2. 서버 검증 후 `entitlements`를 grant한다.
3. report body 생성/조회는 entitlement 확인 후 진행한다.
4. 문구는 "기록의 확장 정리"로 유지한다.

### 구매 복원

1. Flutter가 owned purchases 또는 purchase stream restored 항목을 읽는다.
2. 서버로 token을 다시 보낸다.
3. 서버는 이미 처리된 token이면 idempotent success를 반환한다.
4. 서버 상태를 source of truth로 entitlement와 Star balance를 표시한다.

### 환불 / 취소 / 회수

- Google Play RTDN 또는 Voided Purchases API polling으로 감지한다.
- unused report credit은 revoke/refund 처리한다.
- 이미 사용한 Star는 PM 정책에 따라 negative ledger, future offset, manual support 중 하나를 적용한다.
- 구독은 cancel 즉시 차단하지 않고 paid period end 기준 또는 Google subscription state 기준으로 처리한다.

## 5. Flutter 구현 체크리스트

- [ ] Store mock copy가 production에서 실제 결제로 오해되지 않는다.
- [ ] Star balance component가 Home/Store/My에서 같은 source를 쓴다.
- [ ] Store package card는 Play product details 없을 때 구매 버튼을 비활성화한다.
- [ ] 가격은 hardcoded mock price가 아니라 Play localized price를 사용한다.
- [ ] purchase stream listener가 app lifecycle 전반에서 동작한다.
- [ ] pending purchase는 권한을 주지 않고 pending 안내만 한다.
- [ ] canceled와 error 메시지를 분리한다.
- [ ] purchased/restored는 서버 verify 성공 전 성공 UI를 띄우지 않는다.
- [ ] verify 성공 후 balance, entitlements, reports를 refresh한다.
- [ ] restore purchases CTA가 있다.
- [ ] Star 부족 안내가 free continuation을 먼저 보여준다.
- [ ] Home의 Star 노출은 작고 보조적이며 질문 CTA보다 앞서지 않는다.
- [ ] Android 앱 내부에 Paddle checkout 또는 웹 결제 CTA가 없다.

## 6. Backend 계약 체크리스트

- [ ] `star_ledger`는 append-only다.
- [ ] Flutter authenticated user는 own ledger/entitlement read만 가능하다.
- [ ] Star 지급은 service role 또는 security definer RPC만 가능하다.
- [ ] Google purchase verification Edge Function이 있다.
- [ ] Edge Function은 client-provided Star amount를 신뢰하지 않는다.
- [ ] Edge Function은 server product catalog / allowlist를 사용한다.
- [ ] purchase token raw value는 넓게 저장하지 않고 hash 또는 restricted storage를 사용한다.
- [ ] purchase token replay를 전체 사용자 범위에서 차단한다.
- [ ] Star pack 성공 시 ledger purchase row가 1회만 생성된다.
- [ ] paid report 성공 시 entitlement가 1회만 생성된다.
- [ ] Star spend와 entitlement grant는 transaction으로 묶인다.
- [ ] refund/revoke flow가 ledger와 entitlement를 업데이트한다.
- [ ] subscription state active/grace/hold/cancel/expired를 구분한다.

## 7. 정책 리스크 P0 / P1 / P2

### P0

- Android 앱 내 디지털 상품에 Paddle 또는 웹 결제 CTA가 노출됨.
- 서버 검증 전 Star 지급 또는 entitlement 부여.
- pending/canceled purchase에 권한 부여.
- 질문, Diary, 기본 U-Map, 기본 Signature가 결제 또는 Star 부족으로 막힘.
- paid report copy가 "더 정확한 분석", "진단", "진짜 나"를 암시함.
- Play Console product ID와 Flutter/backend product ID 불일치.
- 환불/voided purchase 후 entitlement 회수 정책 없음.
- AI-generated insight 신고/피드백 경로 없음.

### P1

- Store mock CTA가 production에 남아 사용자 오해를 만듦.
- 가격 hardcoding.
- restore purchase 미구현.
- 사용 내역이 ledger와 불일치.
- 구독을 1차 출시에서 켰지만 cancel/grace/hold QA가 없음.
- Star 부족 안내가 구매를 첫 선택지로 밀어붙임.
- web Paddle entitlement를 Android에서 보여주면서 출처/정책 경계를 설명하지 않음.

### P2

- Star history filter/search 부재.
- 상세 영수증/지원 ticket 연결 부재.
- subscription benefit breakdown 미흡.
- 리포트별 Star cost 조정 UI 부재.
- iOS StoreKit 확장 abstraction 미정.

## 8. 출시 전 차단 항목

- Google Play Billing live/internal testing purchase token 검증 완료.
- Play Console in-app products와 subscription 생성 및 활성화.
- Flutter product ID, backend allowlist, Play Console ID 1:1 확인.
- 서버 verify 성공 전 권한이 부여되지 않는 QA 증거.
- purchase success/cancel/failure/pending/restore/reinstall QA 증거.
- refund/voided purchase 처리 방침과 최소 구현.
- Android 앱에서 Paddle checkout 미노출 검증.
- Store mock UI production 노출 여부 결정.
- Data Safety에 purchase/entitlement/AI-generated content 처리 목적 반영.
- AI-generated content 신고 또는 피드백 경로 확인.
- account deletion path와 web deletion/privacy URL 확인.

## 9. PM 의사결정 필요사항

- 1차 출시에서 Store를 보이게 할지, My/Settings 하위 hidden entry로 둘지.
- Star pack만 출시할지, paid report direct purchase도 출시할지.
- `fiyou_plus` 구독을 launch active로 둘지 draft-only로 둘지.
- 환불 시 이미 사용한 Star의 회수 정책.
- web Paddle 구매 entitlement를 Android에서 읽을지.
- Star earning action 범위: Diary reward, attendance, free explore 등.
- paid report cost table과 launch price.

## Official Policy References

- Google Play Billing: https://developer.android.com/google/play/billing
- Google Play Billing integration and pending purchase acknowledgement: https://developer.android.com/google/play/billing/integrate
- Google Play Payments policy: https://support.google.com/googleplay/android-developer/answer/10281818
- Google Play AI-generated content policy: https://support.google.com/googleplay/android-developer/answer/14094294
- Google Play account deletion guidance: https://android-developers.googleblog.com/2024/03/designing-your-account-deletion-experience-google-play.html
