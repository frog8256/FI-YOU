export const kpiEvents = {
  googleLoginStarted: "auth_google_login_started",
  googleLoginCompleted: "auth_google_login_completed",
  onboardingCompleted: "onboarding_required_completed",
  questionAnswered: "question_answered",
  diaryCreated: "diary_created",
  diaryUpdated: "diary_updated",
  diaryDeleted: "diary_deleted",
  starEarned: "star_earned",
  starSpent: "star_spent",
  starShortageShown: "star_shortage_shown",
  uMapViewed: "u_map_viewed",
  reportViewed: "report_viewed",
  relationStarted: "relation_started",
  growthViewed: "growth_viewed",
  dataExportRequested: "data_export_requested",
  recordsResetRequested: "records_reset_requested",
  accountDeletionRequested: "account_deletion_requested",
  languageSelected: "language_selected"
};

export function trackEvent(name, properties = {}) {
  window.dispatchEvent(new CustomEvent("fiyou:kpi", { detail: { name, properties, at: new Date().toISOString() } }));
}
