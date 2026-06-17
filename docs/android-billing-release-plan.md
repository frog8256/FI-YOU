# FI-YOU Android Billing / Release QA Plan

Last updated: 2026-06-17

Scope: Phase 4 + Phase 7 + Phase 8 for Android production release.

Confirmed decisions:

- Android package name: `com.fiyou.app`
- App name: `FI-YOU`
- Android in-app payments: Google Play Billing only
- Web checkout: Paddle only, never used inside the Android app
- Future iOS in-app payments: Apple StoreKit / In-App Purchase
- Privacy policy URL: `https://fi-you.vercel.app/privacy`
- Release scope includes questions, Diary, U-Map, Signature, relation features, Star, paid reports, and payment
- First device substitute: Android Studio Emulator

## Policy Guardrails

- Questions themselves are not sold.
- Basic self-discovery loop remains accessible before payment emphasis.
- Do not say "more accurate analysis", "diagnosis", "therapy", "counseling", "treatment", or "guaranteed result".
- Paid value copy should use:
  - "clearer U-Map flow"
  - "expanded view of your records"
  - "deeper organization of your own entries"
  - "additional relationship reflection view"
- Android app must not open, promote, or steer users to Paddle checkout for digital goods.
- Web Paddle purchases may exist on the website/account portal, but Android in-app purchase surfaces must use Google Play Billing.
- Any entitlement usable in Android must be synced from backend, but Android purchase CTAs must remain Play Billing.

## Play Billing Product Design

### Product Types

| Type | Play Console type | Use | Entitlement behavior |
| --- | --- | --- | --- |
| Star packs | One-time products, consumable | User buys Star balance | Backend verifies token, appends Star ledger credit, consumes purchase |
| Report credits | One-time products, consumable | User buys one specific expanded report generation/unlock | Backend verifies token, grants report credit or unlock, consumes purchase |
| Subscription | Subscription | Optional FI-YOU Plus bundle | Backend verifies active subscription and stores recurring entitlement |

### Star Pack Products

Use a small set for launch. Avoid too many price anchors before Product QA has real conversion data.

| Product ID | Type | Grant | Positioning |
| --- | --- | --- | --- |
| `fiyou_star_100` | Consumable one-time product | +100 Star | Starter pack |
| `fiyou_star_300` | Consumable one-time product | +330 Star | Standard pack, includes 10% bonus |
| `fiyou_star_700` | Consumable one-time product | +800 Star | Deep exploration pack |
| `fiyou_star_1500` | Consumable one-time product | +1800 Star | Long-term reflection pack |

Play Console fields:

- Product type: In-app product / one-time product
- Status: Active only after sandbox/internal QA passes
- Tax/category: digital content/service
- Product title examples:
  - `100 Stars`
  - `330 Stars`
  - `800 Stars`
  - `1800 Stars`
- Description tone:
  - `Use Stars to open expanded reflection views in FI-YOU. Questions remain available without purchase.`

### Paid Report Products

Reports should be framed as expanded organization of user records, not better truth or accuracy.

| Product ID | Type | Grant | Suggested Star alternative |
| --- | --- | --- | --- |
| `fiyou_report_umap_deep_1` | Consumable one-time product | 1 U-Map expanded report credit | 80 Star |
| `fiyou_report_signature_deep_1` | Consumable one-time product | 1 Signature expanded report credit | 80 Star |
| `fiyou_report_relation_1` | Consumable one-time product | 1 Relation reflection report credit | 100 Star |
| `fiyou_report_past_self_1` | Consumable one-time product | 1 Past-self comparison report credit | 50 Star |

Product copy:

- Allowed: `Unlock an expanded view that organizes your existing entries into a clearer U-Map flow.`
- Avoid: `Get a more accurate analysis.`

### Subscription Product

Recommendation: configure subscription as a ready product structure, but do not make it the dominant first launch CTA. Surface it only after the user has experienced the core loop and an expanded view preview.

Subscription ID:

- `fiyou_plus`

