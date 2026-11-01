import { daysRemaining, parseConfig, phase, type CampaignEnv } from "./campaign";
import { AuthError, getFirebaseJwks, verifyFirebaseIdToken } from "./firebase_auth";
import { AiProviderError, callGemini, parseAiRequest, tashkentDay } from "./ai";
import { legalPage } from "./legal";

export interface Env extends CampaignEnv {
  DB?: D1Database;
  FIREBASE_PROJECT_ID?: string;
  /** Vergul bilan ajratilgan admin emaillari (maxfiy emas). Faqat TASDIQLANGAN email admin hisoblanadi. */
  ADMIN_EMAILS?: string;
  /** Maxfiy: faqat `wrangler secret put GEMINI_API_KEY`. */
  GEMINI_API_KEY?: string;
  AI_MODEL?: string;
  AI_FREE_DAILY_REQUESTS?: string;
  AI_PRO_DAILY_REQUESTS?: string;
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

/** Authorization: Bearer <Firebase ID token> ni tekshiradi. Muvaffaqiyatsiz bo'lsa tayyor Response qaytaradi. */
type AuthedUser = { uid: string; provider?: string; email?: string; emailVerified: boolean };

async function authenticate(request: Request, env: Env): Promise<AuthedUser | Response> {
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
    return { uid: user.uid, provider: user.provider, email: user.email, emailVerified: user.emailVerified === true };
  } catch (e) {
    if (e instanceof AuthError) return json({ error: "unauthorized" }, 401); // sababi oshkor qilinmaydi
    throw e;
  }
}

/** Admin: email ADMIN_EMAILS ro'yxatida va Firebase tomonidan TASDIQLANGAN bo'lsa (tasdiqlanmagan email soxta bo'lishi mumkin). */
export function isAdmin(env: Env, u: { email?: string; emailVerified: boolean }): boolean {
  if (!u.emailVerified || !u.email || !env.ADMIN_EMAILS) return false;
  const email = u.email.trim().toLowerCase();
  return env.ADMIN_EMAILS.split(",").some((e) => e.trim().toLowerCase() === email && email.length > 0);
}

/** Pro: admin, faol entitlement yoki TASDIQLANGAN email bo'yicha admin bergan Pro. */
async function isPro(env: Env, a: AuthedUser): Promise<boolean> {
  if (isAdmin(env, a)) return true;
  if (!env.DB) return false;
  const row = await env.DB.prepare(
    "SELECT COUNT(*) AS n FROM entitlements WHERE user_id = ? AND (ends_at IS NULL OR ends_at > datetime('now'))",
  ).bind(a.uid).first<{ n: number }>();
  if ((row?.n ?? 0) > 0) return true;
  if (a.emailVerified && a.email) {
    const g = await env.DB.prepare(
      "SELECT COUNT(*) AS n FROM promo_grants WHERE email = ? AND (ends_at IS NULL OR ends_at > datetime('now'))",
    ).bind(a.email.trim().toLowerCase()).first<{ n: number }>();
    return (g?.n ?? 0) > 0;
  }
  return false;
}

