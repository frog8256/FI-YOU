import Stripe from "stripe";
import { createClient } from "@supabase/supabase-js";

const STAR_PACKAGES = {
  first_100: { name: "First Purchase Pack", stars: 100, amount: 99, firstPurchaseOnly: true },
  basic_120: { name: "Basic Pack", stars: 120, amount: 199 },
  explore_350: { name: "Explore Pack", stars: 350, amount: 499 },
  deep_800: { name: "Deep Dive Pack", stars: 800, amount: 999 },
  long_1800: { name: "Long Journey Pack", stars: 1800, amount: 1999 }
};

function json(res, status, body) {
  res.statusCode = status;
  res.setHeader("Content-Type", "application/json; charset=utf-8");
  res.end(JSON.stringify(body));
}

export default async function handler(req, res) {
  if (req.method !== "POST") {
    return json(res, 405, { error: "method_not_allowed" });
  }

  const supabaseUrl = process.env.VITE_SUPABASE_URL || process.env.SUPABASE_URL;
  const supabaseAnonKey = process.env.VITE_SUPABASE_PUBLISHABLE_KEY || process.env.SUPABASE_ANON_KEY;
  const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  const stripeSecretKey = process.env.STRIPE_SECRET_KEY;

  if (!supabaseUrl || !supabaseAnonKey || !supabaseServiceRoleKey || !stripeSecretKey) {
    return json(res, 500, { error: "payment_not_configured" });
  }

  const authHeader = req.headers.authorization || "";
  const token = authHeader.startsWith("Bearer ") ? authHeader.slice(7) : "";
  if (!token) return json(res, 401, { error: "not_authenticated" });

  let body = "";
  for await (const chunk of req) body += chunk;

  let parsedBody = {};
  try {
    parsedBody = body ? JSON.parse(body) : {};
  } catch {
    return json(res, 400, { error: "invalid_json" });
  }

  const { packageId } = parsedBody;
  const selected = STAR_PACKAGES[packageId];
  if (!selected) return json(res, 400, { error: "invalid_package" });

  const authClient = createClient(supabaseUrl, supabaseAnonKey);
  const { data: userData, error: userError } = await authClient.auth.getUser(token);
  if (userError || !userData?.user) return json(res, 401, { error: "invalid_session" });

  const admin = createClient(supabaseUrl, supabaseServiceRoleKey);
  if (selected.firstPurchaseOnly) {
    const { count, error } = await admin
      .from("star_ledger")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userData.user.id)
      .eq("entry_type", "purchase");

    if (error) return json(res, 500, { error: "purchase_check_failed" });
    if ((count || 0) > 0) return json(res, 409, { error: "first_purchase_only" });
  }

  const stripe = new Stripe(stripeSecretKey);
  const origin = req.headers.origin || `https://${req.headers.host}`;
  const session = await stripe.checkout.sessions.create({
    mode: "payment",
    success_url: `${origin}/?screen=home&payment=success`,
    cancel_url: `${origin}/?screen=home&payment=cancel`,
    client_reference_id: userData.user.id,
    metadata: {
      user_id: userData.user.id,
      package_id: packageId,
      stars: String(selected.stars),
      first_purchase_offer: String(Boolean(selected.firstPurchaseOnly))
    },
    line_items: [
      {
        quantity: 1,
        price_data: {
          currency: "usd",
          unit_amount: selected.amount,
          product_data: {
            name: `FI-YOU ${selected.name}`,
            description: `${selected.stars} Star`
          }
        }
      }
    ]
  });

  return json(res, 200, { url: session.url });
}
