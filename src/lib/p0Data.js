import { supabase } from "./supabaseClient";

const profileIdField = "user_id";

function throwIf(error) {
  if (error) throw error;
}

function normalizeQuestion(question, options) {
  const orderedOptions = options
    .filter((option) => option.question_id === question.id)
    .sort((a, b) => (a.sequence ?? a.sort_order ?? 0) - (b.sequence ?? b.sort_order ?? 0));

  return {
    id: question.id,
    question: question.prompt,
    helper: question.helper_text,
    note: Boolean(question.helper_text),
    options: orderedOptions.map((option) => option.label),
    optionRecords: orderedOptions
  };
}

export async function signInWithGoogle() {
  const redirectTo = `${window.location.origin}${window.location.pathname}?screen=home`;
  return supabase.auth.signInWithOAuth({
    provider: "google",
    options: { redirectTo }
  });
}

export async function getSession() {
  const { data, error } = await supabase.auth.getSession();
  throwIf(error);
  return data.session;
}

export function onAuthStateChange(callback) {
  return supabase.auth.onAuthStateChange((_event, session) => callback(session));
}

export async function signOut() {
  const { error } = await supabase.auth.signOut();
  throwIf(error);
}

export async function ensureProfile(user) {
  if (!user?.id) return null;
  const { data, error } = await supabase
    .from("profiles")
    .select("*")
    .eq(profileIdField, user.id)
    .maybeSingle();

  if (error) throw error;
  if (data) return data;

  const nickname = user.user_metadata?.name || user.email?.split("@")[0] || "지우";
  const { data: created, error: createError } = await supabase
    .from("profiles")
    .insert({ [profileIdField]: user.id, nickname })
    .select()
    .single();
  throwIf(createError);
  return created;
}

export async function updateProfile(userId, values) {
  const { data, error } = await supabase
    .from("profiles")
    .upsert({ [profileIdField]: userId, ...values, updated_at: new Date().toISOString() }, { onConflict: profileIdField })
    .select()
    .single();
  throwIf(error);
  return data;
}

export async function completeOnboarding(userId) {
  const { data, error } = await supabase
    .from("profiles")
    .update({
      onboarding_completed: true,
      required_questions_completed_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    })
    .eq(profileIdField, userId)
    .select()
    .single();
  throwIf(error);
  return data;
}

export async function fetchQuestions(questionSet) {
  const { data: questions, error } = await supabase
    .from("questions")
    .select("id, question_set, sequence, prompt, helper_text, axis_keys")
    .eq("question_set", questionSet)
    .eq("active", true)
    .order("sequence", { ascending: true });
  throwIf(error);

  if (!questions?.length) return [];

  const { data: options, error: optionError } = await supabase
    .from("question_options")
    .select("id, question_id, sequence, label")
    .in("question_id", questions.map((question) => question.id))
    .order("sequence", { ascending: true });
  throwIf(optionError);

  return questions.map((question) => normalizeQuestion(question, options || []));
}

export async function fetchAnsweredQuestionIds(tableName, userId) {
  const { data, error } = await supabase
    .from(tableName)
    .select("question_id")
    .eq("user_id", userId);
  throwIf(error);
  return new Set((data || []).map((row) => row.question_id));
}

export async function upsertOnboardingAnswer({ userId, questionId, selectedOptionId, optionalText }) {
  const { data, error } = await supabase
    .from("onboarding_answers")
    .upsert({
      user_id: userId,
      question_id: questionId,
      selected_option_id: selectedOptionId,
      optional_text: optionalText || null,
      answered_at: new Date().toISOString()
    }, { onConflict: "user_id,question_id" })
    .select()
    .single();
  throwIf(error);
  return data;
}

export async function upsertAnswer({ userId, questionId, selectedOptionId, optionalText }) {
  const { data, error } = await supabase
    .from("answers")
    .upsert({
      user_id: userId,
      question_id: questionId,
      selected_option_id: selectedOptionId,
      optional_text: optionalText || null,
      answered_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }, { onConflict: "user_id,question_id" })
    .select()
    .single();
  throwIf(error);
  return data;
}

export async function fetchDiaries(userId) {
  const { data, error } = await supabase
    .from("diaries")
    .select("*")
    .eq("user_id", userId)
    .is("deleted_at", null)
    .order("entry_date", { ascending: false });
  throwIf(error);
  return data || [];
}

export async function saveDiary({ userId, id, title, body, moodLabel }) {
  const payload = {
    user_id: userId,
    title: title || "오늘의 나",
    body,
    mood_label: moodLabel,
    updated_at: new Date().toISOString()
  };

  const query = id
    ? supabase.from("diaries").update(payload).eq("id", id)
    : supabase.from("diaries").insert(payload);

  const { data, error } = await query.select().single();
  throwIf(error);
  return data;
}

export async function softDeleteDiary(id) {
  const { error } = await supabase
    .from("diaries")
    .update({ deleted_at: new Date().toISOString(), updated_at: new Date().toISOString() })
    .eq("id", id);
  throwIf(error);
}

export async function revokeDiaryStarOnce(diaryId) {
  const { data, error } = await supabase.rpc("revoke_diary_star", { p_diary_id: diaryId });
  throwIf(error);
  return Number(data || 0);
}

export async function getStarBalance() {
  const { data, error } = await supabase.rpc("get_star_balance");
  throwIf(error);
  return Number(data || 0);
}

export async function grantAttendanceStar() {
  const today = new Date().toISOString().slice(0, 10);
  const { data, error } = await supabase.rpc("grant_daily_attendance_star", { p_local_date: today });
  throwIf(error);
  return Number(data || 0);
}

export async function grantDiaryStarOnce(diaryId) {
  const { data, error } = await supabase.rpc("grant_diary_star_once", { p_diary_id: diaryId });
  throwIf(error);
  return Number(data || 0);
}

export async function spendStar({ reason, amount, refType, refId }) {
  const { data, error } = await supabase.rpc("spend_star", {
    p_reason: reason,
    p_amount: amount,
    p_ref_type: refType,
    p_ref_id: refId || null
  });
  throwIf(error);
  return data;
}

export async function unlockEntitlement({ type, cost, refId }) {
  const { data, error } = await supabase.rpc("unlock_entitlement", {
    p_entitlement_type: type,
    p_cost: cost,
    p_ref_id: refId || null
  });
  throwIf(error);
  return data;
}

export async function fetchEntitlements() {
  const { data, error } = await supabase
    .from("entitlements")
    .select("*")
    .order("unlocked_at", { ascending: false });
  throwIf(error);
  return data || [];
}

export async function fetchLatestUMapSnapshot() {
  const { data, error } = await supabase
    .from("u_map_snapshots")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();
  throwIf(error);
  return data;
}

export async function createRelation({ userId, name, relationshipType }) {
  const { data, error } = await supabase
    .from("relations")
    .insert({
      user_id: userId,
      name: name || "이 관계",
      relationship_type: relationshipType,
      status: "draft"
    })
    .select()
    .single();
  throwIf(error);
  return data;
}

export async function upsertRelationAnswer({ relationId, questionId, selectedOptionId, optionalText }) {
  const { data, error } = await supabase.rpc("upsert_relation_answer", {
    p_relation_id: relationId,
    p_question_id: questionId,
    p_selected_option_id: selectedOptionId || null,
    p_optional_text: optionalText || null
  });
  throwIf(error);
  return data;
}

export function isInsufficientStarError(error) {
  const message = `${error?.message || ""} ${error?.details || ""}`.toLowerCase();
  return message.includes("insufficient") || message.includes("star");
}
