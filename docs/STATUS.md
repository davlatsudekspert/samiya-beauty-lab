# SAMIYA BEAUTY LAB: holat (2026-10-31)

## Qarorlar
- Backend: **Cloudflare** (Workers + D1 + Durable Objects + R2). Auth: **Firebase Auth** (faqat Google va Apple + mehmon rejimi, email/parol yo'q).
- Tillar: **UZ, RU, EN, AR** (arab = RTL). Pro: boshidan quriladi, `BILLING_ENABLED` bayrog'i bilan; to'lov: **RevenueCat**.
- Kontent: kosmetolog yo'q, jahon adabiyoti va regulyator manbalari (CosIng, EU 1223/2009, CIR, PubMed), har da'vo manba bilan. "Ekspert tasdiqlagan" deb yozilmaydi.
- 90 kun bepul kampaniya: `PUBLIC_LAUNCH_DATE` bo'sh (prelaunch), faqat egasi rasmiy launch kuni qo'yadi.

## Phase 0: bajarilgan va TEKSHIRILGAN
- `backend/`: kampaniya fazalari, ruxsatlar, sozlama tekshiruvi, `GET /api/v1/config/public`, D1 sxema. `npm test`: 14/14 o'tdi, `tsc --noEmit` toza, SQL sxema SQLite'da yaratildi.
- `mobile/`: Flutter 3.47.9, 4 tilli ARB + RTL asosi, tema tokenlari. `flutter analyze`: xatosiz, `flutter test`: 9/9 o'tdi (RTL yo'nalish, til almashtirish, ARB kalitlar tengligi, arab yozuvi).

## BajarilMAGAN (da'vo qilinmaydi)
- Hech narsa Cloudflare'ga deploy qilinmagan, D1 yaratilmagan (`wrangler.jsonc`da `REPLACE_WITH_D1_ID`).
- APK/AAB/IPA yo'q (bu muhitda Android SDK va Xcode yo'q; build GitHub Actions orqali, Phase 8).
- Auth, RevenueCat, OCR, AI, QR guruh testi, kontent: hali yozilmagan. 68 ekranning faqat vaqtinchalik Welcome sahifasi bor.
- Arab/rus/ingliz matnlari mashina tarjimasi, arabcha matnni ona tili egasi tekshirishi kerak.
- Git: lokal repo, commit va push qilinmagan (GitHub repo hali yo'q).
- Bundle ID vaqtincha `uz.samiya.samiya_beauty_lab`; Play'da abadiy bog'lanadi, birinchi yuklashdan oldin egasi tasdiqlaydi.

## Egasi qiladigan ishlar
Hozir: private GitHub repo `samiya-beauty-lab`; Cloudflare hisobi (Workers, D1, R2); bundle ID tanlash; arabcha tekshiruvchi odam.
2-bosqichdan oldin: Firebase loyihasi (Google va Apple yoqish), Apple "Sign in with Apple" kaliti, Gemini API kaliti, RevenueCat hisobi, Play to'lov profili va Apple Paid Apps Agreement. Maxfiy kalitlarni chatga emas, GitHub/Cloudflare Secrets'ga qo'ying.
Reliz oldidan: 12+ tester (Play shaxsiy akkaunt), maxfiylik siyosati URL, hisobni o'chirish sahifasi, narxlar.

## Keyingi qadamlar
1. Phase 1: dizayn tizimi + 1-10 ekranlar (4 tilda, RTL) · 2. Kontent pilot: 5 ingredient, 4 tilda, manbalar bilan · 3. Phase 2: Firebase auth + Worker token tekshiruvi.
