# SAMIYA BEAUTY LAB — DESIGN SYSTEM v1.0

## Brand
User-approved icon: hijab profile + botanical leaves. Rose-blush premium visual language, warm ivory cards, soft editorial illustrations, inclusive and scientifically careful cosmetic education.

## Color tokens
| Token | HEX | Intended usage |
|---|---|---|
| `rose.primary` | `#D94F7A` | CTA / selected icons |
| `rose.deep` | `#B85B6A` | heading accents |
| `rose.light` | `#F7A7C1` | gradients |
| `rose.blush` | `#FFE5EC` | pale surfaces |
| `rose.soft` | `#F3D7DC` | separators |
| `surface.ivory` | `#FFF9F8` | app background |
| `ink.primary` | `#392A31` | text |
| `ink.muted` | `#806C73` | supporting text |
| `ink.brown` | `#8B6F6F` | secondary labels |

## Typography
- Brand mark: original approved artwork, not re-typeset.
- Headlines: elegant serif (prototype uses Georgia fallback), size 27–29 px; implement with licensed/interoperable font and correct language coverage.
- UI text: platform system sans, sizes 10–16 px in prototype; raise small 9–11 px labels as needed to meet accessible mobile display requirements.
- Buttons: bold rounded, height target 44+ logical px for accessible touch.

## Spacing and shape
- Horizontal screen padding: ~17–20 px; component spacing: 8/12/16/24 px.
- Cards radius: 16–23 px; primary CTA radius: 26 px.
- Soft rose shadows `0 14px 40px #B85B6A1C`; subtle borders `#EFD8DF`.
- Five-item bottom navigation: Home, Academy, Scanner, Journal, Profile.

## Component inventory
StatusBar, Header, BottomNav, PrimaryButton, OutlineButton, InfoPill, Card, FeatureTile, ListTile, Input, Textarea, Select, PhotoHero, Banner, WarningPanel, ProgressTrack, SettingsToggle, ChatBubble, Drawer/BottomSheet, Toast.

## Screens and states
- 56 top-level route IDs in `SCREEN_INVENTORY.json`.
- Prototype interactive states: input, role selection, selected language, quiz selection, saved journal item, routine checked state, local product, export/reset, errors from empty fields, info dialogs.
- Production needs dedicated offline, permission denied, loading, empty, success/error, disabled and paid-state flows throughout.

## Scientific content rules
- Do not assign universal “safe %” or “100% harmless” labels from raw INCI list.
- Halal status requires reliable certification and suitable scope; do not infer it from names alone.
- Personal suitability depends on actual formula, concentration, usage and individual factors.
- Disclose evidence sources and update dates; AI cannot diagnose disease.

## Original image references
`assets/original-approved-board.png`, `assets/additional-approved-board.png` and original `screen-*.png` files retain the aesthetic the user approved. Use as *visual references*, not as production UI screenshots: real Flutter UI should be composed from components and text layers.

## 90-day campaign additions (2026-10-28)

- Add pill `90 KUN BEPUL · YAQINDA` until official release date is configured, then the number of days left.
- Campaign cards are subtly tinted rose on ivory, not promotional full-screen interstitials.
- Never request a bank card for campaign access; there are no auto-renewal indicators.
- Upgrade path is disabled until billing, prices and store review are approved.
- Sponsor banners remain hidden until separately enabled and clearly marked `Homiylik reklama`.

## v1.3 additions (2026-10-28)
- 68 routed preview screens including five personalized Beauty Journey pages and seven Academy presentation/group-test pages.
- Never change the user's primary blush-hijab visual identity without explicit approval.
- Daily cards: rose-tinted callouts, white surfaces, low-intensity shadows, 16–24 px radii, clearly selected pill choices and accessible button labels.
- Engagement rules: no forced streak, countdown scare, guilt-inducing beauty score or appearance ranking.
- The 10 original artwork-based screens are references and *not* native Flutter widgets. Rebuild text and interactive semantics in Flutter.

## Social sign-in components · design v1.2

- Both Login and Signup include Google and Apple sign-in buttons above email fields, 49dp minimum touch height in web prototype; Flutter uses >=54dp native buttons. Google: white card with blue G marker. Apple: near-black high-contrast card with white icon marker. Actual use of vendor trademark artwork in production must comply with provider's branding guidelines.
- Rose-pink campaign capsule communicates **90 KUN BEPUL · KARTA KERAK EMAS**.
- Guest entry is accessible without account. Demo disclosure modal is mandatory until real provider integration is validated.
- Hero retains approved modest beauty photography and soft gradient. Actual Flutter content must use responsive layout and safe areas.
- Accessibility: use semantic labels (`Google orqali davom etish`, `Apple orqali davom etish`), large targets, focus rings, contrast and readable body font. Full a11y audit remains pending.

## Academic learning flow additions

`slides` (presentation) → `group-create` → `group-lobby` (QR) → `group-join` → `group-quiz` → `group-results` → `mistake-review`. A scannable demo QR is used for UI only. Three-language lesson/question content is a production requirement, not claimed delivered.
