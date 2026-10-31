import { describe, expect, it } from "vitest";
import {
  aiLimit,
  allowed,
  canCharge,
  daysRemaining,
  parseConfig,
  phase,
  type CampaignConfig,
} from "../src/campaign";

const DAY = 86_400_000;
// Toshkent (UTC+5, DST yo'q) 2026-12-01 00:00 = UTC 2026-11-30 19:00
const START = new Date("2026-11-30T19:00:00Z");
const cfg = (over: Partial<CampaignConfig> = {}): CampaignConfig => ({
  officialLaunchDate: "2026-12-01",
  days: 90,
  freeDailyAi: 5,
  proDailyAi: 50,
  adsEnabled: false,
  billingEnabled: false,
  ...over,
});

describe("campaign phase", () => {
  it("launch sanasi yo'q bo'lsa prelaunch, daysRemaining null", () => {
    const c = cfg({ officialLaunchDate: null });
    expect(phase(c, START)).toBe("prelaunch");
    expect(daysRemaining(c, START)).toBeNull();
  });
  it("launchdan oldin prelaunch", () => {
    expect(phase(cfg(), new Date(START.getTime() - 1))).toBe("prelaunch");
  });
  it("90 kun: chegaralar", () => {
    expect(phase(cfg(), START)).toBe("free_campaign");
    expect(daysRemaining(cfg(), START)).toBe(90);
    expect(daysRemaining(cfg(), new Date(START.getTime() + 89 * DAY))).toBe(1);
    expect(phase(cfg(), new Date(START.getTime() + 90 * DAY - 1))).toBe("free_campaign");
    expect(phase(cfg(), new Date(START.getTime() + 90 * DAY))).toBe("free_plus_optional_pro");
    expect(daysRemaining(cfg(), new Date(START.getTime() + 90 * DAY))).toBe(0);
  });
});

describe("entitlements", () => {
  it("bepul yadro doim ochiq, bonus faqat kampaniyada, Pro doim", () => {
    const after = new Date(START.getTime() + 91 * DAY);
    expect(allowed(cfg(), "academy_pro", START, false)).toBe(true);
    expect(allowed(cfg(), "academy_pro", after, false)).toBe(false);
    expect(allowed(cfg(), "academy_pro", after, true)).toBe(true);
    expect(allowed(cfg(), "ingredient_catalog", after, false)).toBe(true);
  });
  it("AI limiti Free 5, Pro 50", () => {
    expect(aiLimit(cfg(), false)).toBe(5);
    expect(aiLimit(cfg(), true)).toBe(50);
  });
  it("avtomatik to'lov yo'q: billing yoqilgan va foydalanuvchi tasdiqlagan bo'lsagina", () => {
    expect(canCharge(cfg(), true)).toBe(false);
    expect(canCharge(cfg({ billingEnabled: true }), false)).toBe(false);
    expect(canCharge(cfg({ billingEnabled: true }), true)).toBe(true);
  });
});

describe("parseConfig (env -> CampaignConfig)", () => {
  it("bo'sh env: prelaunch, billing va reklama o'chiq, standart limitlar", () => {
    expect(parseConfig({})).toEqual({
      officialLaunchDate: null, days: 90, freeDailyAi: 5, proDailyAi: 50,
      adsEnabled: false, billingEnabled: false,
    });
  });
  it("noto'g'ri sana yoki xavfli limitlarni rad etadi", () => {
    expect(() => parseConfig({ PUBLIC_LAUNCH_DATE: "2026-13-40" })).toThrow();
    expect(() => parseConfig({ PUBLIC_LAUNCH_DATE: "01.12.2026" })).toThrow();
    expect(() => parseConfig({ CAMPAIGN_DURATION_DAYS: "0" })).toThrow();
    expect(() => parseConfig({ AI_FREE_DAILY_REQUESTS: "1000" })).toThrow();
  });
  it("to'g'ri qiymatlarni o'qiydi", () => {
    const c = parseConfig({ PUBLIC_LAUNCH_DATE: "2026-12-01", BILLING_ENABLED: "true", AI_PRO_DAILY_REQUESTS: "60" });
    expect(c.officialLaunchDate).toBe("2026-12-01");
    expect(c.billingEnabled).toBe(true);
    expect(c.proDailyAi).toBe(60);
  });
});
