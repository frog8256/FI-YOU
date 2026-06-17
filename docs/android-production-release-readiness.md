# FI-YOU Android Production Release Readiness

Last updated: 2026-06-17

Scope: Flutter Android official release preparation. The official website is out of scope. Android in-app monetization is in scope and must use Google Play Billing.

Role priority: Release & Store QA Lead. Release readiness, Play Console submission, policy compliance, signed AAB preparation, Google Play Billing readiness, and post-launch monitoring take priority over website work.

## Release Decisions

| Item | Decision / Recommendation | Owner Check |
| --- | --- | --- |
| Package name | `com.fiyou.app` | Product + Android |
| App name | `FI-YOU` | Product |
| Version name | Start with `1.0.0` for official launch | Release |
| Version code | Start with `1`; increment on every Play upload | Android |
| minSdk | Recommend API 23 or higher. Use API 23 for wider coverage unless a dependency requires higher. | Android |
| targetSdk | API 35 or higher for Google Play submissions as of current Play requirements | Android |
| Build artifact | Android App Bundle: `.aab` | Release |
| Signing | Play App Signing enabled; local upload key signs AAB uploads | Release |
| Monetization | Included. Android in-app purchases must use Google Play Billing. Web checkout uses Paddle only outside the Android app. Future iOS uses StoreKit / In-App Purchase. | Product |
| Ads | Disabled for first official Android release unless explicitly approved and declared | Product |

## Android Release Checklist

### P0 Build Configuration

- [ ] Flutter Android project exists in release repository.
- [ ] `applicationId` is fixed to the selected package name.
- [ ] App label is `FI-YOU`.
- [ ] `versionName` and `versionCode` are set in `pubspec.yaml` or Gradle.
- [ ] `targetSdk` is API 35 or higher.
- [ ] `minSdk` is confirmed against all dependencies.
- [ ] Release build uses production API endpoints only.
- [ ] Debug logging, debug banners, mock data, and local endpoints are removed.
- [ ] Internet permission is present only if required.
- [ ] Sensitive permissions are not requested unless needed by shipped features.
- [ ] Android 13+ notification permission behavior is handled if reminders are shipped.
- [ ] App icon, adaptive icon, and splash are production assets.
- [ ] App supports intended orientation and screen sizes.
- [ ] ProGuard/R8 release behavior is tested.
- [ ] Crash reporting, logging, and analytics are configured for production, if used.

### P0 Product QA

- [ ] Clean install opens successfully.
- [ ] Onboarding completes.
- [ ] Account creation/sign-in works if accounts are required.
- [ ] User can answer questions.
- [ ] User can create and reopen Diary entries.
- [ ] User can view U-Map or clear insufficient-data state.
- [ ] User can view Signature or clear insufficient-data state.
- [ ] User can continue to the next recommended question.
- [ ] Offline / slow-network states are understandable.
- [ ] AI output avoids diagnosis, treatment, therapy, counseling, and certainty claims.
- [ ] User can report or flag concerning AI-generated output in-app.
- [ ] Settings include privacy, terms, AI limitations, and deletion/account controls as applicable.

### P0 Store QA

- [ ] Privacy policy URL is live and accessible without login: `https://fi-you.vercel.app/privacy`.
- [ ] Terms URL is live and accessible without login.
- [ ] Data deletion URL is live if account creation is supported.
- [ ] Support/contact email is active.
- [ ] Play Console app access instructions are prepared if login is required.
- [ ] Data safety form answers match actual app, backend, and SDK behavior.
- [ ] Health apps declaration is completed accurately.
- [ ] AI-generated content declaration/requirements are satisfied.
- [ ] Content rating questionnaire is completed.
- [ ] Target audience settings are completed.
- [ ] Ads declaration is completed. Answer no ads unless an ad SDK or ad display is included in the Android release build.
- [ ] In-app products and subscriptions are configured according to `docs/android-formal-release-qa-gates.md`, `docs/android-billing-release-plan.md`, and Google Play Billing requirements.
- [ ] Screenshots reflect actual Android app UI, not website screens.
- [ ] Feature graphic is prepared.
- [ ] Closed testing requirements are met before production access request if account type requires it.

## Signing / AAB Build Procedure

### Signing Model

Use Play App Signing with a local upload key.

- App signing key: managed by Google Play after Play App Signing is enabled.
- Upload key: owned by FI-YOU and used to sign AAB uploads.
- Upload keystore: stored outside Git and backed up in a secure password manager or secret vault.
- `key.properties`: local-only Gradle config file, never committed.

### Secret Management

