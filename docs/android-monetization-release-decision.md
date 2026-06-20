# Android Monetization Release Decision

Date: 2026-06-19
Owner: Monetization / Store Systems
Scope: FI-YOU Android 1st release monetization strategy, Store/Star exposure, Google Play Billing readiness

## Decision Summary

Recommendation: **C. Store 화면은 정보성/비활성 상태로 유지하고, 실제 구매는 2차 업데이트로 미룬다.**

Reason:
- 현재 QA 재검수에서 Store disabled UI는 Pass지만, 실제 Google Play Billing product query, purchase, restore, server verification, refund/pending handling은 아직 공식 출시 P0 blocker다.
- FI-YOU 1차 Android 출시는 질문, Diary, U-Map, Signature 중심의 self-discovery 신뢰 형성이 우선이다.
- 질문 자체를 판매하지 않고, 유료 리포트도 더 정확한 판단이 아니라 기록의 확장 정리라는 원칙을 사용자에게 먼저 학습시키는 편이 안전하다.
- 구매 CTA를 열지 않으면 Google Play Billing 미연동 자체는 1차 출시 차단 사유가 아니지만, mock 가격/구매 버튼/Paddle 결제 유도는 Android 디지털 상품 정책 리스크가 된다.

Release rule:
- 1차 출시 빌드에서 Android 앱 내 디지털 상품 구매는 **시작할 수 없어야 한다**.
- Store는 Star 잔액, 사용 내역, 향후 사용처를 보여주는 정보성 화면으로만 유지한다.
- 구매가 열리는 순간부터 Google Play Billing + server verification + ledger/entitlement grant + refund/restore handling은 모두 출시 P0가 된다.

## A/B/C Comparison

| Option | Policy / Review Risk | Product / Trust Impact | Timeline / QA Impact | Decision Notes |
| --- | --- | --- | --- | --- |
| A. Store/Star 구매 완전 숨김 또는 비활성, 핵심 무료 흐름만 출시 | 가장 낮음. 앱 내 디지털 상품 판매가 없으므로 Billing 미연동 리스크를 최소화한다. | 결제 압박이 전혀 없어 초기 신뢰 형성에 유리하다. 다만 Star/리포트 구조 학습이 늦어진다. | 가장 빠르다. Store 관련 QA 범위가 작다. | Store 품질이 심사 또는 사용자 신뢰에 조금이라도 부담이면 선택한다. |
| B. 출시 전 Google Play Billing + server verification 완성 후 출시 | 구매를 열 수 있는 유일한 정석 경로지만 구현 누락 시 가장 위험하다. purchase token 검증, pending, restore, refund/voided 대응이 모두 필요하다. | 출시부터 수익화 검증 가능. 반대로 첫 경험에서 결제 중심 서비스처럼 보일 수 있다. | 가장 느리다. Play Console 상품, license tester, sandbox evidence, backend logs, DB 증빙까지 필요하다. | 1차 출시에서 실제 Star 판매가 반드시 필요할 때만 선택한다. |
| C. Store 정보성/비활성 유지, 구매는 2차 업데이트 | 낮음. 단, 비활성 UI가 실제 구매 CTA처럼 보이면 리스크가 생긴다. 가격/구매/복원/외부결제 문구는 숨기거나 disabled여야 한다. | FI-YOU의 무료 핵심 루프와 향후 Star 사용처를 동시에 설명한다. 가장 균형적이다. | 중간. disabled state QA와 feature flag 검증이 필요하지만 Billing 전체 구현은 2차로 분리된다. | **추천안.** 현재 QA Pass 상태와 1차 출시 목표에 가장 맞다. |

## Recommended 1st Release Scope

Included:
- 핵심 질문/탐구 시작 무료
- Diary 작성/저장 무료
- 기본 U-Map 확인 무료
- Signature 기본 루프 무료
- Store 정보성 화면
- Star 잔액 mock 또는 서버 read-only 표시
- Star 사용 내역 read-only 표시
- 향후 Star 사용처 안내: 고급 리포트, 기록 확장 정리, 부가 기능
- Billing 미연동 안내: 사용자용 문구만 사용

