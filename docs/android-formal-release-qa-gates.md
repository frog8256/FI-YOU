# FI-YOU Android Formal Release QA Gates

Last updated: 2026-06-17
Owner: Product QA & Policy Lead
Scope: Flutter Android formal release readiness, internal testing, closed testing, signed AAB, Play Console materials
Out of scope: Official website launch work, web marketing pages, web pricing pages

## 0. Current Judgment

현재 판정: 출시 보류

이유:

- 현재 로컬 검증 결과 `com.fiyou.app` 에뮬레이터 설치/실행, 첫 화면 렌더링, `dart analyze`, `flutter test`, release AAB build는 통과로 보고되었다.
- 첫 화면 문구 "기록을 따라 지금의 흐름을 살펴봐요."와 "FI-YOU는 전문적 판단을 대신하지 않는 자기탐구 앱이에요."는 FI-YOU 철학에 부합한다.
- 다만 release AAB가 Supabase placeholder 기준이므로 최종 Play 업로드본이 아니다.
- Play Billing evidence, Supabase live data 저장/조회 evidence, RLS evidence, Play Console internal/closed testing evidence, Data Safety final evidence가 아직 없다.
- 이번 출시 범위에는 질문, Diary, U-Map, Signature, 관계 기능, Star, 유료 리포트, 결제가 포함된다. 결제가 포함되는 순간 Google Play Billing, entitlement 지급, 환불/복원, Data Safety 일치 여부가 P0다.
- FI-YOU의 철학, 개인정보, AI 생성 콘텐츠, 관계 기능, 결제 권한 지급이 모두 맞물려야 하므로 문서 기준만으로는 조건부 승인도 불가하다.

## 1. Confirmed Release Parameters

| 항목 | 확정 기준 |
| --- | --- |
| Android package name | `com.fiyou.app` |
| App name | `FI-YOU` |
| Android internal payment | Google Play Billing |
| Web payment | Paddle, web checkout only |
| Future iOS internal payment | Apple StoreKit / In-App Purchase |
| Privacy Policy URL | `https://fi-you.vercel.app/privacy` |
| Release scope | Questions, Diary, U-Map, Signature, relationship features, Star, paid reports, payment |
| Website scope | Not part of core Android release readiness, except privacy/deletion/legal URLs if used by Play Console |
| First QA device target | Android Studio emulator for Phase 0/9/10; real-device QA remains required before production release approval |

## 2. Release Decision Rules

출시 가능:

- P0 issue가 없다.
- Mock Repository release 경로가 제거되고 Supabase 실데이터 저장/조회가 정상이다.
- RLS 격리 검증이 완료되었다.
- Play Billing 결제, 구매 검증, entitlement 지급, 복원, 실패/취소 처리가 통과했다.
- Star 잔액, 차감, 유료 리포트 권한 지급이 서버 기준으로 정합하다.
- 관계 기능이 개인정보 최소화, RLS, 비단정 문구 기준을 통과했다.
- 계정 삭제와 데이터 삭제가 가능하고, 개인정보처리방침 링크가 앱/Play Console에서 정상 연결된다.
- Play Console Data Safety 답변과 실제 앱 동작/SDK/서버 저장 항목이 일치한다.
- FI-YOU 철학 위반 문구가 없다.
- Emulator 기준 Phase 0/9/10 QA가 통과하고, production 제출 전 실기기 QA 계획과 책임자가 확정되어 있다.

조건부 가능:

- P0는 모두 해결되었고, 남은 항목이 P1/P2뿐이다.
- 내부 테스트 또는 Closed testing에 한해 emulator evidence를 임시 인정할 수 있다.
- 결제/개인정보/계정 삭제/AI 생성 콘텐츠 신고/관계 기능 RLS에는 조건부 예외를 두지 않는다.

출시 보류:

- P0가 하나라도 남아 있다.
- 결제 포함 출시인데 Play Billing evidence 또는 entitlement evidence가 없다.
- Supabase 실데이터/RLS/삭제 정책이 검증되지 않았다.
- 문구가 진단, 치료, 상담, 고정 유형, 궁합 단정, 더 정확한 분석처럼 보인다.
- 관계 기능이 상대방을 평가/진단하거나 타인의 개인정보를 과도하게 요구한다.