- [ ] Add `android/key.properties` to `.gitignore`.
- [ ] Add `*.jks`, `*.keystore`, and `*.pem` to `.gitignore`.
- [ ] Store keystore file in a secure non-repository location.
- [ ] Store keystore password, key password, alias, and file path in password manager/CI secrets.
- [ ] Restrict CI secret access to release maintainers.
- [ ] Document recovery process for lost upload key.

### Upload Keystore Creation

Run from a secure developer machine, not from CI logs:

```powershell
keytool -genkeypair -v `
  -keystore fi-you-upload.jks `
  -storetype JKS `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias fi-you-upload
```

### `android/key.properties`

Local file only:

```properties
storePassword=REPLACE_WITH_STORE_PASSWORD
keyPassword=REPLACE_WITH_KEY_PASSWORD
keyAlias=fi-you-upload
storeFile=C:\\secure\\path\\fi-you-upload.jks
```

### Gradle Signing Config

In Flutter Android Gradle config, load `key.properties` and sign release builds with the release signing config. Exact syntax depends on the generated Gradle version and whether the project uses Groovy or Kotlin DSL.

Groovy-style reference:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### AAB Build Commands

From the Flutter project root:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
```

Expected output:

```text
build/app/outputs/bundle/release/app-release.aab
```

If the app uses environment flags:

```powershell
flutter build appbundle --release `
  --dart-define=APP_ENV=production `
  --dart-define=API_BASE_URL=https://api.example.com
```

### AAB Verification

- [ ] Confirm artifact path: `build/app/outputs/bundle/release/app-release.aab`.
- [ ] Confirm `versionCode` is higher than any previously uploaded build.
- [ ] Upload to Play Console internal testing first.
- [ ] Install from Play internal testing on a real Android device.
- [ ] Verify release app launches, signs in, saves data, and calls production backend.
- [ ] Verify no debug banner or dev endpoint.
- [ ] Verify Play Console pre-launch report.
- [ ] Verify crash-free launch on at least one low-end and one modern Android device.

Optional local inspection:

```powershell
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
```

## Play Console Submission Materials

### Main Store Listing

- [ ] App name: `FI-YOU`.
- [ ] Short description.
- [ ] Full description.
- [ ] App icon: 512 x 512 PNG.
- [ ] Feature graphic: 1024 x 500 PNG/JPG.
- [ ] Phone screenshots: minimum required Play Console set, based on actual Android release UI.
- [ ] Tablet screenshots only if tablet support is claimed.
- [ ] Category: recommend `Lifestyle` or `Health & Fitness` only if health declaration risk is intentionally accepted. Prefer `Lifestyle` for self-discovery positioning.
- [ ] Tags: reflection, journaling, self-discovery style tags only if available and accurate.
- [ ] Contact email.
- [ ] Privacy policy URL: `https://fi-you.vercel.app/privacy`.

### Draft Store Copy

Short description:

> AI-assisted self-discovery through reflective questions, diary, U-Map, and Signature insights.

Full description:

> FI-YOU helps you explore your thoughts and personal patterns through reflective questions, Diary entries, U-Map, and Signature insights.
>
> The app turns your own answers into AI-assisted summaries that can help you notice recurring themes and continue with the next question when you are ready.
>
> Key features:
> - Reflective self-discovery questions
> - Personal Diary entries
> - U-Map pattern view
> - Signature insight summaries
> - Recommended next questions
>
> FI-YOU is for personal reflection and self-discovery. It does not provide medical diagnosis, treatment, therapy, counseling, or emergency support. AI-generated insights may be incomplete or inaccurate and should be used as reflection prompts, not professional advice.

### App Content Forms

- [ ] App access: provide reviewer login/test account if required.
- [ ] Ads: declare accurately. First release target: no ads.
- [ ] Content rating.
- [ ] Target audience.
- [ ] Data safety.
- [ ] Health apps declaration.
- [ ] Financial features: no, unless future monetization changes this.
- [ ] News/political/government declarations: no, unless future content changes this.

## Data Safety Draft

Final answers must match the actual app, backend, and SDKs. Backend owner must confirm every item below before Play submission.

### Data Types To Confirm With Backend