Excluded:
- Android 앱 내 Star package 실제 구매
- 유료 리포트 unlock 결제
- subscription 판매
- purchase restore 실행
- Google Play product query 표시
- localized price 표시
- Paddle checkout 또는 웹 결제 이동
- 결제 성공처럼 보이는 mock flow

## Flutter UI Changes For Recommendation C

Required for 1st release:
- `storeBillingConnected=false` 또는 동등한 release feature flag를 공식 빌드에서 강제한다.
- Store package card는 disabled 또는 hidden 처리한다.
- 패키지 가격은 hardcoded price를 쓰지 않는다. Billing 연결 전에는 가격 영역을 숨기거나 “구매 준비 중” 수준의 사용자용 문구로 제한한다.
- “구매하기”, “충전하기”, “복원하기”처럼 실제 결제를 시작하는 CTA는 Billing 연결 전 노출하지 않는다.
- Package card tap 시 purchase sheet, snackbar success, mock grant가 발생하지 않아야 한다.
- Star 잔액과 사용 내역은 read-only로 보인다.
- Star 사용 내역에 “질문 시작”, “탐구 시작” 차감 항목이 없어야 한다.
- Star 사용처 문구는 “더 정확한 분석”이 아니라 “기록의 확장 정리”, “긴 흐름 정리”, “보관/내보내기/추가 리포트”로 제한한다.
- Store는 핵심 탐구 루프 앞에 끼어들지 않는다. My/Settings 또는 보조 진입점이 적절하다.
- Android 앱에서 Paddle, 웹 checkout, 외부 결제 안내를 노출하지 않는다.
- 개발자 문구인 “Google Play Billing 연결 전”은 사용자에게 직접 보이지 않게 한다. 필요하면 “앱 내 구매는 아직 열리지 않았어요”처럼 바꾼다.

Recommended release flags:
- `STORE_MODE=info_only`
- `ENABLE_ANDROID_IN_APP_PURCHASE=false`
- `ENABLE_STORE_PACKAGES=false`
- `ENABLE_PAID_REPORT_UNLOCK=false`

Allowed copy:
- “핵심 질문, Diary, 기본 U-Map은 결제 없이 이어집니다.”
- “Star 구매는 아직 열리지 않았어요.”
- “Star는 향후 기록을 더 길게 정리하거나 보관하는 부가 기능에 사용될 예정입니다.”

Disallowed copy:
- “질문을 시작하려면 Star가 필요해요.”
- “더 정확한 분석을 받으려면 구매하세요.”
- “지금 구매”
- “웹에서 결제”
- “Paddle로 결제”
- “무료 체험 후 자동 결제” unless subscription terms are fully implemented and reviewed.

## Backend / Edge Function / Play Console Work

For recommended 1st release C:
- 앱 클라이언트에서 결제 성공, entitlement grant, Star grant를 자체 처리하지 않는지 확인한다.
- Store read-only 데이터는 mock 또는 서버 read-only로 제한한다.
- `star_ledger`에 질문/탐구 시작 차감 이벤트를 만들지 않는다.
- `entitlements`는 실제 결제 없이 유료 권한을 부여하지 않는다.
- Paddle webhook은 웹 전용으로 유지하고 Android package/product grant와 연결하지 않는다.
- Android 앱에서 Paddle checkout URL을 열 수 있는 path를 만들지 않는다.

For 2nd update or if Option B is selected:
- Play Console product ID 확정:
  - Consumable Star packs: `stars_100`, `stars_300`, `stars_1000`
  - Non-consumable reports, if ever needed: `report_archive_pack_v1` style
  - Subscription, if introduced later: `fiyou_plus_monthly`, `fiyou_plus_yearly`
- Product metadata는 Play Console localized title/description/price를 source of truth로 둔다.
- Flutter purchase flow:
  - product query
  - purchase stream subscription
  - pending state display
  - cancel/failure handling
  - purchased state server verification
  - consume consumable after successful server grant
  - restore for non-consumable/subscription only
- Edge Function contract:
  - Endpoint: `verify-google-play-purchase`
  - Input: `platform`, `packageName`, `productId`, `purchaseToken`, `purchaseType`, `clientPurchaseId`
  - Auth: Supabase authenticated user required
  - Validate product allowlist and product type
  - Verify purchase token with Google Play Developer API
  - Grant only when purchase state is purchased, not pending
  - Use idempotency key from `purchaseToken` hash plus `productId`
  - Insert `star_ledger` only after Google verification succeeds
  - Insert/update `entitlements` only after Google verification succeeds
  - Return authoritative balance/entitlement state to client
