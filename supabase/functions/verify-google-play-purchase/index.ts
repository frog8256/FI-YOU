import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

type PurchaseBody = {
  packageName?: string;
  productId?: string;
  purchaseToken?: string;
  productType?: "inapp" | "subscription";
  amountStars?: number;
  entitlementType?: string;
  resourceType?: string;
  productCode?: string;
};

const jsonHeaders = {
  "Content-Type": "application/json",
};

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  const supabaseUrl = requiredEnv("SUPABASE_URL");
  const anonKey = requiredEnv("SUPABASE_ANON_KEY");
  const serviceRoleKey = requiredEnv("SUPABASE_SERVICE_ROLE_KEY");
  const serviceAccountJson = requiredEnv("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON");
  const expectedPackageName = Deno.env.get("GOOGLE_PLAY_PACKAGE_NAME") ?? "com.fiyou.app";

  if (!supabaseUrl || !anonKey || !serviceRoleKey || !serviceAccountJson) {
    return json({ error: "server_not_configured" }, 503);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return json({ error: "missing_authorization" }, 401);
  }

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: authData, error: authError } = await userClient.auth.getUser();
  if (authError || !authData.user) {
    return json({ error: "invalid_user" }, 401);
  }

  const body = (await req.json()) as PurchaseBody;
  if (body.packageName !== expectedPackageName) {
    return json({ error: "invalid_package" }, 400);
  }
  if (!body.productId || !body.purchaseToken) {
    return json({ error: "missing_purchase_fields" }, 400);
  }

  const accessToken = await getGoogleAccessToken(serviceAccountJson);
  const verification = await verifyPurchase({
    accessToken,
    packageName: expectedPackageName,
    productId: body.productId,
    purchaseToken: body.purchaseToken,
    productType: body.productType ?? "inapp",
  });

  if (!verification.valid) {
    return json({ error: "purchase_not_valid", details: verification.details }, 400);
  }

  const admin = createClient(supabaseUrl, serviceRoleKey);
  const metadata = {
    productId: body.productId,
    productType: body.productType ?? "inapp",
    resourceType: body.resourceType ?? null,
    google: verification.details,
  };

  if (body.amountStars && body.amountStars > 0) {
    const { error } = await admin.from("star_ledger").insert({
      user_id: authData.user.id,
      entry_type: "purchase",
      reason: "google_play_purchase",
      amount: body.amountStars,
      requested_amount: body.amountStars,
      ref_type: "google_play_product",
      idempotency_key: `google-play:${body.purchaseToken}`,
      provider_payment_id: body.purchaseToken,
      metadata,
    });
    if (error && error.code !== "23505") {
      return json({ error: "star_grant_failed", details: error.message }, 500);
    }
  } else {
    const { error } = await admin.from("entitlements").insert({
      user_id: authData.user.id,
      entitlement_type: body.entitlementType ?? body.productId,
      star_cost: 0,
      metadata,
    });
    if (error && error.code !== "23505") {
      return json({ error: "entitlement_grant_failed", details: error.message }, 500);
    }
  }

  return json({ ok: true });
});

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), { status, headers: jsonHeaders });
}

function requiredEnv(name: string) {
  return Deno.env.get(name) ?? "";
}

async function verifyPurchase(args: {
  accessToken: string;
  packageName: string;
  productId: string;
  purchaseToken: string;
  productType: string;
}) {
  const url =
    args.productType === "subscription"
      ? `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${args.packageName}/purchases/subscriptionsv2/tokens/${args.purchaseToken}`
      : `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${args.packageName}/purchases/products/${args.productId}/tokens/${args.purchaseToken}`;

  const response = await fetch(url, {
    headers: { Authorization: `Bearer ${args.accessToken}` },
  });
  const details = await response.json();
  if (!response.ok) {
    return { valid: false, details };
  }

  if (args.productType === "subscription") {
    const activeStates = new Set([
      "SUBSCRIPTION_STATE_ACTIVE",
      "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
      "SUBSCRIPTION_STATE_ON_HOLD",
    ]);
    return { valid: activeStates.has(details.subscriptionState), details };
  }

  return { valid: details.purchaseState === 0, details };
}

async function getGoogleAccessToken(serviceAccountJson: string) {
  const serviceAccount = JSON.parse(serviceAccountJson);
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/androidpublisher",
    aud: "https://oauth2.googleapis.com/token",
    exp: now + 3600,
    iat: now,
  };

  const unsignedToken = `${base64Url(header)}.${base64Url(payload)}`;
  const privateKey = serviceAccount.private_key.replace(/\\n/g, "\n");
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(privateKey),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsignedToken),
  );
  const assertion = `${unsignedToken}.${base64UrlBytes(new Uint8Array(signature))}`;

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  const token = await response.json();
  if (!response.ok || !token.access_token) {
    throw new Error("google_access_token_failed");
  }
  return token.access_token as string;
}

function base64Url(value: unknown) {
  return base64UrlBytes(new TextEncoder().encode(JSON.stringify(value)));
}

function base64UrlBytes(bytes: Uint8Array) {
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "");
}

function pemToArrayBuffer(pem: string) {
  const base64 = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes.buffer;
}