| Data type | Likely status | Purpose | Shared? | Delete? | Backend owner check |
| --- | --- | --- | --- | --- | --- |
| Name / display name | Collected if profile exists | Account/profile | No unless processor needs it | Yes | Required |
| Email address | Collected if email login exists | Account/auth/support | No unless auth provider/processors | Yes | Required |
| User IDs | Collected | Auth, data ownership | No unless processors | Yes | Required |
| Diary text | Collected | Core app feature | No unless AI processor receives it | Yes | Required |
| Question answers | Collected | Core app feature and AI summaries | No unless AI processor receives it | Yes | Required |
| AI-generated insights | Collected/stored if saved | U-Map/Signature history | No unless processors | Yes | Required |
| App interactions | Optional | Analytics/product QA | No unless analytics provider | Delete or anonymize | Required |
| Crash logs | Optional | Crash monitoring | Shared with crash provider if used | Retention per provider | Required |
| Device identifiers | Optional through SDKs | Analytics/crash/security | Shared with SDK provider if used | Depends | Required |
| Advertising ID | Should be not collected in first release | Ads/attribution | N/A | N/A | Required |
| Location | Should be not collected | N/A | N/A | N/A | Required |
| Contacts/photos/files | Should be not collected unless a shipped feature needs it | N/A | N/A | N/A | Required |
| Health data | Should be not collected | N/A | N/A | N/A | Required |

### Security Answers To Prepare

- [ ] Is all collected user data encrypted in transit? Target answer: yes, via HTTPS/TLS.
- [ ] Can users request data deletion? Target answer: yes if accounts or personal data exist.
- [ ] Is data encrypted at rest? Confirm with backend/Supabase/project configuration.
- [ ] Is data shared with third parties? Include AI provider, auth provider, analytics, crash reporting, push notifications, and hosting providers if applicable.
- [ ] Is data processed ephemerally by AI provider or retained? Confirm provider settings and privacy terms.
- [ ] Are SDKs collecting data independently? Confirm Firebase/Supabase/analytics/crash/push SDK behavior.

### Privacy Policy Must Disclose

- Data collected.
- Why it is collected.
- AI processing use.
- Third-party processors.
- Retention period.
- Deletion request path.
- Contact email.
- Non-medical/AI limitations.
- Security practices.

## Account Deletion Requirements

If the Android app allows users to create an account, prepare both:

- In-app deletion path: Settings -> Account -> Delete account.
- Web deletion request link: public URL entered in Play Console Data safety/account deletion field.

Deletion flow requirements:

- [ ] User can initiate deletion without support-only friction.
- [ ] App explains what is deleted: account, answers, Diary, U-Map, Signature, reports, identifiers.
- [ ] App explains retention exceptions: legal/security backups if any.
- [ ] User can request deletion of associated personal data.
- [ ] Backend deletion job is idempotent.
- [ ] Deletion confirmation is sent or shown.
- [ ] Re-authentication is used if needed for security.
- [ ] Data deletion URL works without login and includes support contact.

Suggested in-app copy:

> Delete account and personal data
>
> This will request deletion of your FI-YOU account and personal data, including your answers, Diary entries, U-Map, and Signature history. Some records may be retained only where required for security, legal, or abuse-prevention reasons.

Suggested web deletion copy:

> Use this form to request deletion of your FI-YOU account and associated personal data. We may contact you to verify ownership before processing the request.

## AI / Self-Discovery Policy Response

### Risk Controls

- [ ] Do not call FI-YOU a medical, mental health, therapy, counseling, diagnostic, or treatment app.
- [ ] Do not claim exact personality accuracy or relationship prediction.
- [ ] Do not use "diagnose", "treat", "therapy", "counseling", "clinical", "disorder", "symptom", "patient", or "assessment" in store copy unless legally reviewed.
- [ ] Use "reflection", "self-discovery", "patterns", "tendencies", "journal", "AI-assisted summaries".
- [ ] Add AI limitations near AI insight screens.
- [ ] Add report/flag action for AI-generated content without requiring the user to leave the app.
- [ ] Add safety fallback for self-harm, crisis, abuse, or urgent distress content.
- [ ] Complete Health apps declaration carefully. If no health feature is offered, certify accordingly and keep store copy aligned.

### Reviewer Response: AI-Generated Content

> FI-YOU uses AI to generate self-reflection summaries based on user-provided answers and Diary entries. The app includes in-app reporting for concerning or inaccurate AI-generated content, and users are informed that AI insights may be incomplete or inaccurate.

### Reviewer Response: Non-Medical Positioning

> FI-YOU is a self-discovery and journaling app. It does not provide medical diagnosis, treatment, therapy, counseling, emergency support, or mental health assessment. The app uses reflective questions and AI-assisted summaries to help users notice patterns in their own responses.

### In-App AI Limitation Copy

> This insight is an AI-assisted reflection based on your current entries. It may be incomplete or inaccurate, and it is not diagnosis, therapy, counseling, medical advice, or emergency support.

### Report AI Content Copy

> Report this insight
>
> Tell us if this AI-generated insight feels harmful, inaccurate, offensive, or unsafe.