## 3. Mandatory QA Gates

| Gate | 영역 | 통과 기준 | 필수 evidence |
| --- | --- | --- | --- |
| Gate 1 | 제품 철학/문구 정책 | 질문, Diary, U-Map, Signature, 관계, 리포트, 결제 화면이 기록 기반/관찰적/변화 가능 톤을 유지한다. | 전체 copy export, 주요 화면 캡처, AI 출력 샘플 |
| Gate 2 | 핵심 사용자 루프 | 로그인 -> 온보딩 -> 질문 -> Diary -> U-Map -> Signature -> 다음 질문이 끊기지 않는다. | Emulator screen recording, QA checklist |
| Gate 3 | Supabase/RLS/삭제 | Mock Repository release 제거, 실데이터 저장/조회 정상, 사용자별 RLS 격리, 계정/데이터 삭제 정상. | Schema, RLS policy, RLS test result, deletion test |
| Gate 4 | 관계 기능 | 타인 개인정보 최소화, 상대방 진단 금지, 관계 단정 금지, 관계 데이터 RLS 통과. | 관계 플로우 캡처, 저장 데이터 목록, RLS test |
| Gate 5 | Star/유료 리포트/결제 | Play Billing 결제, 취소, 실패, 복원, 구매 검증, Star 지급/차감, 유료 리포트 entitlement가 정상이다. | Billing test log, backend receipt validation evidence, entitlement DB evidence |
| Gate 6 | 개인정보/정책 | Privacy URL 정상, 앱 내 약관/개인정보/면책/삭제 접근 가능, Data Safety와 실제 동작 일치. | URL check, in-app settings capture, Data Safety draft |
| Gate 7 | Android build | `com.fiyou.app`, signed AAB, production config, no debug banner, no dev endpoint, versioning 정상. | AAB info, signing proof without secrets, build log |
| Gate 8 | Emulator QA | Phase 0/9/10은 Android Studio emulator로 내부 테스트 전 smoke QA를 통과한다. | Emulator version/device profile, screen recording, logs |
| Gate 9 | Play Console 준비 | Store listing, screenshots, app access, Data Safety, content rating, ads/payment/AI disclosures가 준비된다. | Play Console draft screenshots/exports |
| Gate 10 | Internal/Closed testing 준비 | tester task, reviewer credential, support/reporting path, rollout stop condition이 준비된다. | Test plan, tester list, reviewer notes |

## 4. P0 Blocking Issues

| P0 issue | 이유 | 수정 방향 |
| --- | --- | --- |
| Mock Repository release 잔존 | 실제 사용자 데이터/권한/결제 검증이 불가능하다. | Release build에서 Mock Repository를 제거하고 Supabase production/staging backend로 연결한다. |
| Supabase 저장/조회 실패 | Diary/U-Map/Signature/리포트가 제품적으로 연결되지 않는다. | 질문, Diary, 관계, Star, entitlement, AI output 저장/조회 API를 검증한다. |
| RLS 격리 미검증 | Diary/관계/결제 권한 데이터 유출 위험이다. | 모든 user-owned table에 RLS를 적용하고 cross-user read/write denial evidence를 제출한다. |
| Play Billing 미검증 | Android 내부 디지털 상품 결제 정책 위반 및 매출/권한 지급 실패 위험이다. | Google Play Billing test purchase, pending/cancel/failure/restore, server verification을 통과시킨다. |
| Paddle이 Android 내부 결제로 노출 | Google Play 결제 정책 리스크가 크다. | Android 앱 내부 디지털 상품은 Play Billing만 사용하고 Paddle은 web checkout 전용으로 분리한다. |
| Star/유료 리포트 entitlement 지급 오류 | 결제 후 사용자가 권한을 못 받거나 중복 지급될 수 있다. | 서버 기준 idempotent purchase processing, balance ledger, entitlement table을 검증한다. |
| 질문 자체를 판매하거나 핵심 루프 전 결제를 압박 | FI-YOU 철학과 초기 경험을 훼손한다. | 질문/Diary/U-Map/Signature 기본 루프를 먼저 경험하게 하고 결제는 심화 리포트/추가 기능으로 제한한다. |
| 관계 기능이 상대방을 진단/평가 | 비동의 타인 분석, 궁합 단정, 심리상담 오해 리스크가 있다. | 관계 기능은 사용자의 기록 속 상호작용 흐름만 다루고 상대방 정체성/성향 단정을 금지한다. |
| 계정 삭제/데이터 삭제 불가 | Play account deletion 및 개인정보 리스크다. | 앱 내 삭제 경로와 외부 삭제 URL을 제공하고 실제 데이터 삭제 evidence를 제출한다. |
| Privacy URL 연결 실패 | Play Console 및 사용자 신뢰 P0다. | `https://fi-you.vercel.app/privacy`를 앱/스토어에서 열 수 있게 검증한다. |
| Data Safety와 실제 앱 동작 불일치 | Play 심사/정책 위반 리스크다. | SDK, 수집 데이터, 공유, 암호화, 삭제 가능 여부를 실제 구현과 맞춘다. |
| FI-YOU 금지 문구 잔존 | 진단/유형화/상담/의료 오해가 발생한다. | 전체 copy export와 AI 출력에서 금지 문구를 제거하고 대체 표현으로 교체한다. |

