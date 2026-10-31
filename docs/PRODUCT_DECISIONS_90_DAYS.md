# SAMIYA BEAUTY LAB — 90-day free public launch (approved concept)

**Decision date:** 2026-10-28  
**Brand:** Original approved blush-pink / hijab-portrait visual identity; do not change without the owner's consent.

## Exact meaning of '3 oy tekin'

The product launches with a **single global public 90-day campaign**, not a new 90-day clock each time someone signs up. The official public launch date is **NOT KNOWN YET** and must not be invented. On the confirmed public launch date, the authorized server administrator sets `officialLaunchDate` once. Promotional access ends after 90 days in the configured `Asia/Tashkent` timezone (date boundaries are server-authoritative).

**Important:** This is NOT an App Store / Play Store auto-renewing subscription free trial. **No card is required**, no subscription is created by registering, and **no charge begins automatically** when the campaign ends. It is a free introductory access campaign controlled by a backend feature entitlement, not a payment transaction.

## During the global 90 days

- Free core: ingredient encyclopedia, basic academy lessons, skincare routine, journal, limited manual INCI demo/search.
- Campaign-access bonus: additional expert-reviewed lessons, advanced ingredient explanations, premium lesson library (as content becomes available).
- AI: free preview limited to **5 requests/user/day**, adjustable *after measured infrastructure cost review*. This protects against runaway API bills; a global spend cap is also essential.
- Scanner: truly operating OCR must not be advertised until backend/ML Kit integration is verified.
- Full medically individualized product recommendations and diagnosis are out of scope. No unsupported 'halal certified', '88% safe', 'fits your skin' verdicts.
- Advertising: `adsEnabled=false` and `sponsoredProductsEnabled=false` at first launch by default. Business can enable clearly labeled non-sensitive-context ads after review; sponsored products never alter AI's independent recommendations.

## After 90 days

- Free account continues to work with basic encyclopedia, basic academy, routine, journal, and lower AI / scan limits.
- Pro remains **optional**. A paywall for the extra content is allowed only once the owner approves a price and actual in-app purchase flow is correctly integrated.
- No automatic conversion of a Free user into a paid user and no card collection during the campaign.
- Announce upcoming changes well in advance, show a side-by-side Free vs Pro comparison; avoid removing user-owned journal data.

## Production architecture

- **Single source of truth:** backend `promotion_config` and verified purchase entitlements.
- Client UI is informative only. Do not enforce subscription permissions solely through mobile local time, localStorage, or client-side flags.
- Initial `officialLaunchDate = null` means **prelaunch**. The prototype must not count down 90 days from its creation date.
- Usage caps enforced atomically by authenticated user identity on server; add device-attestation / abuse prevention as appropriate without invasive fingerprinting.
- Apple / Google billing is disabled until separate approval. Secret keys are server-only; do not put model API keys or service credentials in Flutter, JS or GitHub commits.
- Screens must explain that premium content offered during launch is provisional and benefits may change after the window, while Free persists.

## Release checklist

- [ ] Product owner approves official launch date and campaign eligibility policy.
- [ ] Authentication, privacy policy, consent and data deletion implemented.
- [ ] Backend promotion end-to-end tests (start, day 89, day 90, different timezones, server clock).
- [ ] Daily request limits enforced, budget circuit breaker enabled.
- [ ] Actual OCR and AI verified, unsupported ingredient claims removed from *native* production UI.
- [ ] Legal/store review of subscription messaging before enabling paid Pro.
- [ ] Baseline telemetry/analytics opt-in and marketing pages prepared.
- [ ] No automatic macOS CI runners, no paid third-party tools enabled without approval.
