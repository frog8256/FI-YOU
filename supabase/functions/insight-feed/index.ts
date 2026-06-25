import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { refreshUserInsights, toFeedItem } from "../_shared/insight-engine.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
};

const json = (status: number, body: Record<string, unknown>) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

function feedSectionForType(type: string) {
  switch (type) {
    case "emerging_pattern":
      return "반복해서 나타나는 흐름";
    case "internal_tension":
      return "함께 보이는 연결";
    case "exploration_gap":
      return "아직 조용한 영역";
    case "consistent_theme":
      return "조금씩 선명해지는 방향";
    case "change_over_time":
      return "변화의 흔적";
    default:
      return "최근 탐험";
  }
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (request.method !== "GET" && request.method !== "POST") {
    return json(405, { error: "method_not_allowed" });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !serviceRoleKey) throw new Error("missing_supabase_env");

    const authHeader = request.headers.get("Authorization") ?? "";
    const jwt = authHeader.replace(/^Bearer\s+/i, "");
    if (!jwt) return json(401, { error: "missing_authorization" });

    const admin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { data: userData, error: userError } = await admin.auth.getUser(jwt);
    if (userError || !userData.user) return json(401, { error: "invalid_user_session" });

    const url = new URL(request.url);
    const body = request.method === "POST" ? await request.json().catch(() => ({})) : {};
    const forceRefresh = url.searchParams.get("refresh") === "true" ||
      (body && typeof body === "object" && (body as Record<string, unknown>).refresh === true);
    const refresh = await refreshUserInsights(admin, userData.user.id, { force: forceRefresh });

    const { data: rows, error: insightError } = await admin
      .from("user_insights")
      .select("id,insight_type,title,description,supporting_nodes,confidence_level,updated_at")
      .eq("user_id", userData.user.id)
      .eq("active", true)
      .order("updated_at", { ascending: false })
      .limit(20);
    if (insightError) throw insightError;

    const insights = (rows ?? []).map((row) => ({
      ...toFeedItem(row),
      feed_section: feedSectionForType(String(row.insight_type)),
    }));

    return json(200, {
      ok: true,
      feed_title: "최근 탐험",
      sections: [
        "최근 탐험",
        "반복해서 나타나는 흐름",
        "함께 보이는 연결",
        "조금씩 선명해지는 방향",
      ],
      insights,
      refresh,
    });
  } catch (error) {
    return json(500, {
      error: "insight_feed_failed",
      message: error instanceof Error ? error.message : String(error),
    });
  }
});