Benefits:

- Monthly Star stipend
- Monthly expanded report credit
- More saved history views
- Deeper organization of U-Map and Signature records

Base plans:

| Subscription ID | Base plan ID | Type | Renewal | Notes |
| --- | --- | --- | --- | --- |
| `fiyou_plus` | `monthly_auto` | Auto-renewing | Monthly | Primary plan |
| `fiyou_plus` | `yearly_auto` | Auto-renewing | Yearly | Optional annual plan |

Offer structure:

| Base plan | Offer ID | Launch status | Notes |
| --- | --- | --- | --- |
| `monthly_auto` | none | Launch | Keep simple for first billing QA |
| `yearly_auto` | none | Launch optional | Use only if yearly pricing is approved |
| `monthly_auto` | `intro_7d` | Draft only | Do not activate before renewal/cancel/grace QA |
| `yearly_auto` | `founder_20` | Draft only | Do not activate before price messaging QA |

## Play Console Product Checklist

### App Setup

- [ ] Create app in Play Console.
- [ ] Package name: `com.fiyou.app`.
- [ ] App name: `FI-YOU`.
- [ ] Default language selected.
- [ ] App/category: recommend `Lifestyle`.
- [ ] Privacy policy URL: `https://fi-you.vercel.app/privacy`.
- [ ] Developer contact email configured.
- [ ] Store listing draft added.
- [ ] Content Rating completed.
- [ ] Data Safety completed.
- [ ] Health apps declaration completed without medical claims.
- [ ] App access instructions/test account provided if login is required.
- [ ] Ads declaration completed.

### Monetization Setup

- [ ] Merchant profile/payment profile ready.
- [ ] One-time products created for Star packs.
- [ ] One-time products created for paid report credits.
- [ ] Subscription `fiyou_plus` created if launch includes subscription.
- [ ] Base plans `monthly_auto` and `yearly_auto` configured.
- [ ] Draft offers created only if QA can cover them.
- [ ] Product IDs match app constants exactly.
- [ ] Products are active before internal billing QA.
- [ ] License testers added in Play Console.
- [ ] Test cards and Play Billing Lab test paths prepared.
- [ ] Refund/revoke support process documented.

### Product ID Parity Checklist

These product IDs must match exactly in three places:

1. Play Console product/subscription IDs.
2. Flutter constants in `mobile/fi_you/lib/data/billing/billing_service.dart`.
3. Backend allowlist and entitlement mapping.

| Product ID | Play Console | Flutter constant | Backend allowlist | Type |
| --- | --- | --- | --- | --- |
| `fiyou_star_100` | [ ] | [x] | [ ] | Consumable one-time product |
| `fiyou_star_300` | [ ] | [x] | [ ] | Consumable one-time product |
| `fiyou_star_700` | [ ] | [x] | [ ] | Consumable one-time product |
| `fiyou_star_1500` | [ ] | [x] | [ ] | Consumable one-time product |
| `fiyou_report_umap_deep_1` | [ ] | [x] | [ ] | Consumable report credit |
| `fiyou_report_signature_deep_1` | [ ] | [x] | [ ] | Consumable report credit |
| `fiyou_report_relation_1` | [ ] | [x] | [ ] | Consumable report credit |
| `fiyou_report_past_self_1` | [ ] | [x] | [ ] | Consumable report credit |
| `fiyou_plus` | [ ] | [x] | [ ] | Subscription |

Subscription base plan parity:

| Subscription ID | Base plan ID | Play Console | Backend subscription mapping |
| --- | --- | --- | --- |
| `fiyou_plus` | `monthly_auto` | [ ] | [ ] |
| `fiyou_plus` | `yearly_auto` | [ ] | [ ] |

Do not upload to Play internal testing for billing QA until all `[ ]` cells in this checklist are resolved or intentionally marked not-in-launch.

### Release Track Setup

