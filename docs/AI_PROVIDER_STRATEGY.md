# SAMIYA AI — economical, fast, reliable and privacy-respecting architecture

**Status:** design decision and tested policy gate, **not a deployed AI service**.

## Choice

- Main candidate: **Google Gemini Flash-Lite**. Pin model ID explicitly in configuration after live benchmarking; do not hardcode assumed future catalog IDs.
- Optional secondary candidate: **DeepSeek chat/Flash**, provided API access, price, latency, data residency and policy review pass. **Do not send the same sensitive question to two providers silently.** A second-provider route requires explicit opt-in and user-facing explanation.
- Camera ingredient text detection: **on-device Google ML Kit** when supported; OCR is text extraction, not ingredient verification. User confirms OCR text before analysis.
- Ingredient facts: verified INCI index/curated references; AI explains facts but does not fabricate chemical evidence.

## Fast perceived performance

1. On-device OCR and local field validation (no AI call for every scan).
2. Stream short answers; show partial answer state and accessible cancel control.
3. Cache public ingredient definitions by normalized INCI ID and evidence revision, **not private user chats**.
4. Keep a small prompt + retrieval context, limit output length, use 12-second target timeout then explicit retry. Benchmark p50/p95 latency in Uzbekistan before selecting production provider.
5. Server-controlled daily quota and spend cutoff. Default prelaunch assumption: 5 free AI requests per account per day; owner may change after observing real cost.

## Privacy/security gates

- Never place any API key inside Flutter, HTML, screenshots, app package or repository.
- Use a server-only secrets manager and HTTPS API proxy; authenticated user and IP level controls; transactional per-day quota (idempotent).
- Separate explicit consent for external AI processing and for photos; avoid sending journal content unless necessary and consented.
- No personalized health/ad targeting from skin preferences. Ads off on first release; sponsored content must be clearly labeled and cannot influence assistant rankings.
- Empty chat and ingredients catalog must still offer useful **offline** educational functions if the AI provider is unavailable.

## Deployment and purchase boundaries

No external Gemini/DeepSeek call, account, billing, payment or key has been activated. See `backend_reference/ai_policy.py` for a unit-tested **preflight policy only**. The script must not be mistaken for a deployed or authenticated API.

Official provider docs and prices must be checked at launch time:

- https://ai.google.dev/gemini-api/docs/pricing
- https://api-docs.deepseek.com/quick_start/pricing/

## Acceptance tests for Claude Code

- Rate limits 5/6, quota concurrency, global budget, timeout, fallback consent, user deletion, photo-consent rejection, invalid INCI text.
- Benchmark comparative test of Gemini vs DeepSeek with **public or synthetic** multilingual UZ/RU/EN skincare education questions; never submit real private journals into benchmarks.
- Compare accuracy and humility, time-to-first-token, p95 latency, context cost, and retry error rate. Document test corpus and date before production selection.
