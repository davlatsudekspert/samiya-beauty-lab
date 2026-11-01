// @ts-ignore
import { readFileSync, readdirSync } from "node:fs";
// @ts-ignore
import { DatabaseSync } from "node:sqlite";
import { describe, expect, it } from "vitest";
import worker from "../src/index";
import { planEvent, safeEqual } from "../src/revenuecat";

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
const env = (db: unknown, extra: Record<string, unknown> = {}) => ({ DB: db, REVENUECAT_WEBHOOK_SECRET: "s3cret-value", ...extra }) as never;
const hook = (event: unknown, auth = "Bearer s3cret-value") =>
  new Request("https://api.test/api/v1/webhooks/revenuecat", { method: "POST", headers: { authorization: auth, "content-type": "application/json" }, body: JSON.stringify({ event }) });
const future = Date.now() + 30 * 86_400_000;

describe("RevenueCat webhook", () => {
  it("noto'g'ri sir: 401; sir sozlanmagan: 503", async () => {
    expect((await worker.fetch(hook({}, "Bearer wrong"), env(d1()))).status).toBe(401);
    expect((await worker.fetch(hook({}), env(d1(), { REVENUECAT_WEBHOOK_SECRET: undefined }))).status).toBe(503);
  });
  it("INITIAL_PURCHASE -> faol entitlement; EXPIRATION -> tugaydi", async () => {
    const db = d1();
    const ev = { type: "INITIAL_PURCHASE", app_user_id: "firebase-uid-1", product_id: "samiya_pro_yearly", expiration_at_ms: future, original_transaction_id: "t1" };
    expect((await worker.fetch(hook(ev), env(db))).status).toBe(200);
    const active = () => db.raw.prepare("SELECT COUNT(*) AS n FROM entitlements WHERE user_id='firebase-uid-1' AND (ends_at IS NULL OR ends_at > datetime('now'))").get();
    expect(active()).toEqual({ n: 1 });
    await worker.fetch(hook({ ...ev, type: "EXPIRATION", expiration_at_ms: Date.now() - 1000 }), env(db));
    expect(active()).toEqual({ n: 0 });
  });
  it("CANCELLATION muddat oxirigacha Pro'ni saqlaydi; anonim ID e'tiborsiz", () => {
    const p = planEvent({ type: "CANCELLATION", app_user_id: "uid-123456", expiration_at_ms: future }, Date.now());
    expect(p!.endsAt! > new Date().toISOString().slice(0, 10)).toBe(true);
    expect(planEvent({ type: "INITIAL_PURCHASE", app_user_id: "$RCAnonymousID:abc" }, Date.now())).toBeNull();
    expect(planEvent({ type: "TEST", app_user_id: "uid-123456" }, Date.now())).toBeNull();
  });
  it("safeEqual", () => {
    expect(safeEqual("abc", "abc")).toBe(true);
    expect(safeEqual("abc", "abd")).toBe(false);
    expect(safeEqual("abc", "ab")).toBe(false);
  });
});
