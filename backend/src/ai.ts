/** SAMIYA AI: Gemini'ga server orqali murojaat. Kalit faqat Worker secret'da (GEMINI_API_KEY), klientga hech qachon berilmaydi. */

export const AI_LANGS = ["uz", "ru", "en", "ar"] as const;
export type AiLang = (typeof AI_LANGS)[number];
export const MAX_QUESTION = 800;
export const MAX_CONTEXT = 6000;
export const MAX_HISTORY = 6;

const LANG_NAME: Record<AiLang, string> = {
  uz: "Uzbek (Latin script)",
  ru: "Russian",
  en: "English",
  ar: "Modern Standard Arabic",
};

export function systemPrompt(lang: AiLang): string {
  return [
    "You are SAMIYA AI, the evidence-based skincare and cosmetology education assistant inside the SAMIYA BEAUTY LAB app.",
    `Always answer in ${LANG_NAME[lang]}, warmly and elegantly, in short paragraphs or bullet points (at most ~220 words).`,
    "Scope: cosmetic ingredients (INCI), skincare routines, natural/plant-based care, facial massage and gua sha, product labels, hygiene, and the history of cosmetics (including Ibn Sina's Canon of Medicine as history, not as evidence).",
    "Rules:",
    "- Education only. Never diagnose, never prescribe medicines or doses, never claim a product 'suits your skin'. For lesions, pain, infection, sudden changes, pregnancy-related or medication questions, advise seeing a dermatologist or doctor.",
    "- Be honest about evidence: say when evidence is limited, small or mixed. Never invent studies, statistics, PMIDs or brand claims. Do not use words like 'chemical-free', '100% safe', 'halal certified' or 'cures'.",
    "- Natural is not automatically safe: mention patch testing and known irritation risks (e.g. lemon juice, baking soda, essential oils) when relevant.",
    "- When APP CONTEXT is provided, prefer it and stay consistent with it; you may mention that the source list is in the app's ingredient card.",
    "- If the question is outside skincare/cosmetics, politely say you can only help with beauty and skincare topics.",
    "- Do not ask for or repeat personal data.",
  ].join("\n");
}

export type AiHistoryItem = { role: "user" | "model"; text: string };
export type AiRequest = { requestId: string; question: string; lang: AiLang; context: string; history: AiHistoryItem[] };

const REQ_ID = /^[A-Za-z0-9-]{8,64}$/;

/** Klient so'rovini qat'iy tekshiradi; xato bo'lsa null. */
export function parseAiRequest(raw: string): AiRequest | null {
  if (raw.length > 20000) return null;
  let b: Record<string, unknown>;
  try {
    b = JSON.parse(raw);
  } catch {
    return null;
  }
  if (typeof b !== "object" || b === null) return null;
  const { requestId, question, lang, context, history } = b;
  if (typeof requestId !== "string" || !REQ_ID.test(requestId)) return null;
  if (typeof question !== "string") return null;
  const q = question.trim();
  if (q.length < 2 || q.length > MAX_QUESTION) return null;
  const l = (AI_LANGS as readonly string[]).includes(lang as string) ? (lang as AiLang) : "en";
  const ctx = typeof context === "string" ? context.slice(0, MAX_CONTEXT) : "";
  const hist: AiHistoryItem[] = [];
  if (Array.isArray(history)) {
    for (const h of history.slice(-MAX_HISTORY)) {
      if (h && typeof h === "object" && (h.role === "user" || h.role === "model") && typeof h.text === "string") {
        hist.push({ role: h.role, text: h.text.slice(0, 1500) });
      }
    }
  }
  return { requestId, question: q, lang: l, context: ctx, history: hist };
}

/** Asia/Tashkent bo'yicha kun (UTC+5, yozgi vaqt yo'q). */
export function tashkentDay(now: Date): string {
  return new Date(now.getTime() + 5 * 3_600_000).toISOString().slice(0, 10);
}

export class AiProviderError extends Error {}

export async function callGemini(
  req: AiRequest,
  opts: { apiKey: string; model: string; fetcher?: typeof fetch; timeoutMs?: number },
): Promise<string> {
  const f = opts.fetcher ?? fetch;
  const user = req.context ? `APP CONTEXT (from the app's evidence cards):\n${req.context}\n\nQUESTION:\n${req.question}` : req.question;
  const body = {
    systemInstruction: { parts: [{ text: systemPrompt(req.lang) }] },
    contents: [
      ...req.history.map((h) => ({ role: h.role, parts: [{ text: h.text }] })),
      { role: "user", parts: [{ text: user }] },
    ],
    generationConfig: { temperature: 0.4, maxOutputTokens: 900 },
  };
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), opts.timeoutMs ?? 17000);
  let res: Response;
  try {
    res = await f(`https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(opts.model)}:generateContent`, {
      method: "POST",
      headers: { "content-type": "application/json", "x-goog-api-key": opts.apiKey },
      body: JSON.stringify(body),
      signal: ctrl.signal,
    });
  } catch {
    throw new AiProviderError("network");
  } finally {
    clearTimeout(timer);
  }
  if (!res.ok) throw new AiProviderError(`status ${res.status}`);
  const data = (await res.json()) as { candidates?: { content?: { parts?: { text?: string }[] } }[] };
  const text = (data.candidates?.[0]?.content?.parts ?? []).map((p) => p.text ?? "").join("").trim();
  if (!text) throw new AiProviderError("empty");
  return text;
}