/** POST /api/v1/ai/ask: kirgan foydalanuvchi, kunlik kvota (Toshkent kuni), idempotent requestId. */
export async function aiAsk(request: Request, env: Env, fetcher?: typeof fetch): Promise<Response> {
  const a = await authenticate(request, env);
  if (a instanceof Response) return a;
  if (!env.GEMINI_API_KEY) return json({ error: "ai_not_configured" }, 503);
  const db = env.DB;
  if (!db) return json({ error: "server_misconfigured" }, 500);
  const req = parseAiRequest(await request.text());
  if (!req) return json({ error: "bad_request" }, 400);
  const pro = await isPro(env, a);
  const limit = Math.max(0, parseInt((pro ? env.AI_PRO_DAILY_REQUESTS : env.AI_FREE_DAILY_REQUESTS) ?? "", 10) || (pro ? 50 : 5));
  const day = tashkentDay(new Date());
  await db.prepare("INSERT OR IGNORE INTO users (id) VALUES (?)").bind(a.uid).run();
  const fresh = await db.prepare("INSERT OR IGNORE INTO ai_request_idempotency (user_id, request_id, day) VALUES (?, ?, ?)")
    .bind(a.uid, req.requestId, day).run();
  if ((fresh.meta?.changes ?? 0) > 0) {
    // Atomar: faqat limitdan oshmasa oshiriladi.
    const r = await db.prepare(
      `INSERT INTO ai_daily_usage (user_id, day, count) VALUES (?, ?, 1)
       ON CONFLICT(user_id, day) DO UPDATE SET count = count + 1 WHERE count < ?`,
    ).bind(a.uid, day, limit).run();
    if ((r.meta?.changes ?? 0) === 0 || limit === 0) {
      await db.prepare("DELETE FROM ai_request_idempotency WHERE user_id = ? AND request_id = ?").bind(a.uid, req.requestId).run();
      return json({ error: "quota_exceeded", limit, pro }, 429);
    }
  }
  const used = (await db.prepare("SELECT count FROM ai_daily_usage WHERE user_id = ? AND day = ?").bind(a.uid, day).first<{ count: number }>())?.count ?? 0;
  try {
    const answer = await callGemini(req, { apiKey: env.GEMINI_API_KEY, model: env.AI_MODEL || "gemini-2.5-flash-lite", fetcher });
    return json({ answer, remaining: Math.max(0, limit - used), limit, pro });
  } catch (e) {
    if (e instanceof AiProviderError) {
      // Muvaffaqiyatsiz javob kvotani sarflamaydi.
      await db.batch([
        db.prepare("UPDATE ai_daily_usage SET count = MAX(count - 1, 0) WHERE user_id = ? AND day = ?").bind(a.uid, day),
        db.prepare("DELETE FROM ai_request_idempotency WHERE user_id = ? AND request_id = ?").bind(a.uid, req.requestId),
      ]);
      return json({ error: "ai_unavailable" }, 502);
    }
    throw e;
  }
}

/** GET /api/v1/me: foydalanuvchini bazaga (bir marta) yozadi; admin va Pro holatini qaytaradi. Pro faqat serverdan. */
async function me(request: Request, env: Env): Promise<Response> {
  const a = await authenticate(request, env);
  if (a instanceof Response) return a;
  await env.DB?.prepare("INSERT OR IGNORE INTO users (id) VALUES (?)").bind(a.uid).run();
  const admin = isAdmin(env, a);
  const pro = await isPro(env, a);
  return json({ uid: a.uid, provider: a.provider, isAdmin: admin, pro });
}

const PLATFORMS = ["android", "ios", "web"] as const;
const INSTALL_ID = /^[A-Za-z0-9-]{16,64}$/;
const APP_VERSION = /^[0-9A-Za-z.+-]{1,32}$/;

/** POST /api/v1/installs: anonim o'rnatish hisoblagichi (tasodifiy ID, shaxsiy ma'lumotsiz). Do'konlar yuklab olish soni emas, ochilgan o'rnatishlar. */
async function recordInstall(request: Request, env: Env): Promise<Response> {
  if (!env.DB) return json({ error: "server_misconfigured" }, 500);
  let body: { installId?: unknown; platform?: unknown; appVersion?: unknown };
  try {
    const raw = await request.text();
    if (raw.length > 2048) return json({ error: "bad_request" }, 400);
    body = JSON.parse(raw);
  } catch {
    return json({ error: "bad_request" }, 400);
  }
  if (typeof body !== "object" || body === null) return json({ error: "bad_request" }, 400);
  const { installId, platform, appVersion } = body;
  if (typeof installId !== "string" || !INSTALL_ID.test(installId)) return json({ error: "bad_request" }, 400);
  if (typeof platform !== "string" || !(PLATFORMS as readonly string[]).includes(platform)) return json({ error: "bad_request" }, 400);
  const version = typeof appVersion === "string" && APP_VERSION.test(appVersion) ? appVersion : "unknown";
  await env.DB.prepare(
    `INSERT INTO installs (id, platform, app_version) VALUES (?, ?, ?)
     ON CONFLICT(id) DO UPDATE SET last_seen = datetime('now'), opens = opens + 1, app_version = excluded.app_version, platform = excluded.platform`,
  ).bind(installId, platform, version).run();
  return json({ ok: true });
}

