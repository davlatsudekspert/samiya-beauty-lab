import { beforeAll, describe, expect, it, vi } from "vitest";
import { resetJwksCache, type Jwk } from "../src/firebase_auth";
import worker from "../src/index";

const PROJECT = "samiya-beauty-lab";
const ADMIN = "davlatsudekspert@gmail.com";
const enc = new TextEncoder();
const b64u = (b: ArrayBuffer | Uint8Array) =>
  btoa(String.fromCharCode(...new Uint8Array(b as ArrayBuffer))).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
const jb = (o: unknown) => b64u(enc.encode(JSON.stringify(o)));
let jwk: Jwk;
let priv: CryptoKey;

beforeAll(async () => {
  const kp = (await crypto.subtle.generateKey(
    { name: "RSASSA-PKCS1-v1_5", modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]), hash: "SHA-256" },
    true, ["sign", "verify"])) as CryptoKeyPair;
  jwk = { ...((await crypto.subtle.exportKey("jwk", kp.publicKey)) as Jwk), kid: "k1" };
  priv = kp.privateKey;
});

async function token(claims: Record<string, unknown> = {}) {
  const now = Math.floor(Date.now() / 1000);
  const body = `${jb({ alg: "RS256", kid: "k1" })}.${jb({
    iss: `https://securetoken.google.com/${PROJECT}`, aud: PROJECT, sub: "uid-1", iat: now - 5, exp: now + 3000, auth_time: now - 5,
    ...claims,
  })}`;
  return `${body}.${b64u(await crypto.subtle.sign("RSASSA-PKCS1-v1_5", priv, enc.encode(body)))}`;
}
const adminTok = () => token({ email: ADMIN, email_verified: true, firebase: { sign_in_provider: "google.com" } });

type Stmt = { sql: string; args: unknown[] };
function fakeDb(counts: Record<string, number> = {}, entitlementRows = 0, grantRows = 0) {
  const ran: Stmt[] = [];
  const db = {
    prepare: (sql: string) => ({
      bind: (...args: unknown[]) => ({
        run: async () => { ran.push({ sql, args }); return {}; },
        first: async () => {
          if (/FROM entitlements/.test(sql) && /user_id = \?/.test(sql)) return { n: entitlementRows };
          if (/FROM promo_grants/.test(sql) && /email = \?/.test(sql)) return { n: grantRows };
          const key = Object.keys(counts).find((k) => sql.includes(k));
          return { n: key ? counts[key] : 0 };
        },
        all: async () => ({ results: [] }),
      }),
    }),
  };
  return { db, ran };
}

const env = (db: unknown, extra: Record<string, unknown> = {}) =>
  ({ DB: db, FIREBASE_PROJECT_ID: PROJECT, ADMIN_EMAILS: ADMIN, ...extra }) as never;
const req = (path: string, tok: string | null, method = "GET", body?: unknown) =>
  new Request(`https://api.test${path}`, {
    method,
    headers: { ...(tok ? { authorization: `Bearer ${tok}` } : {}), ...(body ? { "content-type": "application/json" } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  });
const stub = () => {
  resetJwksCache();
  vi.stubGlobal("fetch", async () => new Response(JSON.stringify({ keys: [jwk] }), { headers: { "cache-control": "max-age=60" } }));
};

describe("admin va Pro (GET /api/v1/me)", () => {
  it("admin emaili + email tasdiqlangan: isAdmin va pro true", async () => {
    stub();
    const { db } = fakeDb();
    const r = await worker.fetch(req("/api/v1/me", await adminTok()), env(db));
    expect(await r.json()).toMatchObject({ uid: "uid-1", isAdmin: true, pro: true });
  });
  it("email katta-kichik harfda yozilgan bo'lsa ham admin", async () => {
    stub();
    const { db } = fakeDb();
    const t = await token({ email: "DavlatSudekspert@Gmail.com", email_verified: true });
    expect(await (await worker.fetch(req("/api/v1/me", t), env(db))).json()).toMatchObject({ isAdmin: true });
  });
  it("email TASDIQLANMAGAN bo'lsa admin EMAS (soxta email xavfi)", async () => {
    stub();
    const { db } = fakeDb();
    const t = await token({ email: ADMIN, email_verified: false });
    expect(await (await worker.fetch(req("/api/v1/me", t), env(db))).json()).toMatchObject({ isAdmin: false, pro: false });
  });
  it("email_verified umuman yo'q bo'lsa admin EMAS", async () => {
    stub();
    const { db } = fakeDb();
    const t = await token({ email: ADMIN });
    expect(await (await worker.fetch(req("/api/v1/me", t), env(db))).json()).toMatchObject({ isAdmin: false });
  });
  it("boshqa foydalanuvchi: admin emas, Pro yo'q", async () => {
    stub();
    const { db } = fakeDb();
    const t = await token({ email: "x@gmail.com", email_verified: true });
    expect(await (await worker.fetch(req("/api/v1/me", t), env(db))).json()).toMatchObject({ isAdmin: false, pro: false });
  });
  it("ADMIN_EMAILS sozlanmagan bo'lsa hech kim admin emas", async () => {
    stub();
    const { db } = fakeDb();
    const r = await worker.fetch(req("/api/v1/me", await adminTok()), env(db, { ADMIN_EMAILS: undefined }));
    expect(await r.json()).toMatchObject({ isAdmin: false });
  });
  it("serverda tasdiqlangan entitlement bo'lsa oddiy foydalanuvchi ham Pro", async () => {
    stub();
    const { db } = fakeDb({}, 1);
    const t = await token({ email: "x@gmail.com", email_verified: true });
    expect(await (await worker.fetch(req("/api/v1/me", t), env(db))).json()).toMatchObject({ isAdmin: false, pro: true });
  });
});