- [ ] Internal testing track created.
- [ ] License tester accounts are opted in.
- [ ] Closed testing track created.
- [ ] If personal developer account requires it, maintain at least 12 opted-in testers for 14 continuous days.
- [ ] AAB uploaded to internal testing first.
- [ ] Pre-launch report reviewed.
- [ ] Production release not submitted until billing QA passes.

## Frontend Billing Contract

Flutter should use the current Google Play Billing compatible path, such as `in_app_purchase` with Android billing support or a vetted wrapper using Play Billing Library 9.x.

Required app behavior:

- [ ] Query product details from Play Billing for all configured product IDs.
- [ ] Show prices from Play Billing, not hardcoded local prices.
- [ ] Start purchase flow only after user action.
- [ ] Do not show Paddle link or web checkout button inside Android.
- [ ] Handle purchase updates throughout app lifecycle.
- [ ] Send purchase token to backend before granting entitlement.
- [ ] Show pending state without granting entitlement.
- [ ] Complete/acknowledge purchase only after backend verification and entitlement grant path is confirmed.
- [ ] Restore purchases by querying active purchases and sending unprocessed tokens to backend.
- [ ] Reflect backend entitlement state as source of truth.

Product constants:

```dart
const androidPackageName = 'com.fiyou.app';

const oneTimeProductIds = <String>{
  'fiyou_star_100',
  'fiyou_star_300',
  'fiyou_star_700',
  'fiyou_star_1500',
  'fiyou_report_umap_deep_1',
  'fiyou_report_signature_deep_1',
  'fiyou_report_relation_1',
  'fiyou_report_past_self_1',
};

const subscriptionProductIds = <String>{
  'fiyou_plus',
};
```

Payment UI copy rules:

- Primary CTA: `Unlock expanded view`
- Star CTA: `Use Stars`
- Purchase CTA: `Buy Stars with Google Play`
- Subscription CTA: `View FI-YOU Plus`
- Insufficient Star state: `You can keep exploring for free, earn Stars, or unlock this expanded view with Google Play.`

Do not use:

- `Get more accurate analysis`
- `Find your true self`
- `Diagnose your relationship`
- `Required to continue`

## Backend Purchase Verification Contract

Backend is the entitlement authority. Client purchase state is not trusted.

### Core Tables / Records

Required records:

- `purchase_transactions`
- `entitlements`
- `points_ledger` / Star ledger
- `report_credits` or `report_entitlements`
- `subscriptions`
- `billing_events`

Minimum fields for `purchase_transactions`:

| Field | Purpose |
| --- | --- |
| `id` | Internal transaction id |
| `user_id` | FI-YOU user |
| `platform` | `android`, `web`, future `ios` |
| `package_name` | Must be `com.fiyou.app` for Android |
| `product_id` | Play product id |
| `product_type` | `inapp` or `subs` |
| `purchase_token_hash` | Hash of token for lookup without exposing raw token broadly |
| `purchase_token_encrypted` | Raw token encrypted or stored in restricted secret table if needed |
| `order_id` | Google order id when available |
| `purchase_state` | `purchased`, `pending`, `canceled`, `expired`, `refunded`, `revoked` |
| `ack_state` | Google acknowledgement state |
| `consumption_state` | For consumables |
| `entitlement_status` | `none`, `granted`, `revoked`, `expired` |
| `idempotency_key` | Prevent duplicate grants |
| `created_at`, `updated_at` | Audit |

### API Endpoints

`POST /billing/google/verify`

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

Server checks:

- Authenticated user owns the request.
- `packageName` equals `com.fiyou.app`.
- `productId` is on the allowlist.
- Product type matches Play Console configuration.
- Purchase token validates through Google Play Developer API.
- Purchase state is `PURCHASED` before entitlement grant.
- Pending purchases do not grant entitlements.
- Token has not already granted entitlement to this or another user.
- Order is not voided/refunded/revoked.

Response:

```json
{
  "status": "granted",
  "entitlements": [
    {
      "type": "star_credit",
      "amount": 330
    }
  ],
  "serverTransactionId": "txn_123"
}
```