/** GET /api/v1/admin/stats: faqat admin. */
async function adminStats(request: Request, env: Env): Promise<Response> {
  const a = await authenticate(request, env);
  if (a instanceof Response) return a;
  if (!isAdmin(env, a)) return json({ error: "forbidden" }, 403);
  const db = env.DB;
  if (!db) return json({ error: "server_misconfigured" }, 500);
  const count = async (sql: string, ...args: unknown[]) => (await db.prepare(sql).bind(...args).first<{ n: number }>())?.n ?? 0;
  const byPlatform: Record<string, number> = {};
  for (const p of PLATFORMS) byPlatform[p] = await count("SELECT COUNT(*) AS n FROM installs WHERE platform = ?", p);
  return json({
    generatedAt: new Date().toISOString(),
    installs: {
      total: await count("SELECT COUNT(*) AS n FROM installs"),
      byPlatform,
      new7d: await count("SELECT COUNT(*) AS n FROM installs WHERE first_seen >= datetime('now', '-7 days')"),
      active7d: await count("SELECT COUNT(*) AS n FROM installs WHERE last_seen >= datetime('now', '-7 days')"),
      active30d: await count("SELECT COUNT(*) AS n FROM installs WHERE last_seen >= datetime('now', '-30 days')"),
    },
    users: {
      total: await count("SELECT COUNT(*) AS n FROM users"),
      new7d: await count("SELECT COUNT(*) AS n FROM users WHERE created_at >= datetime('now', '-7 days')"),
    },
    pro: {
      paid: await count("SELECT COUNT(DISTINCT user_id) AS n FROM entitlements WHERE ends_at IS NULL OR ends_at > datetime('now')"),
      grantedByAdmin: await count("SELECT COUNT(*) AS n FROM promo_grants WHERE ends_at IS NULL OR ends_at > datetime('now')"),
    },
  });
}

/** DELETE /api/v1/me: foydalanuvchining BARCHA serverdagi ma'lumotlarini bitta batch'da o'chiradi (Apple/Google talabi). */
async function deleteMe(request: Request, env: Env): Promise<Response> {
  const a = await authenticate(request, env);
  if (a instanceof Response) return a;
  const db = env.DB;
  if (!db) return json({ error: "server_misconfigured" }, 500);
  try {
    // Bog'liq jadvallar avval (users'ga FOREIGN KEY bor)
    const stmts = [
      db.prepare("DELETE FROM entitlements WHERE user_id = ?").bind(a.uid),
      db.prepare("DELETE FROM ai_daily_usage WHERE user_id = ?").bind(a.uid),
      db.prepare("DELETE FROM ai_request_idempotency WHERE user_id = ?").bind(a.uid),
      db.prepare("DELETE FROM users WHERE id = ?").bind(a.uid),
    ];
    // Email bo'yicha berilgan Pro ham shaxsiy ma'lumot: faqat tasdiqlangan email egasi o'chira oladi.
    if (a.emailVerified && a.email) stmts.unshift(db.prepare("DELETE FROM promo_grants WHERE email = ?").bind(a.email.trim().toLowerCase()));
    await db.batch(stmts);
    return json({ deleted: true });
  } catch {
    return json({ error: "delete_failed" }, 500);
  }
}

const EMAIL_RE = /^[^\s@]{1,64}@[^\s@.]+(\.[^\s@.]+)+$/;
const MAX_GRANT_DAYS = 3650;

