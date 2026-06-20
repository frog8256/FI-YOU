# FI-YOU Android Store Billing Release Contract

Last updated: 2026-06-19

Owner: Monetization / Store Systems Engineer

Scope: Android 1st release Store safety, Star product policy, Google Play Billing contract, backend verification, QA evidence.

## 1. Store 정책 결정안

### 결정

- 핵심 질문과 기본 탐구 시작은 무료다.
- Diary 작성, 기본 U-Map, 기본 Signature는 Star 또는 결제로 막지 않는다.
- Star는 고급 리포트, 확장 정리, 부가 기능에만 연결한다.
- 유료 리포트는 "더 정확한 분석"이 아니라 "기록의 확장 정리"다.
- Android 앱 안의 디지털 상품 결제는 Google Play Billing만 사용한다.
- Paddle은 웹 전용이며 Android Store, My, Settings, Report CTA에서 노출하지 않는다.
- 서버 검증 전 Star 지급, entitlement 부여, 리포트 unlock 표시를 하지 않는다.

### Store 노출 기준

출시 전 Google Play Billing이 연결되지 않았거나 feature flag가 꺼져 있으면:

- Star 잔액과 사용 내역은 읽기 전용으로 표시할 수 있다.
- 패키지 카드는 비활성 상태로 표시하거나 숨긴다.
- 가격은 `Google Play 연결 후 표시` 또는 서버/Play에서 받은 localized price만 표시한다.
- `구매`, `충전`, `Buy` CTA는 노출하지 않는다.
- 복원 버튼은 숨기거나 비활성화한다.

Billing이 연결된 출시 빌드에서만:

- Play product details 조회 성공 후 구매 CTA를 활성화한다.
- 가격은 Google Play localized price만 표시한다.
- purchase token을 서버 검증 Edge Function에 보낸다.
- 서버 응답 후 balance, entitlements, reports를 refresh한다.

## 2. Flutter 수정 지시문

### P0 수정

- `starHistory`에서 질문/탐구 시작 차감 항목을 제거한다.
- Store package note에서 `질문`을 Star 사용처처럼 보이게 하는 문구를 제거한다.
- Billing 미연동 상태에서는 package card `onTap`을 null로 둔다.
- Billing 미연동 상태에서는 restore action을 숨긴다.
- mock price는 원화 금액 대신 `Google Play 연결 후 표시`로 둔다.
- 개발자용 문구인 `Billing 연결 전 준비 화면`은 사용자용 안내로 바꾼다.

### 출시 구현

- `StoreProduct` model은 다음 필드를 가진다:
  - `productId`
  - `productType`
  - `title`
  - `description`
  - `playPrice`
  - `starGrant`
  - `entitlementType`
  - `isAvailable`
- Store package UI는 Play product details 조회 결과가 없으면 비활성화한다.
- pending purchase는 `구매 확인 중` 상태만 표시하고 권한을 주지 않는다.
- canceled와 failure는 별도 문구로 처리한다.
- restored purchase도 서버 verify 성공 전 성공 UI를 표시하지 않는다.
- app start, login restore, Store entry에서 unacknowledged/owned purchase를 재검증한다.

## 3. Product ID 명명 규칙

### Star consumable one-time products

| Product ID | Type | Grant | Notes |
| --- | --- | --- | --- |
| `fiyou_star_100` | consumable in-app product | 100 Star | starter |
| `fiyou_star_300` | consumable in-app product | 330 Star | standard, optional bonus |
| `fiyou_star_700` | consumable in-app product | 800 Star | expanded use |
| `fiyou_star_1500` | consumable in-app product | 1800 Star | long-term use |

### Paid report products

| Product ID | Type | Grant | Copy rule |
| --- | --- | --- | --- |
| `fiyou_report_umap_deep_1` | consumable report credit or non-consumable unlock by PM decision | U-Map expanded report entitlement | records expansion |
| `fiyou_report_signature_deep_1` | consumable report credit or non-consumable unlock by PM decision | Signature expanded report entitlement | records expansion |
| `fiyou_report_relation_1` | consumable report credit or non-consumable unlock by PM decision | Relation reflection report entitlement | self-record reflection |
| `fiyou_report_past_self_1` | consumable report credit or non-consumable unlock by PM decision | Past-self comparison entitlement | record comparison |

Recommendation for Android 1st release: keep report products draft-only unless generation, entitlement, restore, refund, and support QA are complete. If active, choose one model before Play setup:

- Consumable credit: good for repeat generations.
- Non-consumable unlock: good for one permanent report unlock.

### Subscription

| Product ID | Type | Base plans | Launch recommendation |
| --- | --- | --- | --- |
| `fiyou_plus` | subscription | `monthly_auto`, optional `yearly_auto` | draft-only unless subscription lifecycle QA is complete |

## 4. Google Play Billing Flow

### Product loading

1. App initializes Billing client.
2. App queries Play product details for allowed product IDs.
3. App shows only products returned by Play.
4. App uses Play localized price, not hardcoded price.
5. App hides or disables unavailable products.

### Purchase stream

| State | App behavior | Backend behavior |
| --- | --- | --- |
| pending | Show pending notice only. No Star or entitlement. | No grant. |
| canceled | Return to Store. No pressure copy. | No grant. |
| error/failure | Show retry/restore/support. | No grant. |
| purchased | Send token to backend verify. | Verify with Google Play, then grant. |
| restored | Send token to backend verify. | Idempotent verify and return current entitlement. |