## 5. P1 Important Issues

| P1 issue | 이유 | 수정 방향 |
| --- | --- | --- |
| Emulator만 통과하고 실기기 계획이 없다 | 내부 테스트 전은 가능하나 production 승인에는 부족하다. | 최소 2개 Android 실기기 QA 계획, 담당자, 일정, device matrix를 확정한다. |
| 결제 실패/취소 UX가 차갑거나 압박적이다 | 결제 불안과 이탈을 만든다. | 실패/취소 후 기본 루프로 돌아갈 수 있게 하고 재시도는 부드럽게 제안한다. |
| 유료 리포트 copy가 "더 정확한 분석"처럼 보인다 | 결제가 정확도를 산다는 오해를 만든다. | "더 깊은 기록 기반 리포트", "추가 관찰", "확장된 정리"로 수정한다. |
| 관계 기능 empty state가 궁합 기대를 만든다 | 사용자가 타인을 평가하는 기능으로 오해할 수 있다. | "관계 속 나의 반응 흐름" 중심으로 안내한다. |
| AI 신고/피드백 후 운영 프로세스가 불명확하다 | 신고는 있지만 처리 책임이 비어 있을 수 있다. | 접수 위치, triage owner, 삭제/수정/차단 기준을 문서화한다. |

## 6. P2 Later Issues

| P2 issue | 처리 방향 |
| --- | --- |
| 고급 성장 알림/리텐션 실험 | 출시 후 백로그. 결제/관계/삭제 안정화 이후 진행한다. |
| 웹 결제 전환 최적화 | Android 출시 핵심 범위 아님. Paddle은 web checkout 전용으로만 유지한다. |
| iOS 결제 상세 구현 | 향후 StoreKit / Apple In-App Purchase 기준으로 별도 QA Gate를 만든다. |
| 고급 리포트 디자인/공유 기능 | 개인정보/AI 문구 안정화 후 검토한다. |

## 7. Payment-Included Release Policy

Android:

- Android 앱 내부에서 디지털 상품, Star, 유료 리포트, 구독, 기능 잠금 해제를 판매하면 Google Play Billing을 사용한다.
- 구매 검증은 클라이언트 단독이 아니라 서버 기준으로 처리한다.
- Star 지급과 유료 리포트 entitlement는 idempotent하게 처리한다.
- 구매 실패, 취소, pending, refund, restore 상태를 QA한다.
- 결제 성공 후 사용자가 즉시 권한을 확인할 수 있어야 한다.
- 결제 화면은 핵심 루프를 막지 않는다.
- 질문 자체는 판매하지 않는다.
- "결제하면 더 정확해진다"는 표현을 금지한다.

Web:

- Paddle은 web checkout 전용이다.
- Android 앱 내부에서 Paddle checkout을 열어 디지털 상품을 판매하지 않는다.
- Web에서 구매한 entitlement를 Android에서 사용할 경우, Play 정책/계정/권한 동기화 리스크를 별도 검토한다.

Future iOS:

