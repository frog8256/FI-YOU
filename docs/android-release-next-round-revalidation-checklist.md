# FI-YOU Android Release Next-Round Revalidation Checklist

Date: 2026-06-19
Owner: QA / Android Release Validation Lead
Purpose: 다음 Flutter 구현 라운드 완료 보고 직후, QA가 바로 실행할 Android 공식 출시 재검증 절차.

Current gate before this run: **Release Hold**

Expected fixes to verify:

- Android `applicationId` / `namespace` and release signing structure are corrected.
- Supabase live repository path is prepared.
- Settings legal / privacy / data deletion placeholders are removed.
- Insight report action is added.
- Store Billing-unconnected purchase CTA is disabled or gated.
- Bottom navigation overlap is removed.
- Diary minimum body length is relaxed.
- Question completion includes Diary CTA.
- U-Map 8-axis terminology is finalized.
- Valid PNG screenshots are recaptured.

## 1. Revalidation Decision Model

| Decision | Meaning |
| --- | --- |
| Pass | All P0 and P1 exit criteria below pass on Android emulator or real device. |
| Conditional Pass | No P0 remains, but one or more documented P2 items remain and PM accepts them for closed testing. |
| Fail / Release Hold | Any P0 remains, or a P1 affects core flow usability on common Android devices. |

## 2. P0 Exit Criteria

The build cannot proceed to Play internal / closed testing as a release candidate if any item below fails.

| Area | Exit criteria | Evidence |
| --- | --- | --- |
| App identity | Installed package is the approved release package, expected `com.fiyou.app` unless PM changes it. No leftover `com.fiyou.fi_you` package is used for release evidence. | `adb shell pm list packages`, Gradle config screenshot/log |
| Release signing | Release build no longer uses debug signing. Upload/release signing path is documented and buildable. | Build log / Gradle config |
| Static checks | `flutter analyze` and `flutter test` pass from a clean checkout. | Terminal log |
| Auth/session | First launch, Auth, Onboarding, Home entry work. App restart preserves expected signed-in/onboarded state, or intentionally returns to Auth only after logout/session expiry. | Video + UIAutomator dump |
| Supabase live path | Auth, Diary CRUD, Question answer save, Insight/U-Map read path, logout, deletion request use live/staging Supabase or are hard-gated out of release scope. No success toast may appear for unsaved mock data. | Network/backend evidence + screenshots |
| Legal/privacy/deletion | Settings links open real Terms and Privacy URLs. Data deletion/account deletion flow records or executes a real request and matches the policy text. No "출시 전", "준비 상태", "연결 예정" placeholder remains in release UI. | Screenshots + URL list |
| Safety/reporting | Insight detail has visible report action. Report submission succeeds or shows recoverable failure. AI/result copy does not use blocked terms: 진단, 상담, 치료, 처방, 정확도, 고정 유형, 성격유형, 궁합, 진짜 나, 정답, 정상/비정상, 결제하면 더 정확. | Screenshots + copy scan |
| Store/Billing | If Store is visible, Google Play Billing purchase, restore, entitlement, and failure states are connected. If not connected, all paid CTAs are disabled or Store is hidden in release build. | Store screenshots + Billing test result |
| Core flow | Auth -> Onboarding -> Home -> Question -> Clue Found -> Diary CTA -> Diary save -> U-Map reflection -> Insight detail is completable without crash or dead end. | Screen recording |
| Screenshot validity | Required PNG evidence files are valid PNGs and show nonblank app UI. | PNG signature check + visual review |

## 3. P1 Exit Criteria

P1 failures block production release and should block closed testing unless PM explicitly accepts the risk.

| Area | Exit criteria | Evidence |
| --- | --- | --- |
| Bottom nav overlap | Home, Diary, Explore, U-Map, My, Store, Settings have enough bottom inset. No CTA/card/list row is hidden behind nav on 1080x2400 or 720x1280. | Screenshots + bounds dump |
| Small screen | 720x1280 and 360x640-class viewport can complete all core flows without clipped primary actions or unreadable Korean. | Screenshots |
| Keyboard | Diary, Question text input, Onboarding name input remain visible with IME open. Primary save/next CTA can be reached by scroll. | Screen recording |
| Android back | Back dismisses dialogs/bottom sheets first, then returns to prior screen. Drafts are preserved where expected. Back from root follows product decision: exit app or confirm exit. | Screen recording |
| App restart | Saved Diary, completed Question/Clue, U-Map reflection, Insight feedback/report state survive force stop/relaunch. | Screen recording + backend check |
| Offline/error | Network off, slow network, save failure, session expiry, and empty states are user-readable and recoverable. No false success. | Screenshots |
| U-Map wording | 8-axis names and detail copy use "record/evidence/flow" framing, not score/diagnosis/fixed personality type. | Copy scan |
| Diary validation | Relaxed minimum length works as designed. Empty/too-short/body-only/title-only cases produce clear Korean errors and keep the draft. | Video |

