# API / infrastructure contract — for Claude Code

This is a **proposed contract**, not an operating service. The tested `backend_reference/policy.py` supplies campaign phase and an atomic daily AI quota algorithm only. It is not publicly deployed, does not perform authentication and does not call any AI provider.

## Environment variables (server only)

- `PUBLIC_LAUNCH_DATE` — no value until actual public release; ISO `YYYY-MM-DD` Tashkent day.
- `CAMPAIGN_DURATION_DAYS=90`
- `AI_FREE_DAILY_REQUESTS=5`
- `AI_PRO_DAILY_REQUESTS=50` (tentative; owner approval needed)
- `AI_GLOBAL_DAILY_REQUESTS_MAX` and `AI_GLOBAL_DAILY_SPEND_USD_MAX` — configure before real API calls.
- `SUBSCRIPTIONS_ENABLED=false`
- `ADS_ENABLED=false`
- `SPONSORED_PRODUCTS_ENABLED=false`
- `AI_PROVIDER_API_KEY` — secret in backend vault only; NEVER expose to client or logs.

## Proposed endpoints

All sensitive routes use HTTPS, authenticated sessions, per-IP and per-user rate limits, request IDs, audit logs without user photos or private journal contents, CSRF protections for cookie auth where appropriate.

### GET /api/v1/config/public

```json
{
  "campaign": {
    "kind": "global_90_day_launch",
    "phase": "prelaunch",
    "officialLaunchDate": null,
    "durationDays": 90,
    "daysRemaining": null,
    "requiresCard": false,
    "autoCharge": false
  },
  "features": { "billingEnabled": false, "adsEnabled": false, "sponsoredProductsEnabled": false },
  "aiDailyLimitFree": 5
}
```

No start date should be generated based on when this endpoint was first called. Admin-only modification is required to set official launch date.

### GET /api/v1/me/entitlements

Auth required. Server determines `phase` from its own clock, verified Pro entitlement from store receipts, and returns `features: {key: boolean}` + expiration. Do not trust `isPro` sent by client.

### POST /api/v1/ai/chat

Auth required, consent for any sensitive data, idempotency key, sanitized request, strict limits (per user, IP, global budget). On rate limit: `429` and `retryAfterSeconds` rather than an incorrect answer. AI provider call goes through server; store only necessary conversation history with retention controls; no diagnosis; optionally return trustworthy citation IDs.

### POST /api/v1/inci/interpret

Use validated text/OCR results and a reviewable ingredient database. Return `recognized`, `uncertain`, `ingredientFunction`, `sources`, `sourceReviewDate` and **uncertainty**. Never synthesize a safety percentage from just INCI order; do not label 'Halol' absent third-party evidence.

### GET /api/v1/academy/courses

Return roles, languages, reviewer-verified lesson status, user progress and pagination. Unverified draft course content must not be marketed as authoritative.

### GET /api/v1/me/journal ; POST /api/v1/me/journal

Private data encrypted at rest; user can export and permanently delete it. Optional image storage requires separate explicit consent and limited retention.

### POST /api/v1/billing/verify

Must verify a real Apple/Google transaction server-to-server using vendor APIs. Never use the front-end 'purchase success' dialog to grant Pro privileges. Billing remains disabled until product owner approves.

### GET /api/v1/me/export ; DELETE /api/v1/me

Implement authentication recheck, export to machine-readable format, deletion, and user confirmation flows. Avoid leaking internal IDs or PII in analytics.

## Example minimal DB tables

- users (id, locale, account_created_at, consent_revision)
- promotion_config (start_date, duration_days, status, updated_by, updated_at)
- entitlements (user_id, product, provider, provider_transaction_id, verified_at, ends_at)
- ai_daily_usage (user_id, local_day_uz, count)
- ai_request_idempotency (user_id, request_id, created_at)
- ingredients (canonical_inci, synonyms, function, notes, evidence_revision)
- ingredient_sources (ingredient_id, citation_uri, publisher, checked_at)
- journal_entries (owner_id, entry_id, encrypted_text, created_at)
- courses/lessons/quizzes/results with reviewed_at/reviewer_id

## Testing plan

Check threshold and concurrency, Tashkent midnight, a mistaken phone clock, changing official launch date, expired receipts, user deletion, duplicate request ID, the sixth free AI query, unexpected provider failures, photo consent and analytics anonymization.
