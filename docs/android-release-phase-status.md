# FI-YOU Android Release Phase Status

Updated: 2026-06-17

## Confirmed Release Baseline

- Android package name: `com.fiyou.app`
- App display name: `FI-YOU`
- Privacy policy URL: `https://fi-you.vercel.app/privacy`
- Android payment: Google Play Billing
- Web payment: Paddle only
- Future iOS payment: StoreKit / Apple IAP
- Release scope includes questions, Diary, U-Map, Signature, relations, Star, paid reports, and payments.

## Phase Status

| Phase | Status | Notes |
| --- | --- | --- |
| Phase 0. Release criteria | Done | Package/payment/privacy/release scope decisions are reflected in app and docs. |
| Phase 1. Frontend + Backend connection | Partially done | Flutter uses Supabase when release dart-defines are present. Release mock fallback is blocked by `kReleaseMode`. |
| Phase 2. Backend/Supabase stabilization | Partially done | Release RPC compatibility layer has been applied to Supabase. Function execute permissions are restricted to `authenticated`. |
| Phase 3. AI Logic connection | Partial | U-Map reads `u_map_snapshots`; Signature currently returns null so the app uses safe "records are still gathering" copy. Full AI generation pipeline is still needed. |
| Phase 4. Payment/Star/Paid reports | Partially done | Google Play Billing is implemented in Flutter and the `verify-google-play-purchase` Edge Function is deployed with JWT verification. Google Play service account env vars still must be configured before real purchase verification. |
| Phase 5. Frontend release quality | Partially done | Store/Billing user-facing strings were fixed. No Paddle usage remains in Android app code. |
| Phase 6. Release build | Done for placeholder build | AAB builds successfully from ASCII path with placeholder Supabase publishable key. This is not a Play upload candidate until real release env values and Play Billing configuration are complete. |
| Phase 7. Play Console preparation | Not verified in repo | Play Console app/product/internal test setup must be checked in the console. |
| Phase 8. QA validation | Partial | Flutter smoke test passes. Emulator launch was previously verified. Real authenticated Supabase flow and purchase flow still need test accounts/tokens. |
| Phase 9. Final release decision | Hold | Release is not approved until remaining blockers are cleared. |

## Completed Technical Work

- Added Supabase migration `20260617133000_release_rpc_compatibility.sql`.
- Applied release RPCs to Supabase project `debgzfnbthaipqvbytko`.
- Verified app RPC execute privileges:
  - `anon_can_execute = false`
  - `authenticated_can_execute = true`
- Deployed Edge Function `verify-google-play-purchase`.
- Verified Edge Function status: `ACTIVE`, `verify_jwt = true`.
- Fixed Android Store/Billing screen copy to readable Korean release copy.
- Removed visible website `MVP` copy in `src/lib/i18n.tsx`.
- Confirmed Android app scan has no Paddle checkout usage.

## Latest Local Verification

- Web lint: pass
- Web build: pass
- Flutter test: pass
- Flutter static analysis: pass via `dart.exe analyze`
- AAB build from ASCII path: pass

Latest placeholder AAB:

- Path: `C:\Users\frog8\fiyou_release_verify\fi_you_current\build\app\outputs\bundle\release\app-release.aab`
- SHA-256: `56E019FF5B47895F09285FC5C05CB81C95FE97B839DEBC6181E7F837F32F44B1`
- Size: `54,098,561` bytes

## Current Release Blockers

1. Supabase Edge Function secrets are not confirmed:
   - `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
   - Optional: `GOOGLE_PLAY_PACKAGE_NAME=com.fiyou.app`
   - Supabase default envs must be available: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`
2. Google Play Console in-app products/subscription IDs must exist and match Flutter:
   - `fiyou_star_100`
   - `fiyou_star_300`
   - `fiyou_star_700`
   - `fiyou_star_1500`
   - `fiyou_report_umap_deep_1`
   - `fiyou_report_signature_deep_1`
   - `fiyou_report_relation_1`
   - `fiyou_report_past_self_1`
   - `fiyou_plus`
3. Real purchase verification is not tested.
4. Full AI generation pipeline for U-Map/Signature/report bodies is not complete.
5. Paid report storage/body generation is still placeholder-level.
6. Supabase Auth leaked password protection remains disabled in Supabase Dashboard.
7. Play Console Data Safety, Content Rating, internal testing, and product activation still require console-side confirmation.

## Product QA Decision

Current decision: **Release Hold**

Reason: core app build and RPC connectivity are now much stronger, but payment verification secrets, real purchase QA, AI/report generation, and Play Console setup are still not fully verified.