`POST /billing/google/restore`

- Client sends currently owned purchase tokens.
- Backend validates each token and returns current entitlements.
- Backend does not double-grant consumables already consumed/granted.

`POST /billing/google/notifications`

- Receives Real-time Developer Notifications through Pub/Sub bridge.
- Updates subscription renewals, grace, hold, cancellation, expiry, refunds, and revocations.

Scheduled job:

- Poll Voided Purchases API for refunds/chargebacks/revocations and revoke matching entitlements.

### Entitlement Mapping

| Product ID | Backend grant |
| --- | --- |
| `fiyou_star_100` | Append +100 to Star ledger |
| `fiyou_star_300` | Append +330 to Star ledger |
| `fiyou_star_700` | Append +800 to Star ledger |
| `fiyou_star_1500` | Append +1800 to Star ledger |
| `fiyou_report_umap_deep_1` | Grant 1 U-Map expanded report credit |
| `fiyou_report_signature_deep_1` | Grant 1 Signature expanded report credit |
| `fiyou_report_relation_1` | Grant 1 Relation report credit |
| `fiyou_report_past_self_1` | Grant 1 Past-self comparison credit |
| `fiyou_plus` | Set active subscription entitlement; grant recurring benefits according to renewal event |

Idempotency:

- One purchase token can grant entitlement once.
- Star ledger entries must use deterministic idempotency keys, such as `google:{purchase_token_hash}:star`.
- Report credit entries must use deterministic idempotency keys.
- Subscription renewal benefits must key by order id / renewal event, not just product id.

## Payment QA Scenarios

### One-Time Products

| Scenario | Expected result |
| --- | --- |
| Star pack success | Backend verifies token, grants Star once, purchase is consumed/acknowledged |
| Paid report success | Backend verifies token, grants report credit/unlock once |
| User cancels purchase sheet | No entitlement, UI returns to prior state without pressure copy |
| Payment declined | No entitlement, show calm retry/help copy |
| Pending purchase | No entitlement until Play state becomes purchased |
| Duplicate callback | No duplicate Star or report grant |
| Token replay by another account | Reject and alert backend |
| Product details unavailable | Hide purchase CTA or show retry state |
| Network failure after purchase | App retries backend verification; purchase remains recoverable through restore |
| App killed during purchase | On restart, app queries purchases and verifies unfinished token |
| Refund / voided purchase | Backend marks revoked and removes unused credit or blocks future access according to policy |
| Consumed purchase restore | No duplicate restore of already granted Star |

### Subscription

| Scenario | Expected result |
| --- | --- |
| Monthly subscribe success | Backend marks `fiyou_plus` active |
| Yearly subscribe success | Backend marks `fiyou_plus` active |
| Renewal | Backend extends entitlement and grants renewal benefits once |
| User cancels auto-renew | Access remains until paid period end |
| Expiration | Subscription entitlement becomes inactive |
| Grace period | UI shows billing issue state if surfaced; access follows backend policy |
| Account hold | Paid subscription benefits pause or follow policy decision |
| Plan switch monthly to yearly | Backend keeps one active subscription entitlement |
| Refund/chargeback | Backend revokes subscription benefits according to Google state |
| Restore on new device | Active subscription is restored after backend verification |

### Cross-Platform Entitlement

| Scenario | Expected result |
| --- | --- |
| User bought Stars on Android | Android and backend show Star balance after verification |
| User bought on web Paddle | Android can show existing backend entitlement only if policy-reviewed; Android must not link to Paddle |
| Android user taps web payment link | Not allowed; no Paddle CTA inside Android |
| Future iOS purchase | iOS uses StoreKit; backend platform field separates entitlement source |

## Release Build / AAB Plan

Current release identifiers:

- Package: `com.fiyou.app`
- App name: `FI-YOU`
- Version name: `1.0.0`
- Initial version code: `1`
- Privacy policy: `https://fi-you.vercel.app/privacy`

Build commands from Flutter project root:

