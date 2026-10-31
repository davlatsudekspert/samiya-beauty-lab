import { beforeAll, describe, expect, it, vi } from "vitest";
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

async function token(sub = "uid-9") {
  const now = Math.floor(Date.now() / 1000);
  const body = `${jb({ alg: "RS256", kid: "k1" })}.${jb({
    iss: `https://securetoken.google.com/${PROJECT}`, aud: PROJECT, sub, iat: now - 5, exp: now + 3000, auth_time: now - 5,
  })}`;
  return `${body}.${b64u(await crypto.subtle.sign("RSASSA-PKCS1-v1_5", priv, enc.encode(body)))}`;
}

function fakeDb() {
  const stmts: { sql: string; args: unknown[] }[] = [];
  let batches = 0;
  const db = {
    prepare: (sql: string) => ({ bind: (...args: unknown[]) => ({ sql, args }) }),
    batch: async (list: { sql: string; args: unknown[] }[]) => { batches++; stmts.push(...list); return []; },
  };
  return { stmts, db, batches: () => batches };
}

const call = (tok: string | null, env: Record<string, unknown>, method = "DELETE") =>
  worker.fetch(new Request("https://api.test/api/v1/me", { method, headers: tok ? { authorization: `Bearer ${tok}` } : {} }), env as never);

describe("DELETE /api/v1/me (hisobni o'chirish)", () => {
  const stub = () => {
    resetJwksCache();
    vi.stubGlobal("fetch", async () => new Response(JSON.stringify({ keys: [jwk] }), { headers: { "cache-control": "max-age=60" } }));
  };

  it("tokensiz yoki noto'g'ri token: 401 va bazaga TEGILMAYDI", async () => {
    stub();
    const { db, stmts } = fakeDb();
    for (const t of [null, "garbage"]) {
      expect((await call(t, { FIREBASE_PROJECT_ID: PROJECT, DB: db })).status).toBe(401);
    }
    expect(stmts).toHaveLength(0);
  });

  it("faqat TOKENDAGI foydalanuvchining qatorlari bitta batch'da, bog'liqlar avval o'chiriladi", async () => {
    stub();
    const { db, stmts, batches } = fakeDb();
    const r = await call(await token("uid-9"), { FIREBASE_PROJECT_ID: PROJECT, DB: db });
    expect(r.status).toBe(200);
    expect(await r.json()).toEqual({ deleted: true });
    expect(batches()).toBe(1);
    expect(stmts.map((s) => s.sql.replace(/\s+/g, " ").trim().toLowerCase())).toEqual([
      "delete from entitlements where user_id = ?",
      "delete from ai_daily_usage where user_id = ?",
      "delete from ai_request_idempotency where user_id = ?",
      "delete from users where id = ?",
    ]);
    expect(stmts.every((s) => s.args.length === 1 && s.args[0] === "uid-9")).toBe(true);
  });

  it("baza ulanmagan bo'lsa 500 server_misconfigured (muvaffaqiyat soxtalashtirilmaydi)", async () => {
    stub();
    const r = await call(await token(), { FIREBASE_PROJECT_ID: PROJECT });
    expect(r.status).toBe(500);
    expect(await r.json()).toEqual({ error: "server_misconfigured" });
  });

  it("baza xatosi 500 delete_failed qaytaradi, 'deleted: true' emas", async () => {
    stub();
    const db = { prepare: () => ({ bind: () => ({}) }), batch: async () => { throw new Error("d1 down"); } };
    const r = await call(await token(), { FIREBASE_PROJECT_ID: PROJECT, DB: db });
    expect(r.status).toBe(500);
    expect(await r.json()).toEqual({ error: "delete_failed" });
  });

  it("POST 405", async () => {
    expect((await call(null, { FIREBASE_PROJECT_ID: PROJECT }, "POST")).status).toBe(405);
  });
});
