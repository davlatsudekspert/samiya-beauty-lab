/** RevenueCat webhook: obuna holatini entitlements jadvaliga yozadi. Pro FAQAT shu orqali (klient yozolmaydi). */

export type RcEvent = {
  type?: string;
  app_user_id?: string;
  original_app_user_id?: string;
  product_id?: string;
  expiration_at_ms?: number | null;
  transaction_id?: string;
  original_transaction_id?: string;
};

/** Obunani faol qiladigan / muddatini uzaytiradigan voqealar. */
const ACTIVE = new Set(["INITIAL_PURCHASE", "RENEWAL", "PRODUCT_CHANGE", "UNCANCELLATION", "NON_RENEWING_PURCHASE", "SUBSCRIPTION_EXTENDED"]);
/** Muddat tugashi: ends_at = expiration (yoki hozir). CANCELLATION muddat oxirigacha Pro'ni saqlaydi. */
const END = new Set(["EXPIRATION", "CANCELLATION", "BILLING_ISSUE"]);

const UID = /^[A-Za-z0-9_-]{6,128}$/;

export function sqlTime(ms: number): string {
  return new Date(ms).toISOString().slice(0, 19).replace("T", " ");
}

/** Webhook'ni qayta ishlash rejasi (sof funksiya): null = e'tiborsiz qoldiriladi. */
export function planEvent(e: RcEvent, nowMs: number): { uid: string; product: string; endsAt: string | null; txn: string | null } | null {
  const uid = e.app_user_id ?? "";
  if (!UID.test(uid) || uid.startsWith("$RCAnonymousID")) return null;
  const product = (e.product_id ?? "pro").slice(0, 120);
  const txn = (e.original_transaction_id ?? e.transaction_id ?? null)?.slice(0, 120) ?? null;
  const exp = typeof e.expiration_at_ms === "number" ? e.expiration_at_ms : null;
  if (ACTIVE.has(e.type ?? "")) return { uid, product, endsAt: exp === null ? null : sqlTime(exp), txn };
  if (END.has(e.type ?? "")) {
    const end = e.type === "CANCELLATION" && exp !== null ? exp : e.type === "BILLING_ISSUE" && exp !== null ? exp : nowMs;
    return { uid, product, endsAt: sqlTime(Math.min(end, exp ?? end)), txn };
  }
  return null;
}

/** Doimiy vaqtli taqqoslash (sirni sizdirmaslik uchun). */
export function safeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let d = 0;
  for (let i = 0; i < a.length; i++) d |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return d === 0;
}