```powershell
& "C:\Users\frog8\development\flutter\bin\flutter.bat" pub get
& "C:\Users\frog8\development\flutter\bin\cache\dart-sdk\bin\dart.exe" analyze
& "C:\Users\frog8\development\flutter\bin\flutter.bat" test
& "C:\Users\frog8\development\flutter\bin\flutter.bat" build appbundle --release `
  --dart-define=APP_ENV=production `
  --dart-define=SUPABASE_URL=<production-supabase-url> `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<production-supabase-publishable-key> `
  --dart-define=ANDROID_PACKAGE_NAME=com.fiyou.app
```

Final Play upload build command:

```powershell
$env:FIYOU_SUPABASE_URL="<production-supabase-url>"
$env:FIYOU_SUPABASE_PUBLISHABLE_KEY="<production-supabase-publishable-key>"

& "C:\Users\frog8\development\flutter\bin\flutter.bat" clean
& "C:\Users\frog8\development\flutter\bin\flutter.bat" pub get
& "C:\Users\frog8\development\flutter\bin\cache\dart-sdk\bin\dart.exe" analyze
& "C:\Users\frog8\development\flutter\bin\flutter.bat" test
& "C:\Users\frog8\development\flutter\bin\flutter.bat" build appbundle --release `
  --dart-define=APP_ENV=production `
  --dart-define=SUPABASE_URL=$env:FIYOU_SUPABASE_URL `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=$env:FIYOU_SUPABASE_PUBLISHABLE_KEY `
  --dart-define=ANDROID_PACKAGE_NAME=com.fiyou.app

New-Item -ItemType Directory -Force release/android | Out-Null
Copy-Item build/app/outputs/bundle/release/app-release.aab `
  release/android/fi-you-1.0.0+1-production-supabase-play-upload.aab