- iOS 앱 내부 디지털 상품은 Apple StoreKit / In-App Purchase 기준으로 별도 구현한다.
- Android Play Billing 구현을 iOS 결제 정책의 근거로 재사용하지 않는다.

## 8. Payment UX QA Criteria

- [ ] 질문 자체를 판매하지 않는다.
- [ ] 로그인/온보딩/첫 질문/Diary/U-Map/Signature/다음 질문 기본 루프가 결제 없이 먼저 경험된다.
- [ ] Star/유료 리포트는 심화 탐구로만 제안된다.
- [ ] 결제 CTA는 압박, 불안 유도, 손실 회피 문구를 쓰지 않는다.
- [ ] 결제 실패/취소 후 기본 루프로 자연스럽게 복귀한다.
- [ ] 유료 리포트는 "정확도 상승"이 아니라 "더 긴 기록 정리" 또는 "확장된 관찰"로 설명한다.
- [ ] 구매 내역, Star 잔액, 리포트 권한, 환불/문의 경로가 확인 가능하다.
- [ ] 중복 결제/중복 지급/네트워크 재시도 상황에서 ledger가 깨지지 않는다.

## 9. Relationship Feature QA Criteria

- [ ] 관계 기능은 사용자의 기록 속 상호작용 흐름을 다룬다.
- [ ] 상대방의 성격, 심리, 의도, 진단, 미래 행동을 단정하지 않는다.
- [ ] "궁합이 맞다/안 맞다"를 금지한다.
- [ ] 타인의 민감정보 입력을 요구하지 않는다.
- [ ] 상대방 이름/연락처/식별정보는 필수값으로 요구하지 않는다.
- [ ] 관계 데이터는 사용자별 RLS로 격리된다.
- [ ] 관계 리포트도 기록 기반, 현재 흐름, 변화 가능성을 포함한다.
- [ ] 관계 기능은 상담, 치료, 갈등 해결 보장처럼 보이지 않는다.
- [ ] 공유 기능이 있다면 상대방 동의/개인정보 노출 리스크를 별도 검수한다.

## 10. Copy Ban / Replacement Policy

| 금지 표현 | 이유 | 대체 표현 |
| --- | --- | --- |
| 당신은 OO형입니다 | 고정 유형화 | 현재까지의 기록을 바탕으로 이런 흐름이 보여요 |
| 정확도 | 진단/측정처럼 보임 | U-Map 선명도 |
| 분석 정확도 | 결제/AI가 정답을 제공한다는 오해 | 기록 기반 선명도, 흐름의 선명함 |
| 진단 | 의료/심리 평가 오해 | 자기이해를 위한 참고 |
| 치료 | 의료 행위 오해 | 탐구, 기록, 돌아보기 |
| 상담 | 전문 상담 서비스 오해 | AI 기반 자기이해, 기록 기반 정리 |
| 궁합이 맞다/안 맞다 | 관계 단정/운명화 | 관계 속에서 이런 상호작용 흐름이 보여요 |
| 더 정확한 분석 | 결제가 정확도를 산다는 오해 | 더 넓은 기록을 바탕으로 한 확장 리포트 |
| 당신은 이런 사람입니다 | 정체성 단정 | 지금 기록에서는 이런 경향이 조금 보여요 |
| 변하지 않는 Signature | 고정 정체성 | 기록이 쌓이면 Signature는 달라질 수 있어요 |

필수 문구 패턴:

- "현재까지의 기록을 바탕으로"
- "이런 흐름이 보여요"
- "U-Map 선명도"
- "기록이 쌓이면 달라질 수 있어요"
- "FI-YOU는 의료적 조언, 진단, 치료, 상담 또는 긴급 지원을 제공하지 않습니다."

## 11. Internal Testing QA Checklist

Phase 0/9/10 기준: Android Studio emulator evidence를 1차로 인정한다. Production 승인 전 실기기 evidence는 별도 필요하다.

