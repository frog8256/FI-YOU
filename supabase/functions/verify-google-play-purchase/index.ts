import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type ProductConfig = {
  starAmount: number;
  amountKrw?: number;
  entitlementType?: string;
};

type VerifyRequest = {
  productId: string;
  purchaseToken: string;
  packageName?: string;
};

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

const base64Url = (bytes: Uint8Array) =>
  btoa(String.fromCharCode(...bytes))
    .replaceAll("+", "-")
    .replaceAll("/", "_")
    .replaceAll("=", "");

const encodeJson = (value: unknown) =>
  base64Url(new TextEncoder().encode(JSON.stringify(value)));

const pemToArrayBuffer = (pem: string) => {
  const normalized = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");
  const binary = atob(normalized);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i += 1) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
};

async function getGoogleAccessToken() {
  const raw = Deno.env.get("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON");
  if (!raw) throw new Error("missing_google_play_service_account_json");

  const account = JSON.parse(raw) as {
    client_email: string;
    private_key: string;
    token_uri?: string;
  };
  const tokenUri = account.token_uri ?? "https://oauth2.googleapis.com/token";
  const now = Math.floor(Date.now() / 1000);
  const unsignedJwt = [
    encodeJson({ alg: "RS256", typ: "JWT" }),
    encodeJson({
      iss: account.client_email,
      scope: "https://www.googleapis.com/auth/androidpublisher",
      aud: tokenUri,
      iat: now,
      exp: now + 3600,
    }),
  ].join(".");

  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(account.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsignedJwt),
  );
  const assertion = `${unsignedJwt}.${base64Url(new Uint8Array(signature))}`;

  const response = await fetch(tokenUri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });

  if (!response.ok) {
    throw new Error(`google_token_exchange_failed:${response.status}`);
  }

  const payload = await response.json() as { access_token?: string };
  if (!payload.access_token) throw new Error("google_access_token_missing");
  return payload.access_token;
}

async function verifyProductPurchase(
  packageName: string,
  productId: string,
  purchaseToken: string,
) {
  const accessToken = await getGoogleAccessToken();
  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${
      encodeURIComponent(packageName)
    }/purchases/products/${encodeURIComponent(productId)}/tokens/${
      encodeURIComponent(purchaseToken)
    }`;

  const response = await fetch(url, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  const payload = await response.json();

  if (!response.ok) {
    return { ok: false, status: response.status, payload, accessToken };
  }

  return { ok: true, status: response.status, payload, accessToken };
}

async function acknowledgeProductPurchase(
  packageName: string,
  productId: string,
  purchaseToken: string,
  accessToken: string,
) {
  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${
      encodeURIComponent(packageName)
    }/purchases/products/${encodeURIComponent(productId)}/tokens/${
      encodeURIComponent(purchaseToken)
    }:acknowledge`;

  const response = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({}),
  });

  if (!response.ok) {
    throw new Error(`google_purchase_acknowledge_failed:${response.status}`);
  }
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (request.method !== "POST") return json(405, { error: "method_not_allowed" });

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const defaultPackageName = Deno.env.get("GOOGLE_PLAY_PACKAGE_NAME");
    const productMap = JSON.parse(Deno.env.get("GOOGLE_PLAY_PRODUCT_MAP") ?? "{}") as Record<
      string,
      ProductConfig
    >;

    if (!supabaseUrl || !serviceRoleKey) throw new Error("missing_supabase_env");

    const authHeader = request.headers.get("Authorization") ?? "";
    const jwt = authHeader.replace(/^Bearer\s+/i, "");
    if (!jwt) return json(401, { error: "missing_authorization" });

    const body = await request.json() as VerifyRequest;
    const product = productMap[body.productId];
    if (!product) return json(400, { error: "unknown_product_id" });

    const packageName = body.packageName ?? defaultPackageName;
    if (!packageName) return json(400, { error: "missing_package_name" });
    if (defaultPackageName && packageName !== defaultPackageName) {
      return json(400, { error: "package_name_mismatch" });
    }
    if (!body.purchaseToken) return json(400, { error: "missing_purchase_token" });

    const admin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });

    const { data: userData, error: userError } = await admin.auth.getUser(jwt);
    if (userError || !userData.user) return json(401, { error: "invalid_user_session" });

    const verification = await verifyProductPurchase(
      packageName,
      body.productId,
      body.purchaseToken,
    );
    if (!verification.ok) {
      return json(402, {
        error: "purchase_verification_failed",
        googleStatus: verification.status,
      });
    }

    const googlePayload = verification.payload as {
      purchaseState?: number;
      orderId?: string;
      acknowledgementState?: number;
      purchaseTimeMillis?: string;
    };

    if (googlePayload.purchaseState !== 0) {
      return json(402, { error: "purchase_not_completed" });
    }

    const providerPaymentId =
      `googleplay:${body.productId}:${googlePayload.orderId ?? body.purchaseToken}`;

    const { data: ledger, error: ledgerError } = await admin.rpc("record_star_purchase", {
      p_user_id: userData.user.id,
      p_provider_payment_id: providerPaymentId,
      p_star_amount: product.starAmount,
      p_amount_krw: product.amountKrw ?? null,
      p_metadata: {
        provider: "google_play",
        packageName,
        productId: body.productId,
        orderId: googlePayload.orderId ?? null,
        acknowledgementState: googlePayload.acknowledgementState ?? null,
        purchaseTimeMillis: googlePayload.purchaseTimeMillis ?? null,
      },
    });

    if (ledgerError) throw ledgerError;

    if (googlePayload.acknowledgementState === 0) {
      await acknowledgeProductPurchase(
        packageName,
        body.productId,
        body.purchaseToken,
        verification.accessToken,
      );
    }

    const { data: ledgerRows, error: balanceError } = await admin
      .from("star_ledger")
      .select("amount")
      .eq("user_id", userData.user.id);
    if (balanceError) throw balanceError;

    const balance = (ledgerRows ?? []).reduce(
      (sum, row) => sum + Number(row.amount ?? 0),
      0,
    );

    return json(200, {
      ok: true,
      ledger,
      starBalance: balance,
    });
  } catch (error) {
    return json(500, {
      error: "verify_google_play_purchase_failed",
      message: error instanceof Error ? error.message : String(error),
    });
  }
});
