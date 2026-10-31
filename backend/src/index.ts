import { daysRemaining, parseConfig, phase, type CampaignEnv } from "./campaign";
import { AuthError, getFirebaseJwks, verifyFirebaseIdToken } from "./firebase_auth";

export interface Env extends CampaignEnv {
  DB?: D1Database;
  FIREBASE_PROJECT_ID?: string;
}

const json = (body: unknown, status = 200): Response =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" },
  });

function publicConfig(env: Env, now: Date): Response {
  let cfg;
  try {
    cfg = parseConfig(env);
  } catch {
    return json({ error: "server_misconfigured" }, 500); // ichki xato matni oshkor qilinmaydi
  }
  return json({
    campaign: {
      kind: "global_90_day_launch",
      phase: phase(cfg, now),
      officialLaunchDate: cfg.officialLaunchDate,
      durationDays: cfg.days,
      daysRemaining: daysRemaining(cfg, now),
      requiresCard: false,
      autoCharge: false,
    },
    features: { billingEnabled: cfg.billingEnabled, adsEnabled: cfg.adsEnabled, sponsoredProductsEnabled: false },
    aiDailyLimitFree: cfg.freeDailyAi,
  });
}

/** GET /api/v1/me: Firebase tokenini tekshiradi, foydalanuvchini bazaga (bir marta) yozadi. */
async function me(request: Request, env: Env): Promise<Response> {
  if (!env.FIREBASE_PROJECT_ID) return json({ error: "server_misconfigured" }, 500);
  const m = /^Bearer (.+)$/.exec(request.headers.get("authorization") ?? "");
  if (!m) return json({ error: "unauthorized" }, 401);
  let jwks;
  try {
    jwks = await getFirebaseJwks();
  } catch {
    return json({ error: "auth_unavailable" }, 503);
  }
  try {
    const user = await verifyFirebaseIdToken(m[1], { projectId: env.FIREBASE_PROJECT_ID, jwks });
    await env.DB?.prepare("INSERT OR IGNORE INTO users (id) VALUES (?)").bind(user.uid).run();
    return json({ uid: user.uid, provider: user.provider });
  } catch (e) {
    if (e instanceof AuthError) return json({ error: "unauthorized" }, 401); // sababi oshkor qilinmaydi
    throw e;
  }
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const { pathname } = new URL(request.url);
    if (pathname === "/health") return json({ ok: true });
    if (pathname === "/api/v1/config/public") {
      if (request.method !== "GET") return json({ error: "method_not_allowed" }, 405);
      return publicConfig(env, new Date()); // soat faqat serverdan
    }
    if (pathname === "/api/v1/me") {
      if (request.method !== "GET") return json({ error: "method_not_allowed" }, 405);
      return me(request, env);
    }
    return json({ error: "not_found" }, 404);
  },
};