| 영역 | 테스트 | 통과 기준 |
| --- | --- | --- |
| Install/Launch | Release-equivalent build 설치/실행 | 앱 이름 FI-YOU, package `com.fiyou.app`, debug banner 없음 |
| Login | 가입/로그인/로그아웃 | 계정 생성과 세션 복구 정상 |
| Onboarding | 온보딩 완료 | 비의료/비상담/자기이해 안내 후 첫 질문으로 이동 |
| Question | 질문 응답 저장 | Supabase에 저장되고 다시 조회됨 |
| Diary | 작성/수정/조회 | Diary가 사용자 계정에 저장되고 U-Map/Signature 입력으로 연결됨 |
| U-Map | U-Map 확인 | 선명도/흐름/기록 기반 문구 사용, 정확도 표현 없음 |
| Signature | Signature 확인 | 고정 유형처럼 보이지 않고 변화 가능성을 표시 |
| Next question | 다음 질문 추천 | 사용자가 다음 행동을 명확히 알 수 있음 |
| Star | 잔액/지급/차감 | 서버 ledger와 UI 잔액 일치 |
| Payment | Play Billing test purchase | 성공/실패/취소/pending/복원 처리 정상 |
| Paid report | 리포트 권한 | 결제/Star 차감 후 entitlement 지급, 재접속 후 유지 |
| Relationship | 관계 플로우 | 타인 진단/궁합 단정 없음, 최소 개인정보, RLS 통과 |
| Account deletion | 계정 삭제 | 앱 내 경로 존재, 삭제 후 데이터 접근 불가 |
| Privacy | Privacy URL | `https://fi-you.vercel.app/privacy` 정상 연결 |
| Network failure | offline/slow/failure | 데이터 손상 없이 retry/복귀 가능 |
| Copy policy | 전체 문구 scan | 금지 표현 없음 |
| Data Safety | 앱 동작 비교 | Play Console 답변과 실제 SDK/데이터 처리 일치 |

## 12. Evidence Request Format For Threads

각 스레드는 아래 형식으로 산출물을 제출한다.

```text
Thread:
Owner:
Build/version:
Scope:

Evidence:
- Screenshots / recordings:
- Source files / PR:
- Test logs:
- DB evidence:
- Policy/copy evidence:

Known gaps:
- P0:
- P1:
- P2:

Requested Product QA decision:
- 출시 가능 / 조건부 가능 / 출시 보류
```

Frontend Lead evidence:

- 전체 화면맵과 emulator 녹화.
- 로그인, 온보딩, 질문, Diary, U-Map, Signature, 다음 질문, Star, 결제, 유료 리포트, 관계, 계정 삭제 화면.
- 전체 copy export.
- 결제 실패/취소/복원 UX 캡처.

Backend & Supabase evidence:

- Schema, API contract, production/staging environment 구분.
- Mock Repository 제거 증거.
- Supabase 실데이터 저장/조회 로그.
- RLS test result.
- 삭제 procedure와 삭제 후 접근 불가 evidence.
- Star ledger, paid report entitlement, relationship data isolation evidence.

AI Logic evidence:

- 질문/U-Map/Signature/관계/유료 리포트 샘플 출력.
- 금지 문구 scan 결과.
- 비의료/비상담/변화 가능성 caveat.
- 민감 입력 안전 fallback.

Release & Store QA evidence:

- `com.fiyou.app` signed AAB 정보.
- Google Play Billing test evidence.
- Play Console store listing, Data Safety, content rating, app access, privacy URL, AI-generated content reporting 답변.
- Internal/Closed testing tester task와 reviewer notes.

Growth/Monetization evidence:

- Star/유료 리포트 가격/권한표.
- 결제 CTA copy.
- 질문 자체 판매가 없다는 확인.
- Android Play Billing, Web Paddle, future iOS StoreKit 분리 정책 확인.

## 13. Official Policy References Checked

- Google Play Billing: https://developer.android.com/google/play/billing
- Google Play Payments policy: https://support.google.com/googleplay/android-developer/answer/10281818
- Google Play Data safety form: https://support.google.com/googleplay/android-developer/answer/10787469
- Google Play account deletion guidance: https://android-developers.googleblog.com/2024/03/designing-your-account-deletion-experience-google-play.html
- Google Play User Data policy: https://support.google.com/googleplay/android-developer/answer/10144311
- Google Play AI-generated content policy: https://support.google.com/googleplay/android-developer/answer/14094294