## Internal Testing Plan

Goal: validate signed release build and Play review blockers before broader testing.

- Track: Play Console Internal testing.
- Build: signed AAB release.
- Audience: internal team, founders, QA, backend owner.
- Duration: 2-3 days or until P0 issues are cleared.

Internal test checklist:

- [ ] Install through Play internal testing.
- [ ] Complete onboarding.
- [ ] Create account/sign in if applicable.
- [ ] Answer first question.
- [ ] Create Diary entry.
- [ ] View U-Map.
- [ ] View Signature.
- [ ] Answer recommended next question.
- [ ] Trigger AI feedback/report action.
- [ ] Open privacy, terms, AI limitations, deletion path.
- [ ] Relaunch app and verify persistence.
- [ ] Test slow/offline network.
- [ ] Confirm no monetization entry point blocks release flow.
- [ ] Confirm crash/log monitoring captures release build issues.

Exit criteria:

- [ ] Zero P0 crashes in core loop.
- [ ] No policy-risk wording in shipped UI.
- [ ] All Play Console links work.
- [ ] Data safety draft matches actual SDK/backend behavior.
- [ ] Pre-launch report has no launch-blocking issue.

## Closed Testing Plan

Goal: satisfy Play production readiness and validate real-user release quality.

- Track: Play Console Closed testing.
- Audience: controlled external testers.
- If the developer account is a new personal account, plan for at least 12 testers opted in continuously for at least 14 days before applying for production access.
- Keep 15-20 invited testers to protect against drop-off below 12 active opted-in testers.
- Use tester instructions that cover the full app, not just install/open.

Tester script:

- Day 1:
  - Install from Play closed testing.
  - Complete onboarding.
  - Create account/sign in if required.
  - Answer at least one question.
  - Create one Diary entry.
  - Open U-Map.
  - Open Signature.
  - Answer next recommended question.
- Day 2-14:
  - Return at least twice.
  - Add at least one more Diary entry.
  - Check whether U-Map/Signature changed or show a clear state.
  - Submit feedback on confusing AI wording or broken flows.

Closed test evidence to collect:

- Tester count and opt-in dates.
- Crash-free sessions.
- Core loop completion notes.
- Screenshots/video of key flows.
- Feedback summary.
- Fix list and release notes.

Closed test exit criteria:

- [ ] Required tester count/duration met if applicable.
- [ ] No unresolved P0/P1 crashes.
- [ ] Data safety, privacy, account deletion, and app access forms are final.
- [ ] Store listing screenshots match latest build.
- [ ] Production access application answers are prepared.

## Production Submission Order

1. Freeze release scope: Android monetization uses Google Play Billing; no official website dependency.
2. Finalize package name, app name, version, minSdk, targetSdk.
3. Configure signing and build signed AAB.
4. Upload AAB to internal testing.
5. Complete internal smoke QA and pre-launch report review.
6. Complete Play Console store listing and app content forms.
7. Open closed testing.
8. Meet closed testing requirement if account requires it.
9. Apply for production access if needed.
10. Submit production release.
11. Monitor review status and respond to policy feedback.
12. Roll out gradually if available and appropriate.

## Rejection Response Scenarios

### Rejection: Inaccurate Data safety

Action:

- Audit SDKs, backend, AI provider, analytics, crash reporting, and auth data.
- Update Data safety form and privacy policy to match actual behavior.
- Provide concise appeal/resubmission note with changed fields.

Response:

> We reviewed the app, backend, and SDK data flows and updated the Data safety form and privacy policy so they consistently reflect the data collected, processing purposes, sharing, security, and deletion options.

### Rejection: Account deletion missing

Action:

- Add in-app deletion path.
- Publish public deletion request URL.
- Update Play Console Data deletion field.
- Retest path in release build.

Response:

> We added an in-app account deletion path and a public web deletion request link. Users can request deletion of their account and associated personal data from both locations.

### Rejection: AI-generated content reporting missing

Action:

- Add report/flag action to AI insight screens.
- Route reports to backend/support queue.
- Explain moderation/review process.

Response:

> FI-YOU now includes an in-app reporting option for AI-generated insights. Users can flag harmful, inaccurate, offensive, or unsafe AI output without leaving the app.

### Rejection: Health/medical claim risk

Action:

- Remove any wording implying diagnosis, counseling, therapy, treatment, mental health assessment, or accuracy.
- Update store listing, screenshots, onboarding, and AI disclaimer.
- Recheck Health apps declaration.

Response:

> We revised the app and store listing to clarify that FI-YOU is a self-discovery and journaling app only. It does not provide medical diagnosis, treatment, therapy, counseling, emergency support, or mental health assessment.