describe("GET /api/v1/admin/stats", () => {
  it("tokensiz: 401", async () => {
    stub();
    expect((await worker.fetch(req("/api/v1/admin/stats", null), env(fakeDb().db))).status).toBe(401);
  });
  it("admin bo'lmagan foydalanuvchi: 403", async () => {
    stub();
    const t = await token({ email: "x@gmail.com", email_verified: true });
    const r = await worker.fetch(req("/api/v1/admin/stats", t), env(fakeDb().db));
    expect(r.status).toBe(403);
  });
  it("admin: o'rnatishlar, foydalanuvchilar va Pro soni", async () => {
    stub();
    const { db } = fakeDb({ "FROM installs WHERE platform = ?": 7, "FROM installs": 11, "FROM users": 4 });
    const r = await worker.fetch(req("/api/v1/admin/stats", await adminTok()), env(db));
    expect(r.status).toBe(200);
    const b = (await r.json()) as Record<string, any>;
    expect(b.installs.total).toBeGreaterThanOrEqual(0);
    expect(Object.keys(b.installs.byPlatform).sort()).toEqual(["android", "ios", "web"]);
    expect(b.users).toHaveProperty("total");
    expect(b).toHaveProperty("generatedAt");
    expect(b.installs).toHaveProperty("active7d");
    expect(b.installs).toHaveProperty("active30d");
    expect(b.installs).toHaveProperty("new7d");
  });
});

describe("POST /api/v1/installs (anonim o'rnatish hisoblagichi)", () => {
  const good = { installId: "6f1c2a9e-8b1d-4f6a-9d3e-0a1b2c3d4e5f", platform: "android", appVersion: "1.0.0" };
  it("to'g'ri so'rov: bazaga yoziladi, tokensiz ishlaydi", async () => {
    const { db, ran } = fakeDb();
    const r = await worker.fetch(req("/api/v1/installs", null, "POST", good), env(db));
    expect(r.status).toBe(200);
    expect(ran.some((s) => /installs/.test(s.sql) && s.args.includes(good.installId))).toBe(true);
  });
  it("noto'g'ri platforma: 400 va yozilmaydi", async () => {
    const { db, ran } = fakeDb();
    const r = await worker.fetch(req("/api/v1/installs", null, "POST", { ...good, platform: "windows" }), env(db));
    expect(r.status).toBe(400);
    expect(ran).toHaveLength(0);
  });
  it("noto'g'ri yoki juda uzun installId: 400", async () => {
    const { db, ran } = fakeDb();
    for (const installId of ["", "x", "a b c d e f g h", "z".repeat(200), "<script>alert(1)</script>-----"]) {
      expect((await worker.fetch(req("/api/v1/installs", null, "POST", { ...good, installId }), env(db))).status).toBe(400);
    }
    expect(ran).toHaveLength(0);
  });
  it("buzuq JSON: 400; GET: 405", async () => {
    const { db } = fakeDb();
    const bad = new Request("https://api.test/api/v1/installs", { method: "POST", body: "{not json", headers: { "content-type": "application/json" } });
    expect((await worker.fetch(bad, env(db))).status).toBe(400);
    expect((await worker.fetch(req("/api/v1/installs", null, "GET"), env(db))).status).toBe(405);
  });
  it("appVersion noto'g'ri bo'lsa 'unknown' sifatida yoziladi (xato emas)", async () => {
    const { db, ran } = fakeDb();
    const r = await worker.fetch(req("/api/v1/installs", null, "POST", { ...good, appVersion: "<b>x</b>".repeat(20) }), env(db));
    expect(r.status).toBe(200);
    expect(ran.some((s) => s.args.includes("unknown"))).toBe(true);
  });
  it("baza yo'q (DB sozlanmagan): 500 server_misconfigured", async () => {
    const r = await worker.fetch(req("/api/v1/installs", null, "POST", good), { FIREBASE_PROJECT_ID: PROJECT } as never);
    expect(r.status).toBe(500);
  });
});

