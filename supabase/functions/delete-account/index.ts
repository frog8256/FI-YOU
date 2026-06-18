import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "content-type": "application/json" },
  });
}

function getEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`missing_env:${name}`);
  return value;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  try {
    const authHeader = req.headers.get("authorization") ?? "";
    const jwt = authHeader.replace(/^Bearer\s+/i, "");
    if (!jwt) return json({ error: "missing_authorization" }, 401);

    const body = await req.json().catch(() => ({})) as { reason?: string; confirm?: string };
    if (body.confirm !== "DELETE") {
      return json({ error: "confirmation_required" }, 400);
    }

    const admin = createClient(getEnv("SUPABASE_URL"), getEnv("SUPABASE_SERVICE_ROLE_KEY"), {
      auth: { persistSession: false },
    });
    const { data: authData, error: authError } = await admin.auth.getUser(jwt);
    if (authError || !authData.user) return json({ error: "invalid_session" }, 401);

    const userId = authData.user.id;
    const request = await admin.from("account_deletion_requests").insert({
      user_id: userId,
      status: "processing",
      reason: typeof body.reason === "string" ? body.reason.slice(0, 500) : null,
      metadata: { source: "android_app" },
    }).select("id").single();

    if (request.error) {
      return json({ error: "deletion_request_failed" }, 500);
    }

    await admin.from("users")
      .update({ deletion_requested_at: new Date().toISOString() })
      .eq("id", userId);

    const deleteResult = await admin.auth.admin.deleteUser(userId);
    if (deleteResult.error) {
      await admin.from("account_deletion_requests")
        .update({ status: "failed", processed_at: new Date().toISOString() })
        .eq("id", request.data.id);
      return json({ error: "auth_user_delete_failed" }, 500);
    }

    // Keep the deletion request row as processing evidence after auth/user rows are removed.
    await admin.from("account_deletion_requests")
      .update({ status: "completed", processed_at: new Date().toISOString() })
      .eq("id", request.data.id);

    return json({
      deleted: true,
      userId,
      note: "Client must clear the local Supabase session immediately.",
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "unknown_error";
    return json({ error: message }, message.startsWith("missing_env:") ? 503 : 500);
  }
});
