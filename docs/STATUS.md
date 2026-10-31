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
- Auth, RevenueCat, OCR, AI, QR guruh testi, kontent: hali yozilmagan. 68 ekranning 8 tasi native (Phase 1, pastga qarang).
- Arab/rus/ingliz matnlari mashina tarjimasi, arabcha matnni ona tili egasi tekshirishi kerak.
- Git: private repo `davlatsudekspert/samiya-beauty-lab`, `main` ga 2 commit push qilingan (Phase 0 kodi, dizayn referenslari).
- Bundle ID / paket nomi: **`uz.samiya.beautylab`** (Apple'da App ID ro'yxatdan o'tgan; Android va iOS loyihasida shunga o'zgartirildi). Play'da birinchi .aab yuklanganda abadiy bog'lanadi.

## Egasi qiladigan ishlar
Hozir: private GitHub repo `samiya-beauty-lab`; Cloudflare hisobi (Workers, D1, R2); bundle ID tanlash; arabcha tekshiruvchi odam.
2-bosqichdan oldin: Firebase loyihasi (Google va Apple yoqish), Apple "Sign in with Apple" kaliti, Gemini API kaliti, RevenueCat hisobi, Play to'lov profili va Apple Paid Apps Agreement. Maxfiy kalitlarni chatga emas, GitHub/Cloudflare Secrets'ga qo'ying.
Reliz oldidan: 12+ tester (Play shaxsiy akkaunt), maxfiylik siyosati URL, hisobni o'chirish sahifasi, narxlar.

