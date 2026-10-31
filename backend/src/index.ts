import { daysRemaining, parseConfig, phase, type CampaignEnv } from "./campaign";

export interface Env extends CampaignEnv {
  DB?: D1Database;
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

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const { pathname } = new URL(request.url);
    if (pathname === "/health") return json({ ok: true });
    if (pathname === "/api/v1/config/public") {
      if (request.method !== "GET") return json({ error: "method_not_allowed" }, 405);
      return publicConfig(env, new Date()); // soat faqat serverdan
    }
    return json({ error: "not_found" }, 404);
  },
};