function normalizeEmail(v: unknown): string | null {
  if (typeof v !== "string") return null;
  const e = v.trim().toLowerCase();
  return e.length <= 254 && EMAIL_RE.test(e) ? e : null;
}

/** /api/v1/admin/grants: GET ro'yxat, POST {email, days?} Pro berish (days yo'q = cheksiz), DELETE {email} qaytarib olish. Faqat admin. */
async function adminGrants(request: Request, env: Env): Promise<Response> {
  const a = await authenticate(request, env);
  if (a instanceof Response) return a;
  if (!isAdmin(env, a)) return json({ error: "forbidden" }, 403);
  const db = env.DB;
  if (!db) return json({ error: "server_misconfigured" }, 500);
  if (request.method === "GET") {
    const r = await db.prepare("SELECT email, ends_at, granted_at FROM promo_grants WHERE 1 = ? ORDER BY granted_at DESC LIMIT 200").bind(1).all();
    return json({ grants: r.results ?? [] });
  }
  let body: { email?: unknown; days?: unknown };
  try {
    body = JSON.parse(await request.text());
  } catch {
    return json({ error: "bad_request" }, 400);
  }
  if (typeof body !== "object" || body === null) return json({ error: "bad_request" }, 400);
  const email = normalizeEmail(body.email);
  if (!email) return json({ error: "bad_request" }, 400);
  if (request.method === "DELETE") {
    await db.prepare("DELETE FROM promo_grants WHERE email = ?").bind(email).run();
    return json({ ok: true, email });
  }
  let endsAt: string | null = null;
  if (body.days !== undefined && body.days !== null) {
    const d = body.days;
    if (typeof d !== "number" || !Number.isInteger(d) || d < 1 || d > MAX_GRANT_DAYS) return json({ error: "bad_request" }, 400);
    endsAt = new Date(Date.now() + d * 86_400_000).toISOString().slice(0, 19).replace("T", " ");
  }
  await db.prepare(
    "INSERT INTO promo_grants (email, ends_at) VALUES (?, ?) ON CONFLICT(email) DO UPDATE SET ends_at = excluded.ends_at, granted_at = datetime('now')",
  ).bind(email, endsAt).run();
  return json({ ok: true, email, endsAt });
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const { pathname } = url;
    if (pathname === "/health") return json({ ok: true });
    if (pathname === "/privacy" || pathname === "/terms" || pathname === "/delete-account") {
      if (request.method !== "GET") return json({ error: "method_not_allowed" }, 405);
      return legalPage(pathname.slice(1) as "privacy" | "terms" | "delete-account", url.searchParams.get("lang"));
    }
    if (pathname === "/api/v1/config/public") {
      if (request.method !== "GET") return json({ error: "method_not_allowed" }, 405);
      return publicConfig(env, new Date()); // soat faqat serverdan
    }
    if (pathname === "/api/v1/me") {
      if (request.method === "GET") return me(request, env);
      if (request.method === "DELETE") return deleteMe(request, env);
      return json({ error: "method_not_allowed" }, 405);
    }
    if (pathname === "/api/v1/ai/ask") {
      if (request.method !== "POST") return json({ error: "method_not_allowed" }, 405);
      return aiAsk(request, env);
    }
    if (pathname === "/api/v1/installs") {
      if (request.method !== "POST") return json({ error: "method_not_allowed" }, 405);
      return recordInstall(request, env);
    }
    if (pathname === "/api/v1/admin/grants") {
      if (!["GET", "POST", "DELETE"].includes(request.method)) return json({ error: "method_not_allowed" }, 405);
      return adminGrants(request, env);
    }
    if (pathname === "/api/v1/admin/stats") {
      if (request.method !== "GET") return json({ error: "method_not_allowed" }, 405);
      return adminStats(request, env);
    }
    return json({ error: "not_found" }, 404);
  },
};