- Duplicate grant prevention:
  - Unique index on `platform + product_id + purchase_token_hash`
  - Replayed token returns existing grant result, not another grant
- Refund / voided purchase handling:
  - Poll Voided Purchases API or process Real-time Developer Notifications when ready
  - Mark ledger reversal or entitlement revoked
  - Keep an audit trail for grant and reversal
- QA evidence:
  - Internal testing track
  - License tester accounts
  - sandbox purchase success/cancel/failure/pending
  - restore evidence for non-consumable/subscription
  - server logs showing token verification
  - DB rows showing idempotent grant and refund/revoke handling

## Official Launch Blockers

Blockers for 1st release under recommendation C:
- Any active Android in-app purchase CTA remains visible.
- Store package card can be tapped and starts purchase, success, or mock grant flow.
- Hardcoded price is shown as if it were a real purchasable Play product.
- Android app links to Paddle or web checkout for digital goods.
- 질문/탐구 시작이 Star cost로 표시된다.
- 유료 리포트가 “더 정확한 자기판단”으로 표현된다.
- Client grants Star or entitlement without server verification.
- Core question, Diary, U-Map, Signature loop is blocked by Store/Star.
- AI-generated content policy 대응이 필요한 화면에서 사용자 신고/피드백 경로가 없다.
- Data safety / privacy disclosures are inconsistent with actual collection and AI processing.

Blockers only if purchases are enabled in 1st release:
- Google Play Billing product query is not implemented.
- Play Console products are not active in an internal testing track.
- Purchase token server verification Edge Function is missing.
- Pending purchases are treated as successful.
- Restore flow for non-consumable/subscription is missing.
- Refund/voided purchase handling has no server-side plan.
- Star ledger and entitlement grants are not idempotent.
- Localized price from Play Billing is not used.
- License tester sandbox evidence is missing.

Can be excluded from 1st release under recommendation C:
- Star package purchases
- Paid report purchase/unlock
- Subscription
- Restore purchase UI
- Play Billing product query
- RTDN production automation
- Voided purchase reconciliation automation
- Paddle-to-mobile entitlement bridge

## QA Recheck Criteria

Store disabled state:
- Store package area is disabled or hidden.
- No purchase, charge, restore, or checkout CTA is visible.
- Tapping package cards does not open a purchase flow or grant Star.
- No hardcoded real-money price is shown.
- User copy says core exploration is free.

Core loop:
- A new user can start questions without Star.
- Diary write/save does not require Star.
- Basic U-Map and Signature loop remain reachable without Store interaction.
- Star 부족 안내 does not appear before or during core exploration.

Policy boundary:
- Android app contains no Paddle checkout path for digital goods.
- Store copy does not imply questions are sold.
- Paid report copy says expanded organization, not higher accuracy.
- Billing disconnected release build has purchase feature flags off.

Backend boundary:
- No client-only grant path exists.
- `star_ledger` has no question-start debit.
- `entitlements` are not granted by mock purchase state.
- Any future grant path requires server verification first.

Evidence expected before QA signs off:
- Release build screenshot of disabled/info-only Store.
- Tap test recording or QA note confirming package cards cannot purchase.
- Text scan confirming no forbidden purchase/Paddle/question-cost copy in Flutter screens.
- Backend note confirming no mobile purchase verification endpoint is being called in 1st release.

## PM Decision

Adopt **C** for Android 1st release.

PM acceptance statement:
- FI-YOU Android 1차 공식 출시는 핵심 self-discovery 무료 흐름을 우선 출시한다.
- Store는 정보성/비활성 상태로 유지한다.
- Android 앱 내 Star 구매, 유료 리포트 구매, subscription은 2차 업데이트 범위로 이관한다.
- 2차 업데이트에서 구매를 열기 전 Google Play Billing, purchase token server verification, idempotent ledger/entitlement grant, restore, pending, refund/voided handling을 모두 P0로 완료한다.
