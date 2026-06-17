# FI-YOU Android Release & Growth Plan

> Status note, 2026-06-17: This document is superseded for formal Android release approval by `docs/android-formal-release-qa-gates.md`.
> Use this file only as historical/growth context. Its previous "payment excluded from MVP" premise is obsolete.
> Current confirmed Android release scope includes Google Play Billing, Star, paid reports, and relationship features.

Last updated: 2026-06-17

Status: Superseded for production release planning. Use `docs/android-production-release-readiness.md` for the current Android official launch checklist. This file remains as historical MVP/Growth context only.

## Release Position

FI-YOU Android 1st release is a Flutter Android official release candidate, not an MVP-only release. Until Product QA approves the core loop, Release & Store QA has priority over monetization placement, but the current release scope includes Google Play Billing, Star, paid reports, and relationship features.

Primary release goal:

- Complete the core loop: onboarding -> question answer -> diary entry -> U-Map view -> Signature view -> next question recommendation.
- Keep the basic self-discovery loop free.
- Keep the core self-discovery loop ahead of monetization. Star, paid reports, and subscriptions may ship only through Google Play Billing and must not block questions, Diary, U-Map, or Signature basics.

## P0 Android Release Checklist

### Product Loop Readiness

- [ ] Onboarding explains FI-YOU as self-discovery, not diagnosis, therapy, counseling, or medical advice.
- [ ] User can start the first question without payment, Star spend, or account friction beyond the chosen release auth rule.
- [ ] User can answer at least one question.
- [ ] User can create a Diary entry after answering or from the main loop.
- [ ] User can view U-Map after sufficient input or see an empty-state that explains more answers improve the map.
- [ ] User can view Signature after sufficient input or see an empty-state that invites the next question.
- [ ] User receives a next question recommendation.
- [ ] User can return to the main loop without dead ends.
- [ ] All AI output uses non-diagnostic language.
- [ ] App has crisis/safety fallback copy if user expresses self-harm, abuse, or urgent distress.

### Android Build & Package

- [x] Confirm package name: `com.fiyou.app`.
- [x] Confirm Play Store app name: `FI-YOU`.
- [ ] Confirm short device label if needed: `FI-YOU`.
- [ ] Prepare production app icon in all Android densities.
- [ ] Prepare adaptive icon foreground/background.
- [ ] Prepare splash screen asset and color.
- [ ] Confirm minimum SDK and target SDK for current Play requirements before upload.
- [ ] Confirm app versioning policy: `versionName` and monotonically increasing `versionCode`.
- [ ] Configure release signing key.
- [ ] Store signing credentials outside the repository.
- [ ] Enable Play App Signing in Play Console.
- [ ] Build release AAB.
- [ ] Test install release build on a real Android device.
- [ ] Verify no debug banner, dev API endpoint, verbose logging, or test keys remain.

### Play Console Materials

- [ ] App name.
- [ ] Short description.
- [ ] Full description.
- [ ] App category.
- [ ] Contact email.
- [ ] Privacy policy URL.
- [ ] Data deletion URL if account creation is supported.
- [ ] App icon.
- [ ] Feature graphic.
- [ ] Phone screenshots.
- [ ] 7-inch / tablet screenshots if tablet support is claimed.
- [ ] Content rating questionnaire.
- [ ] Data safety form.
- [ ] Target audience and content settings.
- [ ] Ads declaration. For first release, recommended: no ads.
- [ ] App access instructions for reviewer if login is required.
- [ ] Closed testing track configured.
- [ ] Internal testing track configured for smoke QA.
- [ ] Production country availability selected.

### Legal & Policy Pages

- [ ] Privacy Policy.
- [ ] Terms of Service.
- [ ] AI Limitations Notice.
- [ ] Non-medical / non-counseling disclaimer.
- [ ] Data deletion guide.
- [ ] Account deletion guide if accounts exist.
- [ ] Refund/support policy for Google Play Billing purchases, Star grants, paid report unlocks, subscription cancellation, and entitlement revocation.
- [ ] Contact/support policy.
- [ ] Retention period for diary, answers, U-Map, Signature, and account data.
- [ ] Explanation of AI-generated content and user control/reporting.

### Store Review Risk Controls

