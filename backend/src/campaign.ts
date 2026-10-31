// 90 kunlik global kampaniya va funksiya ruxsatlari. Sof funksiyalar, I/O yo'q.
// Manba: docs/PRODUCT_DECISIONS_90_DAYS.md. Vaqt chegaralari serverning soati bo'yicha;
// klientning soati yoki bayrog'iga hech qachon ishonilmaydi.

export type Phase = "prelaunch" | "free_campaign" | "free_plus_optional_pro";

export interface CampaignConfig {
  officialLaunchDate: string | null; // YYYY-MM-DD, Asia/Tashkent kuni
  days: number;
  freeDailyAi: number;
  proDailyAi: number;
  adsEnabled: boolean;
  billingEnabled: boolean;
}

export const FREE_CORE = new Set([
  "ingredient_catalog", "academy_basic", "routine", "journal", "scanner_basic", "ai_basic",
]);
export const CAMPAIGN_BONUS = new Set([
  "academy_pro", "advanced_analysis", "routine_export", "premium_lessons",
]);

const DAY_MS = 86_400_000;

function startOf(cfg: CampaignConfig): Date | null {
  // Toshkent UTC+5, yozgi vaqt yo'q, shuning uchun qat'iy ofset ishonchli.
  return cfg.officialLaunchDate ? new Date(`${cfg.officialLaunchDate}T00:00:00+05:00`) : null;
}

export function phase(cfg: CampaignConfig, now: Date): Phase {
  const start = startOf(cfg);
  if (!start || now < start) return "prelaunch";
  return now.getTime() < start.getTime() + cfg.days * DAY_MS ? "free_campaign" : "free_plus_optional_pro";
}

export function daysRemaining(cfg: CampaignConfig, now: Date): number | null {
  const start = startOf(cfg);
  if (!start) return null;
  if (now < start) return cfg.days;
  const left = start.getTime() + cfg.days * DAY_MS - now.getTime();
  return Math.max(0, Math.ceil(left / DAY_MS));
}

export function allowed(cfg: CampaignConfig, feature: string, now: Date, verifiedPro: boolean): boolean {
  if (FREE_CORE.has(feature)) return true;
  if (CAMPAIGN_BONUS.has(feature) && phase(cfg, now) === "free_campaign") return true;
  return verifiedPro;
}

export const aiLimit = (cfg: CampaignConfig, verifiedPro: boolean): number =>
  verifiedPro ? cfg.proDailyAi : cfg.freeDailyAi;

// Yashirin obuna yoki avtomatik konversiya yo'q: faqat billing yoqilgan VA foydalanuvchi aniq tasdiqlagan.
export const canCharge = (cfg: CampaignConfig, explicitlyConfirmed: boolean): boolean =>
  cfg.billingEnabled && explicitlyConfirmed;

function int(raw: string | undefined, def: number, min: number, max: number, name: string): number {
  if (raw === undefined || raw === "") return def;
  const n = Number(raw);
  if (!Number.isInteger(n) || n < min || n > max) throw new Error(`${name} must be an integer ${min}..${max}`);
  return n;
}

function launchDate(raw: string | undefined): string | null {
  if (raw === undefined || raw === "") return null;
  const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(raw);
  const d = m && new Date(Date.UTC(+m[1], +m[2] - 1, +m[3]));
  if (!m || !d || d.getUTCFullYear() !== +m[1] || d.getUTCMonth() !== +m[2] - 1 || d.getUTCDate() !== +m[3]) {
    throw new Error("PUBLIC_LAUNCH_DATE must be a real YYYY-MM-DD date");
  }
  return raw;
}

export interface CampaignEnv {
  PUBLIC_LAUNCH_DATE?: string;
  CAMPAIGN_DURATION_DAYS?: string;
  AI_FREE_DAILY_REQUESTS?: string;
  AI_PRO_DAILY_REQUESTS?: string;
  BILLING_ENABLED?: string;
  ADS_ENABLED?: string;
}

export function parseConfig(env: CampaignEnv): CampaignConfig {
  return {
    officialLaunchDate: launchDate(env.PUBLIC_LAUNCH_DATE),
    days: int(env.CAMPAIGN_DURATION_DAYS, 90, 1, 365, "CAMPAIGN_DURATION_DAYS"),
    freeDailyAi: int(env.AI_FREE_DAILY_REQUESTS, 5, 1, 100, "AI_FREE_DAILY_REQUESTS"),
    proDailyAi: int(env.AI_PRO_DAILY_REQUESTS, 50, 1, 500, "AI_PRO_DAILY_REQUESTS"),
    adsEnabled: env.ADS_ENABLED === "true",
    billingEnabled: env.BILLING_ENABLED === "true",
  };
}