### Rejection: Closed testing requirement not met

Action:

- Confirm developer account type.
- Ensure at least 12 testers are opted in for 14 continuous days if required.
- Wait until Play Console dashboard shows eligibility.

Response:

> We completed the required closed test with the required number of opted-in testers for the required duration and are resubmitting after Play Console confirmed production access eligibility.

## Post-Launch Monitoring Plan

### First 24 Hours

- [ ] Monitor Play Console vitals: crash rate, ANR rate, affected devices.
- [ ] Monitor crash reporting dashboard.
- [ ] Monitor auth failures and backend 4xx/5xx.
- [ ] Monitor AI generation failures/timeouts.
- [ ] Monitor support inbox.
- [ ] Check reviews and ratings if visible.

### First 7 Days

- [ ] Daily crash/ANR review.
- [ ] Daily backend error review.
- [ ] Track onboarding completion.
- [ ] Track first question completion.
- [ ] Track Diary creation.
- [ ] Track U-Map viewed.
- [ ] Track Signature viewed.
- [ ] Track next question answered.
- [ ] Track AI report/flag events.
- [ ] Track account deletion requests and completion SLA.

### Alert Thresholds

- Crash-free users below 99%: investigate.
- Any startup crash cluster: hotfix candidate.
- ANR spike above Play Console warning threshold: investigate.
- Auth failure spike: backend/auth incident.
- AI timeout/error spike: provider/backend incident.
- Any self-harm safety fallback failure: immediate P0 review.
- Any deletion request not processed within policy/SLA: privacy incident review.

### Hotfix Criteria

- Startup crash.
- Login/account creation blocking issue.
- Data loss in Diary/answers.
- Broken account deletion path.
- Broken privacy/terms links.
- AI output safety issue.
- Play policy violation in shipped copy.

## Monetization / Star Release Gate

Android monetization is included in the official release scope and is governed by `docs/android-formal-release-qa-gates.md`, `docs/android-billing-release-plan.md`, and Google Play Billing policy.

- Android in-app digital goods: Google Play Billing only.
- Web checkout: Paddle only, outside Android in-app purchase surfaces.
- Future iOS in-app digital goods: Apple StoreKit / In-App Purchase.
- Questions themselves are not sold.
- Payment CTAs must not appear before the core discovery loop is understandable.
- Paid copy must avoid "more accurate analysis" and similar certainty claims.

## Blocking Risks

| Risk | Severity | Owner | Mitigation |
| --- | --- | --- | --- |
| Flutter CLI not available on PATH in this environment | P0 | Android | Run build/analyze/test on a configured Flutter + Android Studio machine |
| Upload keystore / `key.properties` missing | P0 | Release | Generate upload key and store signing secrets outside Git before signed AAB build |
| Package name not finalized before first Play upload | Resolved | Product | `com.fiyou.app` is the fixed package name |
| Privacy policy / deletion URL not live | P0 | Legal/Backend | Publish minimal compliant pages or public forms before Play submission |
| Data safety mismatch with backend/SDKs | P0 | Backend/Release | Complete data inventory before form submission |
| Account deletion missing for account-based app | P0 | Backend/Android | Implement in-app path and public deletion request URL |
| AI report/flag action missing | P0 | Android/Backend | Add report action to AI insight screens and backend/support handling |
| Health app declaration mismatch | P0 | Release/Product | Keep positioning as lifestyle/self-discovery and avoid health claims |
| Personal developer account closed testing requirement | P0 | Release | Recruit 15-20 testers and maintain at least 12 opted-in for 14 continuous days |
| targetSdk below Play requirement | P0 | Android | Target API 35 or higher |
| Billing entitlement bugs | P0 | Backend/Android | Verify purchases server-side before granting Star, reports, or subscription benefits |

## Official References Checked

- Flutter Android release docs: https://docs.flutter.dev/deployment/android
- Android app signing: https://developer.android.com/studio/publish/app-signing
- Google Play target API level requirements: https://developer.android.com/google/play/requirements/target-sdk
- Play Console testing tracks: https://support.google.com/googleplay/android-developer/answer/9845334
- New personal account app testing requirements: https://support.google.com/googleplay/android-developer/answer/14151465
- Google Play Data safety form: https://support.google.com/googleplay/android-developer/answer/10787469
- Google Play User Data policy: https://support.google.com/googleplay/android-developer/answer/10144311
- Google Play AI-generated content policy: https://support.google.com/googleplay/android-developer/answer/14094294
- Google Play Health apps declaration: https://support.google.com/googleplay/android-developer/answer/14738291