- [ ] Do not use "diagnosis", "treatment", "therapy", "counseling", "clinical", "accurate personality diagnosis", or "mental health assessment" in store copy.
- [ ] Do not claim FI-YOU can determine the user's true personality, future, compatibility, disorder, or relationship outcome.
- [ ] Use "reflection", "self-discovery", "patterns", "tendencies", "journaling", and "AI-assisted insight".
- [ ] Add visible in-app disclaimer before or near AI interpretation surfaces.
- [ ] Provide a way to report or give feedback on AI-generated content.
- [ ] If user-generated AI content can be shared or generated freely, include moderation/reporting handling before wider launch.
- [ ] Android paid digital unlocks use Google Play Billing only. Paddle must remain web-only.

## Internal / Closed Testing Flow

### Internal Testing

Goal: verify build health and review-blocking issues before closed testing.

- Audience: founders, product, QA, trusted internal testers.
- Build: signed release AAB uploaded to internal track.
- Duration: 2-3 days or until P0 smoke tests are clean.
- Exit criteria:
  - No crash in onboarding -> next question loop.
  - No policy-risk copy found in app or store listing.
  - Data deletion / privacy links work.
  - Release build installs and starts cleanly.

### Closed Testing

Goal: validate first-session activation, diary repeat, and paid-feature behavior without monetization pressure.

- Audience: limited external testers who understand this is the first Android release candidate.
- Duration: at least one complete usage week is recommended before production submission.
- Tester tasks:
  - Complete onboarding.
  - Answer first question.
  - Write first Diary.
  - View U-Map.
  - View Signature.
  - Answer recommended next question.
  - Return the next day and write another Diary.
- Exit criteria:
  - Activation rate is acceptable.
  - No major confusion around AI limitations.
  - No user reports that the app feels medical, diagnostic, or payment-gated.
  - Store metadata and Data safety answers match the actual app behavior.

## Release Smoke Test

Run this on a clean install of the release build.

| Area | Test | Pass Criteria |
| --- | --- | --- |
| Install | Install from release AAB / internal track | App installs without warning beyond normal Play test notice |
| Launch | First launch | Splash appears, app reaches onboarding |
| Onboarding | Complete onboarding | User reaches first question |
| Question | Submit answer | Answer saves and next state appears |
| Diary | Create diary entry | Entry saves and can be reopened |
| U-Map | Open U-Map | Shows generated state or clear insufficient-data state |
| Signature | Open Signature | Shows generated state or clear insufficient-data state |
| Recommendation | Open next question | Recommended question is accessible |
| Persistence | Relaunch app | Previous progress remains |
| Network | Slow/offline state | App shows useful error or retry state |
| Privacy | Open privacy links | Privacy, terms, deletion links work |
| Copy | Review app text | No diagnosis/treatment/counseling/accuracy claims |
| Monetization | Scan main flow | No paid lock blocks the core self-discovery loop |

## Store Listing Draft

### App Name

FI-YOU

### Short Description

AI-assisted self-discovery through questions, diary, U-Map, and Signature insights.

### Full Description

FI-YOU helps you explore your thoughts, patterns, and personal tendencies through a calm self-discovery loop.

Start with reflective questions, write short Diary entries, and review AI-assisted insights such as U-Map and Signature. FI-YOU is designed to help you notice recurring themes in your own words and continue with the next question when you are ready.

What you can do:

- Answer self-discovery questions.
- Keep a personal Diary.
- Review U-Map patterns based on your responses.
- Check Signature insights that summarize current tendencies.
- Continue with recommended next questions.

Important notice:

FI-YOU is for personal reflection and self-discovery. It does not provide medical diagnosis, treatment, therapy, counseling, or emergency support. AI-generated insights may be incomplete or inaccurate and should be used as prompts for reflection, not as professional advice.

### What's New / First Release Note

FI-YOU Android launches with onboarding, reflective questions, Diary, U-Map, Signature, and next question recommendations.

## Review Risk & Response Copy

### Risk: App appears to provide diagnosis or therapy

Policy-safe response:

> FI-YOU is a self-discovery and journaling app. It does not diagnose, treat, counsel, or provide medical or mental health advice. The app uses reflective questions and AI-assisted summaries to help users notice patterns in their own responses.

In-app copy:

> This insight is a reflection aid based on your current answers. It is not a diagnosis, therapy, counseling, or medical advice.

### Risk: AI-generated content lacks user feedback/reporting

Policy-safe response:

> FI-YOU provides AI-assisted self-reflection summaries and includes a user feedback path for concerning, inaccurate, or unwanted AI output.

In-app copy:

