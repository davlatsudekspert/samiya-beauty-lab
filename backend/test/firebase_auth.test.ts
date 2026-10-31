import { beforeAll, describe, expect, it, vi } from "vitest";
import { AuthError, getFirebaseJwks, resetJwksCache, verifyFirebaseIdToken, type Jwk } from "../src/firebase_auth";
import worker from "../src/index";

const PROJECT = "samiya-beauty-lab";
const enc = new TextEncoder();
const b64u = (b: ArrayBuffer | Uint8Array) =>
  btoa(String.fromCharCode(...new Uint8Array(b as ArrayBuffer))).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
const jsonB64u = (o: unknown) => b64u(enc.encode(JSON.stringify(o)));

let jwk: Jwk;
let otherJwk: Jwk;
let privateKey: CryptoKey;
let otherPrivate: CryptoKey;

async function keypair(kid: string) {
  const kp = await crypto.subtle.generateKey(
    { name: "RSASSA-PKCS1-v1_5", modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]), hash: "SHA-256" },
    true, ["sign", "verify"]) as CryptoKeyPair;
  const pub = (await crypto.subtle.exportKey("jwk", kp.publicKey)) as Jwk;
  return { pub: { ...pub, kid, alg: "RS256", use: "sig" } as Jwk, priv: kp.privateKey };
}

const NOW = 1_800_000_000;
async function sign(payload: Record<string, unknown>, opts: { kid?: string; alg?: string; key?: CryptoKey } = {}) {
  const header = { alg: opts.alg ?? "RS256", kid: opts.kid ?? "k1", typ: "JWT" };
  const body = `${jsonB64u(header)}.${jsonB64u(payload)}`;
  const sig = await crypto.subtle.sign("RSASSA-PKCS1-v1_5", opts.key ?? privateKey, enc.encode(body));
  return `${body}.${b64u(sig)}`;
}
const goodPayload = (over: Record<string, unknown> = {}) => ({
  iss: `https://securetoken.google.com/${PROJECT}`, aud: PROJECT, sub: "uid-123",
  iat: NOW - 60, exp: NOW + 3000, auth_time: NOW - 120,
  email: "a@b.co", firebase: { sign_in_provider: "apple.com" }, ...over,
});

beforeAll(async () => {
  const a = await keypair("k1"); jwk = a.pub; privateKey = a.priv;
  const b = await keypair("k2"); otherJwk = b.pub; otherPrivate = b.priv;
});

const verify = (t: string) => verifyFirebaseIdToken(t, { projectId: PROJECT, jwks: [jwk], nowSec: NOW });
const rejects = async (t: string, code: string) => {
  const err = await verify(t).then(() => null, (e) => e);
  expect(err).toBeInstanceOf(AuthError);
  expect((err as AuthError).code).toBe(code);
};

describe("verifyFirebaseIdToken", () => {
  it("to'g'ri token: uid, email va provayderni qaytaradi", async () => {
    const v = await verify(await sign(goodPayload()));
    expect(v).toMatchObject({ uid: "uid-123", email: "a@b.co", provider: "apple.com" });
  });
  it("muddati o'tgan token rad etiladi", async () => rejects(await sign(goodPayload({ exp: NOW - 100 })), "expired"));
  it("kelajakda berilgan token (iat) rad etiladi", async () => rejects(await sign(goodPayload({ iat: NOW + 5000 })), "iat_future"));
  it("boshqa loyiha (aud) rad etiladi", async () => rejects(await sign(goodPayload({ aud: "other-project" })), "bad_audience"));
  it("boshqa emitent (iss) rad etiladi", async () => rejects(await sign(goodPayload({ iss: "https://evil.example" })), "bad_issuer"));
  it("sub bo'sh yoki juda uzun bo'lsa rad etiladi", async () => {
    await rejects(await sign(goodPayload({ sub: "" })), "bad_sub");
    await rejects(await sign(goodPayload({ sub: "x".repeat(200) })), "bad_sub");
  });
  it("alg=none va HS256 hujumlari rad etiladi", async () => {
    await rejects(await sign(goodPayload(), { alg: "none" }), "bad_alg");
    await rejects(await sign(goodPayload(), { alg: "HS256" }), "bad_alg");
  });
  it("noma'lum kid rad etiladi", async () => rejects(await sign(goodPayload(), { kid: "zzz" }), "unknown_key"));
  it("boshqa kalit bilan imzolangan token rad etiladi (kid soxtalashtirilgan)", async () =>
    rejects(await sign(goodPayload(), { key: otherPrivate }), "bad_signature"));
  it("payload o'zgartirilgan token rad etiladi", async () => {
    const [h, , s] = (await sign(goodPayload())).split(".");
    await rejects(`${h}.${jsonB64u(goodPayload({ sub: "attacker" }))}.${s}`, "bad_signature");
  });
  it("buzilgan tuzilma rad etiladi", async () => {
    await rejects("abc", "malformed");
    await rejects("a.b.c", "malformed");
    await rejects("", "malformed");
  });
});