## Yordamchi hisoboti (2026-10-31) va tekshiruv natijasi
- **Bajarilgan:** faqat A (GitHub private repo, Flutter .gitignore, MIT). B-J (bundle ID, Cloudflare, Firebase, Apple, Play, RevenueCat, Gemini, huquqiy sahifalar, arabcha tekshiruvchi) egasiga ko'rsatma sifatida berilgan, bajarilmagan. Bundle ID `uz.samiya.beautylab` keyin Apple'da ro'yxatdan o'tkazildi (pastga qarang).
- **Tekshirildi (rasmiy manba): Google Play** - O'zbekiston merchant ro'yxatdan o'tishni qo'llab-quvvatlaydi (valyuta USD), [Google jadvali](https://support.google.com/googleplay/android-developer/answer/9306917). Obunaga xos cheklov topilmadi; Payments profile ochilishi amalda egasi tomonidan tekshirilsin.
- **Tasdiqlanmadi: Apple.** Yordamchi "O'zbekiston uchun Paid Apps Agreement 2022 dan beri mavjud" degan, lekin manba topilmadi. Egasi App Store Connect > Agreements, Tax, and Banking ichida bank ma'lumotini qo'sha oladimi, o'zi tekshiradi. Ishlamasa, iOS'da Pro keyinga qoladi (arxitektura provayderga bog'liq emas).
- **Tuzatish:** yordamchi "20 tester" degan. Google rasmiy talabi **12 tester, 14 kun** (shaxsiy akkaunt); 20 faqat zaxira uchun. Hisobotdagi "Lifestyle/Beauty" kategoriya maslahati to'g'ri, sog'liq deklaratsiyasi: "Healthcare Services" belgilanmasin.
- Cloudflare Pages `samiya-legal.pages.dev` hali yaratilmagan, nom band bo'lishi mumkin.

## Phase 1 (davom etmoqda): dizayn tizimi va 1-10 ekranlar, TEKSHIRILGAN
- **Native Flutter ekranlar (4 tilda, RTL bilan):** 01 splash, 02 til tanlash, 03 welcome, 04-06 onboarding (bitta PageView, 3 sahifa), 07 kirish (faqat Google, Apple, mehmon), 10 rol tanlash, 11 bosh sahifa (VAQTINCHALIK stub). Router: go_router. Til, onboarding va rol diskda saqlanadi.
- **Ongli o'zgarishlar:** 08 (ro'yxatdan o'tish) va 09 (parolni tiklash) yo'q, chunki email/parol yo'q. Dizayndagi yurakcha ikonkasi olib tashlangan (ma'nosiz). Rol oldindan tanlanmaydi (aniq tanlov). Bayroq emojilari o'rniga UZ/RU/EN/AR monogrammalari. Wordmark native matn (rasm emas).
- **Tekshiruv:** `flutter analyze` toza; `flutter test` 57 ta o'tdi (oqim, saqlash, RTL, 48 px bosish maydoni, 320x568 ekran va 1.5x shriftda 4 tilda overflow yo'q); `flutter test --tags visual` 18 skrinshotni `qa/visual/` ga yozdi (uz, ar, ru). Testlar haqiqiy xatolarni topdi va tuzatildi (gradient yo'nalishi, overflow, arab raqam tartibi).
- **Shriftlar (OFL, ilovaga joylangan):** Inter + Playfair Display (lotin va kirill), IBM Plex Sans Arabic + Amiri (arab). Litsenziyalar `mobile/assets/licenses/`.
- **MUHIM ogohlantirishlar (egasi qarori kerak):**
  1. **Rasm aktivlari past sifatli** (taxta 1536 px, portretlar ~300-400 px; men faqat 2x silliq kattalashtirdim, aniqlik oshmaydi). Haqiqiy reliz uchun asl yuqori sifatli fayllar (logotip belgisi, hijobli portretlar) kerak.
  2. **Logotip ostidagi "BEAUTY · SCIENCE · HALAL"** va taxtadagi "Xavfsizlik darajasi 88%", "Halol mahsulot", "Teri uchun mos" matnlari mahsulot siyosatiga zid (dalilsiz da'vo). Ilova ularni ishlatmaydi; "HALAL" so'zini brenddan olib tashlash egasining qarori.
  3. Google tugmasidagi "G" vaqtincha (rasmiy Google belgisi Phase 2 da).
  4. Arab, rus, ingliz matnlari mashina tarjimasi; arabchani ona tili egasi tekshirishi kerak.

## Qarorlar: reklama va hamkorlar (egasi rozi, 2026-10-31)
- Reklama o'rinlari ilovada boshidan quriladi, lekin `adsEnabled` bayrog'i bilan **dastlabki 90 kunda o'chiq**. Pro obunasi reklamasiz. Moderatsiyani egasi qiladi, yordamchi ko'maklashadi.
- To'g'ridan-to'g'ri sotiladigan reklama (reklama tarmog'i SDK'siz). Reklama tahlilga, AI javoblariga, testlarga va kirish ekranlariga ta'sir qilmaydi; yorliq ("Reklama", "Homiylik") har doim ko'rinadi; salomatlik/teri ma'lumoti bo'yicha maqsadli reklama yo'q.
- "Hamkorlar uchun" bo'limi: asosan veb-sahifa (Cloudflare Pages) + ilovada havola; ariza Worker orqali D1'ga. Reja: 6-bosqichdan keyin (~1.5-2 hafta). O'zbekiston reklama qonunchiligini yurist tekshiradi.

## Phase 1 davomi: navigatsiya qobig'i va bosh sahifa (TEKSHIRILGAN)
- Pastki 5 bandli navigatsiya (go_router StatefulShellRoute), tab holati saqlanadi; Akademiya, Skaner, Kundalik, Profil hozircha halol "Tez orada" joy egalari.
- 11 Bosh sahifa native: salom, qidiruv (hozircha "tez orada"), banner, 6 plitka, mashhur ingredientlar (faqat INCI nomlari, da'vosiz). Dizayndan **ongli chetga chiqish**: "Tabiiy va havfsiz" -> "Dalillar va manbalar bilan" (dalilsiz da'vo), "Teri tahlili" -> "Teri afzalliklari" (tashxis ma'nosi), "Mutaxassislar" -> "SAMIYA AI" (bunday katalog yo'q).
- Testlar: `flutter test` 85 ta o'tdi (jumladan siyosat testi: bosh sahifada halal/xavfsiz/88% kabi iboralar 4 tilda yo'q; arabda navigatsiya tartibi teskari; 320x568 va 1.5x shriftda overflow yo'q). `flutter analyze` toza.

## Kontent pilot (A): 5 ingredient, 4 til (DRAFT, qisman tekshirilgan)
- `content/pilot/`: niacinamide, hyaluronic-acid, salicylic-acid, ascorbic-acid, retinol + 40 terminli glossary (uz, ru, ar). 19 noyob PMID; `validate_content.py --online` o'tdi (PMID, sarlavha, yil PubMed bilan mos). Qo'lda annotatsiya bilan tekshirildi: niacinamide-2, -3, -5 (oxirgisi olib tashlandi).
- Ko'rib chiqishda 3 da'vo mazmun doirasiga to'g'ri kelmagani uchun olib tashlandi (dori yoki protsedura: aktinik keratoz/fluorouracil, kimyoviy piling, lazerdan keyingi qizarish). Qoida `content/pilot/README.md`da.
- **TASDIQLANMAGAN:** barcha 5 kartochkada EU annex va CosIng funksiyalari (`unverified`), chunki EUR-Lex/CosIng bu muhitdan o'qilmadi. Retinol va salitsil kislota cheklovlari qo'lda rasmiy manbadan tekshirilishi shart. Arab/rus/uz matnlari mashina tarjimasi. Validator da'voning manbaga to'liq mosligini tekshirmaydi (faqat sarlavha/yil).

## Apple (yordamchi bajargan, 2026-10-31) - maxfiy bo'lmagan natijalar
- **App ID yaratildi:** "SAMIYA BEAUTY LAB", Bundle ID `uz.samiya.beautylab`, App ID prefiksi (Team ID) `5Z9CT2W378`. Capability: Sign in with Apple (primary App ID) va In-App Purchase (standart yoqilgan).
- **Sign in with Apple kaliti yaratildi:** Key ID `94WS6NBPXQ`. `.p8` faylni FAQAT egasi o'zi yuklab oladi (bir martalik) va xavfsiz joyda saqlaydi; keyin Firebase formasiga o'zi joylaydi.
- **Hali qilinmagan:** Services ID (Firebase loyihasi kutilmoqda), App Store Connect yozuvi, App Store Connect API kaliti (CI), 0-bosqich hisoboti (Paid Apps Agreement, bank formasida O'zbekiston bormi), Firebase, Cloudflare.
- Ilovaning bosh ekran nomi: **SAMIYA** (Android va iOS), chunki to'liq nom ikonka ostiga sig'maydi.

## Keyingi qadamlar
1. Phase 1: dizayn tizimi + 1-10 ekranlar (4 tilda, RTL) · 2. Kontent pilot: 5 ingredient, 4 tilda, manbalar bilan · 3. Phase 2: Firebase auth + Worker token tekshiruvi.
