// Firebase ID tokenini Cloudflare Worker'da tekshirish (RS256, Google'ning ommaviy kalitlari bilan).
// Hujjat: https://firebase.google.com/docs/auth/admin/verify-id-tokens (qo'lda tekshirish talablari).

export interface Jwk {
  kid: string;
  kty: string;
  n: string;
  e: string;
  alg?: string;
  use?: string;
}

export interface VerifiedToken {
  uid: string;
  email?: string;
  emailVerified?: boolean;
  provider?: string;
  authTime: number;
  exp: number;
}

export class AuthError extends Error {
  constructor(public code: string) {
    super(code);
  }
}

const JWKS_URL = "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com";
const LEEWAY_SEC = 60;
const MAX_SUB = 128;

function b64uToBytes(s: string): Uint8Array {
  const pad = s.replace(/-/g, "+").replace(/_/g, "/").padEnd(Math.ceil(s.length / 4) * 4, "=");
  return Uint8Array.from(atob(pad), (c) => c.charCodeAt(0));
}

function parseJson(b64u: string): Record<string, unknown> {
  try {
    const v = JSON.parse(new TextDecoder().decode(b64uToBytes(b64u)));
    if (v === null || typeof v !== "object" || Array.isArray(v)) throw new Error();
    return v as Record<string, unknown>;
  } catch {
    throw new AuthError("malformed");
  }
}

export async function verifyFirebaseIdToken(
  token: string,
  opts: { projectId: string; jwks: Jwk[]; nowSec?: number },
): Promise<VerifiedToken> {
  const parts = token.split(".");
  if (parts.length !== 3 || parts.some((p) => p === "")) throw new AuthError("malformed");
  const [h, p, s] = parts;
  const header = parseJson(h);
  if (header.alg !== "RS256") throw new AuthError("bad_alg"); // none/HS256 hujumlariga qarshi
  const key = opts.jwks.find((k) => k.kid === header.kid);
  if (typeof header.kid !== "string" || !key) throw new AuthError("unknown_key");

  let ok = false;
  try {
    const cryptoKey = await crypto.subtle.importKey(
      "jwk",
      { kty: key.kty, n: key.n, e: key.e, alg: "RS256", ext: true },
      { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
      false,
      ["verify"],
    );
    ok = await crypto.subtle.verify("RSASSA-PKCS1-v1_5", cryptoKey, b64uToBytes(s), new TextEncoder().encode(`${h}.${p}`));
  } catch {
    throw new AuthError("bad_signature");
  }
  if (!ok) throw new AuthError("bad_signature");

  const c = parseJson(p);
  const now = opts.nowSec ?? Math.floor(Date.now() / 1000);
  const num = (v: unknown) => (typeof v === "number" ? v : NaN);
  if (!(num(c.exp) > now - LEEWAY_SEC)) throw new AuthError("expired");
  if (!(num(c.iat) <= now + LEEWAY_SEC)) throw new AuthError("iat_future");
  if (!(num(c.auth_time) <= now + LEEWAY_SEC)) throw new AuthError("iat_future");
  if (c.aud !== opts.projectId) throw new AuthError("bad_audience");
  if (c.iss !== `https://securetoken.google.com/${opts.projectId}`) throw new AuthError("bad_issuer");
  if (typeof c.sub !== "string" || c.sub.length === 0 || c.sub.length > MAX_SUB) throw new AuthError("bad_sub");

  const fb = c.firebase as { sign_in_provider?: unknown } | undefined;
  return {
    uid: c.sub,
    email: typeof c.email === "string" ? c.email : undefined,
    emailVerified: c.email_verified === true,
    provider: typeof fb?.sign_in_provider === "string" ? fb.sign_in_provider : undefined,
    authTime: num(c.auth_time),
    exp: num(c.exp),
  };
}

let cache: { keys: Jwk[]; expiresAt: number } | null = null;
export const resetJwksCache = () => {
  cache = null;
};

/** Google kalitlarini oladi va Cache-Control max-age bo'yicha (1 soatdan 24 soatgacha) xotirada saqlaydi. */
export async function getFirebaseJwks(fetchFn: typeof fetch = fetch): Promise<Jwk[]> {
  const now = Date.now();
  if (cache && cache.expiresAt > now) return cache.keys;
  const res = await fetchFn(JWKS_URL);
  if (!res.ok) throw new Error(`jwks_fetch_${res.status}`);
  const data = (await res.json()) as { keys?: Jwk[] };
  if (!Array.isArray(data.keys) || data.keys.length === 0) throw new Error("jwks_empty");
  const maxAge = Number(/max-age=(\d+)/.exec(res.headers.get("cache-control") ?? "")?.[1] ?? 3600);
  cache = { keys: data.keys, expiresAt: now + Math.min(Math.max(maxAge, 60), 86_400) * 1000 };
  return cache.keys;
}
