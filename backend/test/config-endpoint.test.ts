import { describe, expect, it } from "vitest";
import worker from "../src/index";

const call = (path: string, env: Record<string, string> = {}, method = "GET") =>
  worker.fetch(new Request(`https://api.test${path}`, { method }), env as never);

describe("GET /api/v1/config/public", () => {
  it("launchdan oldin: prelaunch, kartasiz, avto-to'lovsiz, billing o'chiq", async () => {
    const res = await call("/api/v1/config/public");
    expect(res.status).toBe(200);
    expect(res.headers.get("content-type")).toContain("application/json");
    expect(await res.json()).toEqual({
      campaign: {
        kind: "global_90_day_launch", phase: "prelaunch", officialLaunchDate: null,
        durationDays: 90, daysRemaining: null, requiresCard: false, autoCharge: false,
      },
      features: { billingEnabled: false, adsEnabled: false, sponsoredProductsEnabled: false },
      aiDailyLimitFree: 5,
    });
  });
  it("noto'g'ri sozlama 500 qaytaradi, ichki xato matnini oshkor qilmaydi", async () => {
    const res = await call("/api/v1/config/public", { PUBLIC_LAUNCH_DATE: "bad" });
    expect(res.status).toBe(500);
    expect(await res.json()).toEqual({ error: "server_misconfigured" });
  });
});

describe("routing", () => {
  it("/health 200", async () => {
    expect((await call("/health")).status).toBe(200);
  });
  it("noma'lum yo'l 404 JSON", async () => {
    const res = await call("/nope");
    expect(res.status).toBe(404);
    expect(await res.json()).toEqual({ error: "not_found" });
  });
  it("config faqat GET: POST 405", async () => {
    expect((await call("/api/v1/config/public", {}, "POST")).status).toBe(405);
  });
});
