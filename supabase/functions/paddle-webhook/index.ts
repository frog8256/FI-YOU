import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, paddle-signature",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

type PaddlePayload = {
  event_id?: string;
  event_type?: string;
  data?: {
    id?: string;
    status?: string;
    custom_data?: Record<string, unknown>;
    items?: Array<{ price?: { id?: string; product_id?: string } }>;
  };
  custom_data?: Record<string, unknown>;
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

async function sha256Hex(input: string): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(input));
  return Array.from(new Uint8Array(digest)).map((byte) => byte.toString(16).padStart(2, "0")).join("");
}

async function hmacHex(secret: string, message: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(message));
  return Array.from(new Uint8Array(signature)).map((byte) => byte.toString(16).padStart(2, "0")).join("");
}

function constantTimeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let result = 0;
  for (let i = 0; i < a.length; i++) result |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return result === 0;
}

async function verifyPaddleSignature(rawBody: string, header: string | null): Promise<boolean> {
  if (!header) return false;
  const secret = getEnv("PADDLE_WEBHOOK_SECRET");
  const parts = Object.fromEntries(
    header.split(";").map((part) => {
      const [key, value] = part.split("=");
      return [key?.trim(), value?.trim()];
    }),
  );
  const ts = parts.ts;
  const h1 = parts.h1;
  if (!ts || !h1) return false;
  const toleranceSeconds = Number(Deno.env.get("PADDLE_SIGNATURE_TOLERANCE_SECONDS") ?? "5");
  const ageSeconds = Math.abs(Math.floor(Date.now() / 1000) - Number(ts));
  if (!Number.isFinite(ageSeconds) || ageSeconds > toleranceSeconds) return false;
  const expected = await hmacHex(secret, `${ts}:${rawBody}`);
  return constantTimeEqual(expected, h1);
}

function getCustom(payload: PaddlePayload): Record<string, unknown> {
  return payload.data?.custom_data ?? payload.custom_data ?? {};
}

function stringValue(value: unknown): string | null {
  return typeof value === "string" && value.trim() ? value.trim() : null;
}

function numberValue(value: unknown): number {
  return typeof value === "number" ? value : Number(value ?? 0);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  try {
    const rawBody = await req.text();
    const signatureOk = await verifyPaddleSignature(rawBody, req.headers.get("paddle-signature"));
    if (!signatureOk) return json({ error: "invalid_paddle_signature" }, 401);

    const payload = JSON.parse(rawBody) as PaddlePayload;
    const custom = getCustom(payload);
    const eventType = payload.event_type ?? "unknown";
    const transactionId = payload.data?.id ?? payload.event_id ?? await sha256Hex(rawBody);
    const eventId = payload.event_id ?? `${eventType}:${transactionId}`;
    const userId = stringValue(custom.user_id);
    const amountStars = Math.max(0, numberValue(custom.amount_stars));
    const entitlementType = stringValue(custom.entitlement_type);
    const resourceType = stringValue(custom.resource_type);
    const resourceId = stringValue(custom.resource_id);
    const productCode = stringValue(custom.product_code)
      ?? payload.data?.items?.[0]?.price?.id
      ?? payload.data?.items?.[0]?.price?.product_id
      ?? null;

    const isGrantEvent = ["transaction.completed", "subscription.created", "subscription.updated"].includes(eventType);
    const isRevokeEvent = [
      "transaction.refunded",
      "transaction.payment_failed",
      "subscription.canceled",
      "subscription.past_due",
      "adjustment.created",
    ].includes(eventType);

    const status = isGrantEvent ? "verified" : isRevokeEvent ? "refunded" : "received";
    const admin = createClient(getEnv("SUPABASE_URL"), getEnv("SUPABASE_SERVICE_ROLE_KEY"), {
      auth: { persistSession: false },
    });

    await admin.from("payment_events").upsert({
      provider: "paddle",
      event_id: eventId,
      user_id: userId,
      product_code: productCode,
      provider_transaction_id: transactionId,
      status,
      amount_stars: amountStars,
      entitlement_type: entitlementType,
      resource_type: resourceType,
      resource_id: resourceId,
      raw_event: {
        event_id: payload.event_id,
        event_type: eventType,
        data_id: payload.data?.id,
        data_status: payload.data?.status,
        custom_data: custom,
      },
      processed_at: new Date().toISOString(),
    }, { onConflict: "provider,event_id" });

    if (userId && isGrantEvent && amountStars > 0) {
      const idempotencyKey = `paddle:${eventId}:stars`;
      const existing = await admin.from("star_ledger")
        .select("id")
        .eq("user_id", userId)
        .eq("idempotency_key", idempotencyKey)
        .maybeSingle();
      if (!existing.data) {
        await admin.from("star_ledger").insert({
          user_id: userId,
          amount: amountStars,
          entry_type: "grant",
          reason: "paddle_web_purchase",
          source_provider: "paddle",
          source_event_id: eventId,
          reference_type: "payment_event",
          idempotency_key: idempotencyKey,
          metadata: { productCode },
        });
      }
    }

    if (userId && isGrantEvent && entitlementType && entitlementType !== "star_pack") {
      const sourceEventId = `${eventId}:entitlement`;
      const existing = await admin.from("entitlements")
        .select("id")
        .eq("source_provider", "paddle")
        .eq("source_event_id", sourceEventId)
        .maybeSingle();
      if (!existing.data) {
        await admin.from("entitlements").insert({
          user_id: userId,
          entitlement_type: entitlementType,
          resource_type: resourceType,
          resource_id: resourceId,
          product_code: productCode,
          status: "active",
          source_provider: "paddle",
          source_event_id: sourceEventId,
          metadata: { eventType },
        });
      }
    }

    if (userId && isRevokeEvent) {
      await admin.from("entitlements")
        .update({ status: status === "refunded" ? "refunded" : "cancelled" })
        .eq("user_id", userId)
        .eq("source_provider", "paddle")
        .eq("product_code", productCode);

      if (amountStars > 0) {
        const idempotencyKey = `paddle:${eventId}:revoke`;
        const existing = await admin.from("star_ledger")
          .select("id")
          .eq("user_id", userId)
          .eq("idempotency_key", idempotencyKey)
          .maybeSingle();
        if (!existing.data) {
          await admin.from("star_ledger").insert({
            user_id: userId,
            amount: -amountStars,
            entry_type: "revoke",
            reason: "paddle_refund_or_cancellation",
            source_provider: "paddle",
            source_event_id: eventId,
            reference_type: "payment_event",
            idempotency_key: idempotencyKey,
            metadata: { productCode, eventType },
          });
        }
      }
    }

    return json({ received: true, status });
  } catch (error) {
    const message = error instanceof Error ? error.message : "unknown_error";
    return json({ error: message }, message.startsWith("missing_env:") ? 503 : 500);
  }
});