> AI insights can miss context. If something feels wrong or unsafe, you can report it or ignore it.

### Risk: Paid digital goods use Paddle instead of Google Play Billing

Policy-safe response for the official Android release:

> FI-YOU Android uses Google Play Billing for in-app digital purchases such as Stars, paid reports, and subscriptions. Paddle is used only for web checkout outside the Android app.

Release rule:

- Stars, paid reports, subscriptions, or any digital entitlement consumed inside Android must use Google Play Billing.
- Paddle is web checkout only and must not be linked, opened, or promoted inside the Android app for digital goods.

### Risk: User data deletion requirement

Policy-safe response:

> FI-YOU provides a privacy policy and a data deletion path. If account creation is enabled, users can request account deletion from inside the app and through a web URL.

In-app copy:

> You can request deletion of your account and personal data from Settings or through our data deletion page.

## Obsolete Payment-Excluded MVP Notes

This section is intentionally retired. Do not use it for Android formal release decisions.

Current Product QA position:

- Android formal release scope includes Star, paid reports, relationship features, and payment.
- Android in-app digital goods must use Google Play Billing.
- Paddle is web checkout only and must not be exposed as Android in-app checkout for digital goods.
- Future iOS in-app digital goods must use Apple StoreKit / In-App Purchase.
- Questions themselves are not sold.
- Payment must not block the user from understanding the core discovery loop.
- Paid copy must not imply "more accurate analysis"; use deeper or expanded record-based report language.

## P1 Growth After Core Loop QA

### Retention Loops

- Diary reminder: one gentle reminder at the user's chosen time.
- Next question reminder: send only if the user completed at least one question and has not continued.
- U-Map update reminder: trigger after meaningful new input, not daily spam.
- Signature refresh reminder: trigger after a set number of new answers or Diary entries.

Notification principles:

- Default to low frequency.
- Let users disable reminders easily.
- Avoid anxious wording.
- Do not imply the app knows the user's mental state.

Suggested reminder copy:

- "Want to leave a short note for today?"
- "Your next reflection question is ready."
- "You have new entries. U-Map may have more to show."

### MVP KPI Definitions

| KPI | Definition | First Release Use |
| --- | --- | --- |
| Activation | User completes onboarding and answers the first question | Primary first-session success metric |
| Diary Repeat | User writes Diary entries on 2 different days within 7 days | Early retention quality |
| U-Map Viewed | User opens U-Map after answering at least one question | Insight curiosity |
| Signature Viewed | User opens Signature after answering at least one question | Value discovery |
| Next Question Answered | User answers a recommended next question | Core loop continuation |
| D1 Return | User returns the day after activation | Retention baseline |
| D7 Return | User returns within 7 days after activation | MVP retention signal |

## Post-Release Growth / Monetization Backlog

### Star Economy Experiments

- Earned Star only:
  - Attendance: +10 Star.
  - Diary entry: +12 Star.
  - Rewarded ad: +15 Star, only after ad policy and UX QA.
- Spend candidates:
  - Free exploration session: 30 Star.
  - Romance tendency analysis: 50 Star.
  - Relation-Map: 80 Star per person.
  - Compare with past self: 30 Star candidate.

Experiment guardrails:

- Questions themselves are never sold.
- Basic loop remains free.
- Star shortage screens suggest free earning actions before purchase.
- Paid unlocks are framed as deeper exploration, not required progress.

### Payment Backlog

- Decide Android paid unlock implementation using Google Play Billing if digital goods are sold or consumed in-app.
- Evaluate Paddle for web checkout only after reviewing platform-specific rules.
- Separate Android, iOS, and web purchase policies.
- Prepare refund policy and entitlement restoration before enabling paid unlocks.
- Add purchase audit trail and support tooling.

### Paid Feature Backlog

- Deeper U-Map analysis.
- Expanded Signature history.
- Past-self comparison.
- Relation-Map.
- Exportable personal report.
- Optional subscription bundle after retention is proven.

## Policy Sources Checked

- Google Play Billing: https://developer.android.com/google/play/billing
- Google Play Payments policy help: https://support.google.com/googleplay/android-developer/answer/10281818
- Google Play AI-Generated Content policy help: https://support.google.com/googleplay/android-developer/answer/14094294
- Google Play User Data policy help: https://support.google.com/googleplay/android-developer/answer/10144311
- Apple App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Apple In-App Purchase HIG: https://developer.apple.com/design/human-interface-guidelines/in-app-purchase
