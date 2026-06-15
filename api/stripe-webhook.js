import Stripe from "stripe";
import { createClient } from "@supabase/supabase-js";

const STAR_PACKAGES = {
  first_100: { stars: 100, firstPurchaseOnly: true },
  basic_120: { stars: 120 },
  explore_350: { stars: 350 },
  deep_800: { stars: 800 },
  long_1800: { stars: 1800 }
};

function send(res, status, body) {
  res.statusCode = status;
  res.setHeader("Content-Type", "application/json; charset=utf-8");
  res.end(JSON.stringify(body));
}

async function readRawBody(req) {
  const chunks = [];
  for await (const chunk of req) chunks.push(Buffer.from(chunk));
  return Buffer.concat(chunks);
}

export default async function handler(req, res) {
  if (req.method !== "POST") {
    return send(res, 405, { error: "method_not_allowed" });
  }

  const stripeSecretKey = process.env.STRIPE_SECRET_KEY;
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
  const supabaseUrl = process.env.VITE_SUPABASE_URL || process.env.SUPABASE_URL;
  const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!stripeSecretKey || !webhookSecret || !supabaseUrl || !supabaseServiceRoleKey) {
    return send(res, 500, { error: "webhook_not_configured" });
  }

  const stripe = new Stripe(stripeSecretKey);
  const rawBody = await readRawBody(req);
  let event;

  try {
    event = stripe.webhooks.constructEvent(rawBody, req.headers["stripe-signature"], webhookSecret);
  } catch (error) {
    return send(res, 400, { error: "invalid_signature" });
  }

  if (event.type === "checkout.session.completed") {
    const session = event.data.object;
    const userId = session.metadata?.user_id;
    const packageId = session.metadata?.package_id;
    const selected = STAR_PACKAGES[packageId];

    if (!userId || !selected) {
      return send(res, 400, { error: "invalid_metadata" });
    }

    const admin = createClient(supabaseUrl, supabaseServiceRoleKey);
    if (selected.firstPurchaseOnly) {
      const { count, error: firstPurchaseError } = await admin
        .from("star_ledger")
        .select("id", { count: "exact", head: true })
        .eq("user_id", userId)
        .eq("entry_type", "purchase")
        .neq("provider_payment_id", session.id);

      if (firstPurchaseError) {
        return send(res, 500, { error: "first_purchase_check_failed" });
      }

      if ((count || 0) > 0) {
        return send(res, 200, { received: true, skipped: "first_purchase_already_used" });
      }
    }

    const { error } = await admin.from("star_ledger").insert({
      user_id: userId,
      entry_type: "purchase",
      reason: "star_purchase",
      amount: selected.stars,
      requested_amount: selected.stars,
      ref_type: "stripe_checkout",
      idempotency_key: `purchase:stripe:${session.id}`,
      provider_payment_id: session.id,
      metadata: {
        package_id: packageId,
        first_purchase_offer: Boolean(selected.firstPurchaseOnly),
        payment_status: session.payment_status,
        amount_total: session.amount_total,
        currency: session.currency
      }
    });

    if (error && error.code !== "23505") {
      return send(res, 500, { error: "ledger_insert_failed" });
    }
  }

  return send(res, 200, { received: true });
}