describe("Admin Pro beradi: /api/v1/admin/grants", () => {
  const post = async (body: unknown, tok: string | null, db = fakeDb().db) =>
    worker.fetch(req("/api/v1/admin/grants", tok, "POST", body), env(db));

  it("tokensiz 401, admin bo'lmagan 403 va bazaga yozilmaydi", async () => {
    stub();
    const { db, ran } = fakeDb();
    expect((await post({ email: "a@b.co" }, null, db)).status).toBe(401);
    const t = await token({ email: "x@gmail.com", email_verified: true });
    expect((await post({ email: "a@b.co" }, t, db)).status).toBe(403);
    expect(ran).toHaveLength(0);
  });
  it("admin emailga Pro beradi (kichik harfga keltirib, muddat bilan)", async () => {
    stub();
    const { db, ran } = fakeDb();
    const r = await post({ email: "  Friend@Gmail.COM ", days: 30 }, await adminTok(), db);
    expect(r.status).toBe(200);
    expect(await r.json()).toMatchObject({ ok: true, email: "friend@gmail.com" });
    const w = ran.find((s) => /promo_grants/.test(s.sql));
    expect(w?.args[0]).toBe("friend@gmail.com");
    expect(w?.args[1]).toEqual(expect.stringMatching(/^\d{4}-\d\d-\d\d \d\d:\d\d:\d\d$/));
  });
  it("days berilmasa: cheksiz (ends_at = NULL)", async () => {
    stub();
    const { db, ran } = fakeDb();
    expect((await post({ email: "a@b.co" }, await adminTok(), db)).status).toBe(200);
    expect(ran.find((s) => /promo_grants/.test(s.sql))?.args[1]).toBeNull();
  });
  it("noto'g'ri email yoki days: 400", async () => {
    stub();
    const { db, ran } = fakeDb();
    const t = await adminTok();
    for (const b of [{}, { email: "" }, { email: "no-at-sign" }, { email: "a@b" }, { email: "a b@c.co" }, { email: "x".repeat(260) + "@a.co" },
      { email: "a@b.co", days: 0 }, { email: "a@b.co", days: -5 }, { email: "a@b.co", days: 99999 }, { email: "a@b.co", days: "30" }]) {
      expect((await post(b, t, db)).status, JSON.stringify(b).slice(0, 40)).toBe(400);
    }
    expect(ran).toHaveLength(0);
  });
  it("Prodan olib tashlash: DELETE", async () => {
    stub();
    const { db, ran } = fakeDb();
    const r = await worker.fetch(req("/api/v1/admin/grants", await adminTok(), "DELETE", { email: "Friend@Gmail.com" }), env(db));
    expect(r.status).toBe(200);
    expect(ran.find((s) => /DELETE FROM promo_grants/.test(s.sql))?.args[0]).toBe("friend@gmail.com");
  });
  it("Ro'yxat: GET faqat admin uchun", async () => {
    stub();
    const { db } = fakeDb();
    expect((await worker.fetch(req("/api/v1/admin/grants", null), env(db))).status).toBe(401);
    const r = await worker.fetch(req("/api/v1/admin/grants", await adminTok()), env(db));
    expect(r.status).toBe(200);
    expect(await r.json()).toHaveProperty("grants");
  });
  it("berilgan emailli foydalanuvchi (email tasdiqlangan) kirganda Pro bo'ladi", async () => {
    stub();
    const { db } = fakeDb({}, 0, 1);
    const t = await token({ email: "friend@gmail.com", email_verified: true });
    expect(await (await worker.fetch(req("/api/v1/me", t), env(db))).json()).toMatchObject({ isAdmin: false, pro: true });
  });
  it("email TASDIQLANMAGAN bo'lsa grant ishlamaydi (boshqa emailni da'vo qilib bo'lmaydi)", async () => {
    stub();
    const { db } = fakeDb({}, 0, 1);
    const t = await token({ email: "friend@gmail.com", email_verified: false });
    expect(await (await worker.fetch(req("/api/v1/me", t), env(db))).json()).toMatchObject({ pro: false });
  });
  it("hisobni o'chirishda email bo'yicha grant ham o'chadi (shaxsiy ma'lumot)", async () => {
    stub();
    const stmts: { sql: string; args: unknown[] }[] = [];
    const db = { prepare: (sql: string) => ({ bind: (...args: unknown[]) => ({ sql, args }) }), batch: async (l: typeof stmts) => { stmts.push(...l); return []; } };
    const t = await token({ email: "Friend@Gmail.com", email_verified: true });
    const r = await worker.fetch(req("/api/v1/me", t, "DELETE"), env(db));
    expect(r.status).toBe(200);
    expect(stmts.find((s) => /promo_grants/.test(s.sql))?.args[0]).toBe("friend@gmail.com");
  });
});
