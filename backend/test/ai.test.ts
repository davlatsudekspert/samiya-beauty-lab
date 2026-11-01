// node:sqlite va node:fs faqat testda (Worker tiplari ichida node tiplari yo'q).
// @ts-ignore
import { readFileSync, readdirSync } from "node:fs";
// @ts-ignore
import { DatabaseSync } from "node:sqlite";
import { beforeAll, describe, expect, it, vi } from "vitest";
import { parseAiRequest, systemPrompt, tashkentDay } from "../src/ai";
import { resetJwksCache, type Jwk } from "../src/firebase_auth";
import worker from "../src/index";

const PROJECT = "samiya-beauty-lab";
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

async function token(sub = "uid-1") {
  const now = Math.floor(Date.now() / 1000);
  const body = `${jb({ alg: "RS256", kid: "k1" })}.${jb({
    iss: `https://securetoken.google.com/${PROJECT}`, aud: PROJECT, sub, iat: now - 5, exp: now + 3000, auth_time: now - 5,
  })}`;
  return `${body}.${b64u(await crypto.subtle.sign("RSASSA-PKCS1-v1_5", priv, enc.encode(body)))}`;
}

/** node:sqlite ustida kichik D1 o'xshatmasi: haqiqiy SQL semantikasi (upsert WHERE ham). */
function d1() {
  const s = new DatabaseSync(":memory:");
  for (const f of readdirSync("migrations").sort()) s.exec(readFileSync(`migrations/${f}`, "utf8"));
  const stmt = (sql: string, args: unknown[] = []) => ({
    run: async () => ({ meta: { changes: Number(s.prepare(sql).run(...(args as never[])).changes) } }),
    first: async () => s.prepare(sql).get(...(args as never[])) ?? null,
    all: async () => ({ results: s.prepare(sql).all(...(args as never[])) }),
  });
  return {
    raw: s,
    prepare: (sql: string) => ({ ...stmt(sql), bind: (...args: unknown[]) => stmt(sql, args) }),
    batch: async (l: { run: () => Promise<unknown> }[]) => { for (const x of l) await x.run(); return []; },
  };
}

let geminiCalls: { url: string; body: any; key: string | null }[] = [];
function stub(gemini: () => Response = () => new Response(JSON.stringify({ candidates: [{ content: { parts: [{ text: "Javob" }] } }] }))) {
  resetJwksCache();
  geminiCalls = [];
  vi.stubGlobal("fetch", async (url: string, init?: RequestInit) => {
    if (String(url).includes("generativelanguage.googleapis.com")) {
      geminiCalls.push({ url: String(url), body: JSON.parse(String(init?.body)), key: new Headers(init?.headers).get("x-goog-api-key") });
      return gemini();
    }
    return new Response(JSON.stringify({ keys: [jwk] }), { headers: { "cache-control": "max-age=60" } });
  });
}

const env = (db: unknown, extra: Record<string, unknown> = {}) =>
  ({ DB: db, FIREBASE_PROJECT_ID: PROJECT, GEMINI_API_KEY: "test-key", AI_FREE_DAILY_REQUESTS: "2", ...extra }) as never;
const ask = async (body: unknown, tok?: string | null) =>
  new Request("https://api.test/api/v1/ai/ask", {
    method: "POST",
    headers: { ...(tok === null ? {} : { authorization: `Bearer ${tok ?? (await token())}` }), "content-type": "application/json" },
    body: JSON.stringify(body),
  });
const q = (id: string, extra: Record<string, unknown> = {}) => ({ requestId: `req-${id}-0000`, question: "Niatsinamid nima?", lang: "uz", ...extra });

describe("SAMIYA AI (POST /api/v1/ai/ask)", () => {
  it("kirmagan foydalanuvchi: 401", async () => {
    stub();
    expect((await worker.fetch(await ask(q("a"), null), env(d1()))).status).toBe(401);
  });
  it("kalit sozlanmagan: 503 ai_not_configured (Gemini chaqirilmaydi)", async () => {
    stub();
    const r = await worker.fetch(await ask(q("a")), env(d1(), { GEMINI_API_KEY: undefined }));
    expect(r.status).toBe(503);
    expect(await r.json()).toEqual({ error: "ai_not_configured" });
    expect(geminiCalls).toHaveLength(0);
  });
  it("javob qaytaradi; kalit faqat sarlavhada, tizim ko'rsatmasi tanlangan tilda", async () => {
    stub();
    const r = await worker.fetch(await ask(q("a", { context: "Niacinamide: ..." })), env(d1()));
    expect(r.status).toBe(200);
    expect(await r.json()).toMatchObject({ answer: "Javob", remaining: 1, limit: 2, pro: false });
    expect(geminiCalls[0].key).toBe("test-key");
    expect(geminiCalls[0].url).not.toContain("test-key");
    expect(geminiCalls[0].body.systemInstruction.parts[0].text).toContain("Uzbek");
    expect(geminiCalls[0].body.contents.at(-1).parts[0].text).toContain("APP CONTEXT");
  });
  it("kunlik limit: 3-so'rov 429, bir xil requestId qayta yuborilsa kvota sarflanmaydi", async () => {
    stub();
    const db = d1();
    expect((await worker.fetch(await ask(q("a")), env(db))).status).toBe(200);
    expect((await worker.fetch(await ask(q("a")), env(db))).status).toBe(200); // qayta urinish
    expect((await worker.fetch(await ask(q("b")), env(db))).status).toBe(200);
    const r = await worker.fetch(await ask(q("c")), env(db));
    expect(r.status).toBe(429);
    expect(await r.json()).toMatchObject({ error: "quota_exceeded", limit: 2 });
    expect(db.raw.prepare("SELECT count FROM ai_daily_usage").get()).toEqual({ count: 2 });
  });
  it("Gemini xatosi: 502 va kvota qaytariladi", async () => {
    stub(() => new Response("x", { status: 500 }));
    const db = d1();
    expect((await worker.fetch(await ask(q("a")), env(db))).status).toBe(502);
    expect(db.raw.prepare("SELECT count FROM ai_daily_usage").get()).toEqual({ count: 0 });
    expect(db.raw.prepare("SELECT COUNT(*) AS n FROM ai_request_idempotency").get()).toEqual({ n: 0 });
  });
  it("noto'g'ri so'rov: 400", async () => {
    stub();
    expect((await worker.fetch(await ask({ requestId: "x", question: "salom" }), env(d1()))).status).toBe(400);
    expect((await worker.fetch(await ask(q("a", { question: "a".repeat(900) })), env(d1()))).status).toBe(400);
  });
  it("GET: 405", async () => {
    expect((await worker.fetch(new Request("https://api.test/api/v1/ai/ask"), env(d1()))).status).toBe(405);
  });
});

describe("ai yordamchilari", () => {
  it("parseAiRequest: noma'lum til -> en, tarix 6 ta bilan cheklanadi, kontekst kesiladi", () => {
    const r = parseAiRequest(JSON.stringify({
      requestId: "abcdefgh1", question: "  Retinol?  ", lang: "xx", context: "c".repeat(9000),
      history: Array.from({ length: 10 }, (_, i) => ({ role: i % 2 ? "model" : "user", text: `t${i}` })).concat([{ role: "system", text: "x" } as never]),
    }))!;
    expect(r.lang).toBe("en");
    expect(r.question).toBe("Retinol?");
    expect(r.context.length).toBe(6000);
    expect(r.history.length).toBeLessThanOrEqual(6);
    expect(r.history.every((h) => h.role === "user" || h.role === "model")).toBe(true);
  });
  it("tizim ko'rsatmasi: tashxis yo'q, soxta manba yo'q", () => {
    const p = systemPrompt("ar");
    expect(p).toContain("Arabic");
    expect(p).toMatch(/Never diagnose/);
    expect(p).toMatch(/Never invent studies/);
  });
  it("Toshkent kuni UTC+5", () => {
    expect(tashkentDay(new Date("2026-11-01T19:30:00Z"))).toBe("2026-11-02");
    expect(tashkentDay(new Date("2026-11-01T18:59:00Z"))).toBe("2026-11-01");
  });
});