Get-FileHash release/android/fi-you-1.0.0+1-production-supabase-play-upload.aab -Algorithm SHA256
```

Final upload artifact rule:

- Old verification artifact: `release/android/fi-you-0.1.0+1-release.aab`
- Placeholder artifact: `release/android/fi-you-1.0.0+1-placeholder-supabase-release.aab`
- Final Play upload artifact: `release/android/fi-you-1.0.0+1-production-supabase-play-upload.aab`
- Never upload the old `0.1.0+1` artifact to Play Console.
- Never upload the placeholder artifact to Play Console.
- Never rename the placeholder artifact into the final upload name.
- Always rebuild from source with production Supabase dart-defines for the final upload AAB.

AAB path:

```text
build/app/outputs/bundle/release/app-release.aab
```

Verification:

- [x] Confirm `applicationId` is `com.fiyou.app`.
- [ ] Confirm app label is `FI-YOU`.
- [ ] Confirm `versionCode` is higher than previous Play upload.
- [ ] Confirm `versionName` is release-approved.
- [x] Confirm AAB can be signed with upload key.
- [ ] Confirm no Paddle checkout route/button is present in Android app.
- [ ] Confirm Google Play Billing product IDs match Play Console.
- [ ] Upload AAB to internal testing first.
- [ ] Install through Play internal testing on Android Studio Emulator with Play Store image.
- [ ] Sign in with license tester Google account.
- [ ] Run billing test scenarios.
- [ ] Review pre-launch report.

Version record format:

| Version code | Version name | Git ref | AAB SHA-256 | Track | Notes |
| --- | --- | --- | --- | --- | --- |
| 1 | 1.0.0 | local verification | `829AC7962E34E12C9933D856E7486F4833CB95BC6EA0CCE5F304FF11638131E4` | Not uploaded | Placeholder Supabase compile/signing verification only |

Local verification evidence, 2026-06-17:

- `dart analyze`: passed in `C:\Users\frog8\fiyou_release_verify\fi_you`.
- `flutter test`: passed in `C:\Users\frog8\fiyou_release_verify\fi_you`.
- `flutter build appbundle --release`: passed with placeholder Supabase dart-defines.
- Placeholder AAB copied to `release/android/fi-you-1.0.0+1-placeholder-supabase-release.aab`.
- Debug APK installed and launched on Android emulator `fi_you_api36`.
- First launch focused activity: `com.fiyou.app/.MainActivity`.
- First-launch screenshot: `C:\Users\frog8\fiyou_release_verify\fi_you\build\app-first-launch-pull.png`.
- Important: the placeholder AAB is not the final Play upload artifact. Rebuild with production Supabase values before upload.

### Build Warning Classification

| Warning | Release blocker? | Classification | Required action |
| --- | --- | --- | --- |
| Android SDK license warning | No if AAB build, install, and Play upload work; yes if Gradle/Play build starts failing | P2 operational cleanup | Accept licenses through Android Studio SDK Manager or `sdkmanager --licenses` on the release machine. Keep evidence if warning remains. |
| KGP plugin warning | Not currently blocking because analyze/test/build passed | P2 technical debt unless the warning becomes an error | Track Kotlin Gradle Plugin compatibility. Current observed config uses Kotlin plugin `2.3.20`; no release stop while signed AAB builds cleanly. |
| CupertinoIcons warning | Not a release blocker if unused dependency warning only | P3 cleanup | Remove unused dependency only if it appears in `pubspec.yaml` or causes analyzer/build warnings. Current `pubspec.yaml` does not list `cupertino_icons`. |

Warnings do not override policy gates. Any warning that prevents signed AAB generation, Play upload, install, product loading, or purchase verification becomes P0 immediately.

## Emulator Test Preparation

Use Android Studio Emulator with a Google Play system image.

- [ ] Create emulator with Play Store image.
- [ ] Sign into emulator with a license tester Google account.
- [ ] Install via Play internal testing opt-in, not raw local install for final billing QA.
- [ ] Confirm package name matches `com.fiyou.app`.
- [ ] Confirm products load from Play Console.
- [ ] Test card success/decline/pending flows.
- [ ] Test app restart during unfinished purchase.
- [ ] Test restore after reinstall.
- [ ] Capture screenshots for QA evidence.

## Internal Testing Upload Readiness

Before uploading any AAB to Play Console internal testing:

- [ ] Confirm upload artifact filename includes `production-supabase-play-upload`.
- [ ] Confirm artifact SHA-256 is recorded in this document or release notes.
- [ ] Confirm artifact was built with production `SUPABASE_URL`.
- [ ] Confirm artifact was built with production `SUPABASE_PUBLISHABLE_KEY`.
- [ ] Confirm placeholder AAB was not uploaded.
- [ ] Confirm Play app package is `com.fiyou.app`.
- [ ] Confirm Play app name is `FI-YOU`.
- [ ] Confirm privacy policy URL is `https://fi-you.vercel.app/privacy`.
- [ ] Confirm app category is selected, recommended `Lifestyle`.
- [ ] Complete Content Rating.
- [ ] Complete Data Safety using backend-confirmed data inventory.
- [ ] Complete Health apps declaration with non-medical positioning.
- [ ] Complete app access instructions and reviewer account if login is required.
- [ ] Add license tester Google accounts.
- [ ] Create Play products and subscriptions listed in Product ID Parity Checklist.
- [ ] Activate launch products or mark draft-only products intentionally.
- [ ] Create internal testing release.
- [ ] Upload final production Supabase AAB.
- [ ] Review Play Console warnings before rollout.
- [ ] Send opt-in link to license testers.
- [ ] Install through Play internal testing on AVD `fi_you_api36` or another Play Store emulator image.
- [ ] Run billing smoke tests before moving to closed testing.

User/team materials needed:

- Production Supabase URL.
- Production Supabase publishable key.
- Upload keystore and passwords stored outside Git.
- Play Console owner/admin access.
- Merchant/payment profile readiness.
- License tester Google accounts.
- Reviewer test account credentials if app login is required.
- Backend Google Play Developer API credentials.
- Pub/Sub / RTDN setup owner.
- Support contact email and refund/revoke process owner.