describe("getFirebaseJwks", () => {
  it("Google'dan kalitlarni oladi va keshlaydi", async () => {
    resetJwksCache();
    const f = vi.fn(async () => new Response(JSON.stringify({ keys: [jwk, otherJwk] }), { headers: { "cache-control": "public, max-age=3600" } }));
    expect((await getFirebaseJwks(f as never)).map((k) => k.kid)).toEqual(["k1", "k2"]);
    await getFirebaseJwks(f as never);
    expect(f).toHaveBeenCalledTimes(1);
  });
  it("Google javob bermasa xato (503 uchun)", async () => {
    resetJwksCache();
    await expect(getFirebaseJwks((async () => new Response("no", { status: 500 })) as never)).rejects.toThrow();
  });
});

describe("GET /api/v1/me", () => {
  const stubJwks = () => {
    resetJwksCache();
    vi.stubGlobal("fetch", async () => new Response(JSON.stringify({ keys: [jwk] }), { headers: { "cache-control": "max-age=60" } }));
  };
  const fakeDb = () => {
    const calls: unknown[][] = [];
    return { calls, db: { prepare: (sql: string) => ({ bind: (...a: unknown[]) => ({ run: async () => { calls.push([sql, ...a]); return {}; }, first: async () => ({ n: 0 }) }) }) } };
  };
  const call = (token: string | null, env: Record<string, unknown>) =>
    worker.fetch(new Request("https://api.test/api/v1/me", { headers: token ? { authorization: `Bearer ${token}` } : {} }), env as never);

  it("tokensiz va noto'g'ri token 401, sababi oshkor qilinmaydi", async () => {
    stubJwks();
    const env = { FIREBASE_PROJECT_ID: PROJECT };
    for (const t of [null, "garbage", await sign(goodPayload({ exp: 1 }))]) {
      const r = await call(t, env);
      expect(r.status).toBe(401);
      expect(await r.json()).toEqual({ error: "unauthorized" });
    }
  });
  it("to'g'ri token: uid qaytadi va foydalanuvchi bazaga bir marta yoziladi (INSERT OR IGNORE)", async () => {
    stubJwks(); vi.setSystemTime(new Date(NOW * 1000));
    const { calls, db } = fakeDb();
    const r = await call(await sign(goodPayload()), { FIREBASE_PROJECT_ID: PROJECT, DB: db });
    vi.useRealTimers();
    expect(r.status).toBe(200);
    expect(await r.json()).toEqual({ uid: "uid-123", provider: "apple.com", isAdmin: false, pro: false });
    expect(calls).toHaveLength(1);
    expect(String(calls[0][0])).toMatch(/INSERT OR IGNORE INTO users/i);
    expect(calls[0][1]).toBe("uid-123");
  });
  it("FIREBASE_PROJECT_ID yo'q bo'lsa 500 server_misconfigured", async () => {
    stubJwks();
    const r = await call("x", {});
    expect(r.status).toBe(500);
    expect(await r.json()).toEqual({ error: "server_misconfigured" });
  });
  it("POST 405", async () => {
    const r = await worker.fetch(new Request("https://api.test/api/v1/me", { method: "POST" }), { FIREBASE_PROJECT_ID: PROJECT } as never);
    expect(r.status).toBe(405);
  });
});