### Acknowledgement / completion

- Complete or acknowledge purchase only after backend verification succeeds.
- Pending purchases must not be acknowledged as completed.
- Failed server verification leaves the purchase recoverable through restore/retry.

## 5. Backend Contract 지시문

### Edge Function

Endpoint:

`POST /functions/v1/verify-google-play-purchase`

Request:

```json
{
  "packageName": "com.fiyou.app",
  "productId": "fiyou_star_300",
  "productType": "inapp",
  "purchaseToken": "google-play-token",
  "source": "android"
}
```

Server requirements:

- Require authenticated Supabase JWT.
- Reject package mismatch.
- Reject non-Android source.
- Reject product ID not in server allowlist.
- Ignore client-provided Star amount or entitlement type.
- Verify token through Google Play Developer API.
- Grant only when state is purchased/active according to product type.
- Hash purchase token for lookup.
- Prevent token replay across all users.
- Write audit/payment event.
- Append Star ledger purchase row once.
- Grant entitlement once.
- Return current balance and entitlement summary.

Response:

```json
{
  "status": "granted",
  "productId": "fiyou_star_300",
  "entitlements": [
    { "type": "star_credit", "amount": 330 }
  ]
}
```

### star_ledger 기준

- `earn`: Diary reward, attendance, approved free earning.
- `purchase`: verified Google Play Star purchase.
- `spend`: paid report unlock or optional expanded feature.
- `refund`: refund accounting entry.
- `revoke`: voided/chargeback reversal.
- `adjust`: admin/support correction.

Rules:

- Ledger is append-only.
- `idempotency_key` is required.
- `provider_payment_id` or token hash uniqueness prevents duplicate purchase grants.
- Question start must never create a `spend` ledger row.
- Basic exploration must never create a `spend` ledger row.

### entitlements 기준

- Grant only after verified purchase or successful Star spend transaction.
- Paid report entitlement must reference source ledger or provider event.
- Restore returns already-granted entitlements without double granting.
- Refunded/revoked purchase updates entitlement state or creates revocation evidence.

## 6. Refund / Voided Purchase 대응

Minimum release requirement:

- Support manual refund review and entitlement revoke.
- Store provider payment ID / token hash.
- Record refund/revoke ledger entry without deleting original purchase row.
- If report credit is unused, revoke credit.
- If Star is already spent, apply PM policy:
  - negative ledger balance,
  - future offset,
  - manual support-only adjustment.

Recommended:

- Configure Real-time Developer Notifications.
- Poll Voided Purchases API.
- Add support view or SQL runbook to inspect purchase, ledger, and entitlement records.

## 7. Play Console 준비 체크리스트

- [ ] Package name is `com.fiyou.app`.
- [ ] App is uploaded to internal testing before billing QA.
- [ ] License tester accounts are added.
- [ ] Star products are created with exact product IDs.
- [ ] Paid report products are draft or active according to PM decision.
- [ ] `fiyou_plus` subscription is draft unless lifecycle QA is complete.
- [ ] Products are active before internal test purchase.
- [ ] Test cards and Play Billing Lab are prepared.
- [ ] Privacy policy and account deletion URL are available.
- [ ] Data Safety includes purchases, entitlements, user content, and AI-generated content.
- [ ] Reviewer/test account instructions are ready.

## 8. QA 체크리스트

### Flutter / Play

- [ ] Product details load for all active product IDs.
- [ ] Localized price displays from Play.
- [ ] Billing unavailable disables purchase UI.
- [ ] Purchase success sends token to backend.
- [ ] Cancel shows no entitlement.
- [ ] Failure shows retry/restore/support.
- [ ] Pending shows pending only and no grant.
- [ ] Restore re-verifies token.
- [ ] App restart during purchase recovers state.
- [ ] Reinstall and login restore entitlements.

### Backend evidence

- [ ] Edge Function logs show package/product/source validation.
- [ ] Google API verification response is recorded in restricted metadata.
- [ ] `star_ledger` has one purchase row per purchase token.
- [ ] `entitlements` has one row per paid report/subscription grant.
- [ ] Duplicate callback does not double grant.
- [ ] Same token from another user is rejected.
- [ ] Refund/voided test creates revoke/refund evidence.

### Policy

- [ ] No Paddle/web checkout in Android app.
- [ ] No question-start Star cost.
- [ ] No basic U-Map/Diary/Signature paywall.
- [ ] No "more accurate analysis" paid copy.
- [ ] AI-generated content has in-app report/flag or feedback path.

## 9. 남은 Open Blocker

- Live Google Play Billing integration is not implemented in this Flutter tree.
- Purchase token verification Edge Function is not present in this slim workspace tree.
- Play Console product IDs are not proven against app constants.
- Internal testing purchase evidence is missing.
- Restore/refund/voided purchase evidence is missing.
- Subscription launch status is not decided.
- Paid report product type is not decided: consumable credit vs non-consumable unlock.
- PM refund policy for spent Star is not decided.
- Data Safety and AI-generated content reporting evidence is not complete.

## Official References

- Google Play Billing integration: https://developer.android.com/google/play/billing/integrate
- Google Play Billing testing: https://developer.android.com/google/play/billing/test
- Google Play Billing release notes: https://developer.android.com/google/play/billing/release-notes
- Google Play Payments policy: https://support.google.com/googleplay/android-developer/answer/10281818
- Google Play AI-generated content policy: https://support.google.com/googleplay/android-developer/answer/13985936