## Requests By Owner

### Backend

- Implement Google Play Developer API verification.
- Implement purchase token idempotency.
- Implement Star ledger grants.
- Implement report credit/unlock grants.
- Implement subscription entitlement state.
- Implement RTDN Pub/Sub endpoint.
- Implement Voided Purchases API polling.
- Provide entitlement read API for Flutter.
- Confirm privacy/Data Safety fields for billing data.
- Keep raw purchase tokens encrypted/restricted.

### Frontend / Flutter

- Integrate Play Billing through Flutter package compatible with Play Billing Library 9.x.
- Use product IDs from this document.
- Show Play-provided localized prices.
- Send tokens to backend for verification before granting UI access.
- Implement restore purchases.
- Implement pending/canceled/failed states.
- Remove all Android Paddle checkout entry points.
- Add non-pressuring Star/report purchase UI copy.
- Add emulator billing QA evidence.

### Product QA

- Approve Star pack amounts and prices.
- Approve paid report product list.
- Decide whether `fiyou_plus` subscription is active at launch or draft-only.
- Review all purchase copy for pressure and policy tone.
- Confirm free core loop is not blocked by payment.
- Approve refund/support handling.

### Release / Play Console

- Create products/subscriptions in Play Console.
- Add license testers.
- Upload AAB to internal testing.
- Run pre-launch report.
- Maintain version record.
- Prepare closed testing and production submission.

## Blocking Risks

| Risk | Severity | Current state | Next action |
| --- | --- | --- | --- |
| Production Supabase dart-defines not injected into final AAB | P0 | Placeholder values were used only for compile verification | Rebuild final AAB with production `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` |
| Play Console products not yet verified against app product IDs | P0 | Product IDs are defined in app/docs | Create/activate Play products and run internal billing QA |
| Billing backend verification not proven against Google Play API | P0 | Edge Function contract exists; live Google verification not yet tested | Configure Google service credentials and verify tokens from Play internal testing |
| Product prices not approved | P0 | Pending | Product QA to approve localized pricing |
| Subscription launch status undecided | P1 | Proposed optional | Product QA to choose active vs draft-only |
| Flutter CLI is not on PATH | P2 | Commands pass through explicit Flutter path | Add Flutter to PATH later for convenience |
| Android SDK licenses still reported by `flutter doctor` | P2 | Build/install succeeded; sdkmanager auto-accept is not completing cleanly | Accept licenses from Android Studio UI if doctor warning remains |
| Paddle route exists in current web app | P1 | Web-only is allowed; Android must not include it | Confirm Android build has no Paddle CTA |
| AAB ignore | Resolved | `.aab`, `.apk`, `.apks`, `.idsig`, and Flutter build outputs are ignored | Recheck before committing release artifacts |

## Current Judgment

Status: Conditional complete for local build verification. The app builds, analyzes, tests, produces a signed release AAB with placeholder Supabase values, and launches on an Android emulator as `com.fiyou.app`. Actual Play release remains blocked until the final production Supabase build, Play Console product setup, live Google Play purchase verification, internal testing install, and Product QA gate are completed.

## Official References Checked

- Google Play Billing overview: https://developer.android.com/google/play/billing
- Google Play Billing integration: https://developer.android.com/google/play/billing/integrate
- Google Play subscriptions, base plans, and offers: https://developer.android.com/google/play/billing/subscriptions
- Play Console subscription structure: https://support.google.com/googleplay/android-developer/answer/12154973
- Google Play Billing testing: https://developer.android.com/google/play/billing/test
- Google Play license testing: https://support.google.com/googleplay/android-developer/answer/6062777
- Google Play Payments policy: https://support.google.com/googleplay/android-developer/answer/10281818
- Google Play Billing Library release notes: https://developer.android.com/google/play/billing/release-notes
- Google Play Voided Purchases API: https://developers.google.com/android-publisher/voided-purchases
- Real-time developer notifications: https://developer.android.com/google/play/billing/rtdn-reference