## 4. P2 Exit Criteria

P2 can remain for internal testing if documented.

| Area | Exit criteria |
| --- | --- |
| Visual polish | Minor spacing, icon alignment, or wording polish that does not block comprehension or tapping. |
| Accessibility labels | Noncritical semantics gaps that do not block QA automation or screen-reader use for core flow. |
| Dependency freshness | Nonblocking package update warnings with no security or Play policy impact. |

## 5. Passable This Round vs Still Release Hold

These items can be marked Pass in this round if the expected fix is present and the exit criteria above pass:

- App identity and release signing structure.
- Static checks.
- Auth / Onboarding / Home entry.
- Bottom nav overlap removal.
- Store Billing-unconnected CTA disabled or Store hidden.
- Insight report action visible and submit path testable.
- Diary relaxed validation and draft preservation.
- Question completion Diary CTA.
- U-Map 8-axis wording.
- Valid PNG screenshot recapture.

These items remain **Release Hold** unless live/staging dependencies are demonstrably connected:

- Supabase Auth/session and personal data persistence.
- Diary create/read/update/delete against Supabase.
- Question answer save and Clue/U-Map/Insight reflection persistence.
- Data export/delete/account deletion server handling.
- Google Play Billing purchase/restore/entitlement if Store is visible.
- Real Terms, Privacy, and deletion URLs deployed and linked.
- Report submission persistence/review route for AI-generated insight content.

## 6. Pre-Run Commands

Run from:

```powershell
cd C:\Users\frog8\Desktop\project\Fi-You\mobile\fi_you
$Flutter = 'C:\Users\frog8\development\flutter\bin\flutter.bat'
$Adb = 'C:\Users\frog8\AppData\Local\Android\Sdk\platform-tools\adb.exe'
& $Flutter --version
& $Flutter pub get
& $Flutter analyze
& $Flutter test
& $Flutter devices
```

Expected:

- `flutter analyze`: no issues.
- `flutter test`: all tests pass.
- Android emulator or real device is listed.

## 7. Build And Install Procedure

Use debug build for first UI revalidation, then repeat release/AAB checks when signing is ready.

```powershell
cd C:\Users\frog8\Desktop\project\Fi-You\mobile\fi_you
$Flutter = 'C:\Users\frog8\development\flutter\bin\flutter.bat'
$Adb = 'C:\Users\frog8\AppData\Local\Android\Sdk\platform-tools\adb.exe'
$Device = 'emulator-5554'
$Pkg = 'com.fiyou.app'

& $Flutter build apk --debug
& $Adb -s $Device uninstall $Pkg
& $Adb -s $Device install -r .\build\app\outputs\flutter-apk\app-debug.apk
& $Adb -s $Device shell pm list packages | Select-String 'fiyou|fi_you'
& $Adb -s $Device shell monkey -p $Pkg -c android.intent.category.LAUNCHER 1
```

If package launch fails, check whether the build still uses the old package:

```powershell
& $Adb -s $Device shell pm list packages | Select-String 'fiyou|fi_you'
```

Release build check when signing is ready:

```powershell
& $Flutter build appbundle --release
Get-ChildItem .\build\app\outputs\bundle\release
```

## 8. Evidence Capture Procedure

Create a fresh evidence folder for every run.

```powershell
cd C:\Users\frog8\Desktop\project\Fi-You\mobile\fi_you
$Adb = 'C:\Users\frog8\AppData\Local\Android\Sdk\platform-tools\adb.exe'
$Device = 'emulator-5554'
$Run = Get-Date -Format 'yyyyMMdd-HHmm'
$Out = "screenshots\revalidation-$Run"
New-Item -ItemType Directory -Force $Out | Out-Null
```

Capture screen and UI hierarchy after each checkpoint:

```powershell
& $Adb -s $Device shell uiautomator dump /sdcard/qa.xml
& $Adb -s $Device pull /sdcard/qa.xml "$Out\##_screen.xml"
& $Adb -s $Device exec-out screencap -p > "$Out\##_screen.png"
```

Validate PNG signature:

```powershell
$png = "$Out\##_screen.png"
$bytes = [System.IO.File]::ReadAllBytes((Resolve-Path $png))
$signature = ($bytes[0..7] | ForEach-Object { $_.ToString('X2') }) -join ' '
$signature
```

Expected PNG signature:

```text
89 50 4E 47 0D 0A 1A 0A
```

## 9. Core Flow Revalidation

Record one continuous video if possible, then capture still PNGs at each checkpoint.

