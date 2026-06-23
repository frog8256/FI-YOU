import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { refreshUserInsights } from "../_shared/insight-engine.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (status: number, body: Record<string, unknown>) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

type AnswerRequest = {
  card_id?: string;
  selected_options?: string[];
  user_note?: string;
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (request.method !== "POST") return json(405, { error: "method_not_allowed" });

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !serviceRoleKey) throw new Error("missing_supabase_env");

    const authHeader = request.headers.get("Authorization") ?? "";
    const jwt = authHeader.replace(/^Bearer\s+/i, "");
    if (!jwt) return json(401, { error: "missing_authorization" });

    const body = await request.json().catch(() => ({})) as AnswerRequest;
    if (!body.card_id) return json(400, { error: "missing_card_id" });
    if (!Array.isArray(body.selected_options) || body.selected_options.length === 0) {
      return json(400, { error: "missing_selected_options" });
    }

    const userScopedAdmin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
      global: { headers: { Authorization: authHeader } },
    });
    const serviceAdmin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { data: userData, error: userError } = await serviceAdmin.auth.getUser(jwt);
    if (userError || !userData.user) return json(401, { error: "invalid_user_session" });

    const { error: answerError } = await userScopedAdmin.rpc("record_exploration_card_answer", {
      p_card_history_id: body.card_id,
      p_selected_options: body.selected_options,
      p_user_note: body.user_note ?? "",
    });
    if (answerError) throw answerError;

    const refresh = await refreshUserInsights(serviceAdmin, userData.user.id).catch((error) => ({
      refreshed: false,
      reason: "refresh_failed",
      message: error instanceof Error ? error.message : String(error),
    }));

    return json(200, { success: true, insights: refresh });
  } catch (error) {
    return json(500, {
      error: "answer_exploration_card_failed",
      message: error instanceof Error ? error.message : String(error),
    });
  }
});