| Step | Action | Expected |
| --- | --- | --- |
| 1 | Clear app data, launch app. | First launch starts at Auth or approved onboarding gate. No mock-only copy in release mode. |
| 2 | Complete Auth. | User identity/session created or staging login succeeds. Legal consent links reachable if required. |
| 3 | Complete Onboarding. | Home opens and onboarding state persists after restart. |
| 4 | Open Home. | No overflow, no bottom nav overlap, safe copy, U-Map and Insight surfaces are tappable. |
| 5 | Open Insight Detail. | Evidence/source visible. Edit/disagree/hide/report actions visible. Report path works. |
| 6 | Open Explore and start Question. | Step indicators, Korean text, option/text input states render cleanly. |
| 7 | Complete Question. | Clue Found appears. Save failure state is testable if network is disabled. |
| 8 | Tap Diary CTA from Question completion. | Diary write or related Diary destination opens. Draft context is preserved if expected. |
| 9 | Save Diary with relaxed length. | Valid entry saves to backend/local staging state; U-Map reflection cue appears. |
| 10 | Open Diary detail, edit, delete. | Edit persists. Delete confirms, removes record, empty state appears if no records remain. |
| 11 | Open U-Map. | 8-axis terminology is final. Low-data state appears when data is insufficient. |
| 12 | Open U-Map Axis Detail. | Evidence, record count, "not fixed" limitation copy visible. No score/diagnosis framing. |
| 13 | Open Store/Star. | Billing-connected flow works, or all purchase CTAs are disabled/hidden. Restore behavior is clear. |
| 14 | Open My/Settings. | Notifications, legal, data download/delete, logout, account deletion are real or properly gated. |
| 15 | Force stop and relaunch. | Session, onboarding, saved data, report/feedback state persist as designed. |

## 10. Android-Specific Procedures

### Small Screen

```powershell
$Adb = 'C:\Users\frog8\AppData\Local\Android\Sdk\platform-tools\adb.exe'
$Device = 'emulator-5554'
try {
  & $Adb -s $Device shell wm size 720x1280
  Start-Sleep -Seconds 1
  # Repeat Home, Diary, Question, U-Map, My/Settings screenshots.
}
finally {
  & $Adb -s $Device shell wm size reset
}
```

Pass:

- Bottom nav never covers content or touch targets.
- Primary CTA remains reachable.
- Korean text wraps cleanly without clipping.

### Keyboard

Test Onboarding name, Question text answer, Diary title/body.

```powershell
& $Adb -s $Device shell input tap <x> <y>
& $Adb -s $Device shell input text "qa_text_input"
```

Pass:

- Focused field is visible with keyboard open.
- Save/Next CTA can be reached by scroll.
- Back first dismisses keyboard, then navigates.

### Back Navigation

```powershell
& $Adb -s $Device shell input keyevent 4
```

Pass:

- Dialog/bottom sheet closes first.
- Detail screen returns to source screen.
- Unsaved Diary draft is preserved or confirm-discard is shown.
- Root tab behavior matches PM decision.

### App Restart Persistence

```powershell
& $Adb -s $Device shell am force-stop $Pkg
Start-Sleep -Seconds 1
& $Adb -s $Device shell monkey -p $Pkg -c android.intent.category.LAUNCHER 1
```

Pass:

- Auth/session state is correct.
- Onboarding completion persists.
- Saved Diary and Question/Insight/U-Map state persists.
- Pending report/delete requests are not lost or falsely marked complete.

### Network Off / Slow

```powershell
& $Adb -s $Device shell svc wifi disable
& $Adb -s $Device shell svc data disable
# Run save/report/delete attempts.
& $Adb -s $Device shell svc wifi enable
& $Adb -s $Device shell svc data enable
```

Pass:

- No false success.
- User sees recoverable Korean error.
- Draft/input is preserved.
- Retry succeeds after network restore.

## 11. Copy Scan

Run before device QA and again before final report:

```powershell
cd C:\Users\frog8\Desktop\project\Fi-You\mobile\fi_you
rg "진단|상담|치료|처방|정확도|고정 유형|성격유형|궁합|진짜 나|정답|정상|비정상|결제하면 더 정확|출시 전|준비 상태|연결 예정" lib pubspec.yaml android
```

Pass:

- Blocked product-safety terms do not appear in user-facing release copy.
- Placeholder terms do not appear in release UI.
- "고정된 설명이 아니에요" style limitation copy is allowed.

## 12. Final Report Template

Use this format after the revalidation run:

```text
QA 판정: Pass / Conditional Pass / Fail

Pass 처리:
- ...

Release Hold:
- ...

P0:
- [area] finding, evidence path, reproduction

P1:
- [area] finding, evidence path, reproduction

P2:
- ...

실행 명령:
- flutter analyze: ...
- flutter test: ...
- build/install: ...

검증하지 못한 항목:
- item, reason, owner

Flutter App Lead 수정 지시:
- actionable item

Supabase/Store/Safety Lead 수정 지시:
- actionable item
```
