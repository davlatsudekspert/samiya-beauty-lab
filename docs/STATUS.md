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
- **Apple (yordamchi sahifadan o'qigan, 2026-10-31):** Paid Applications Agreement holati **Active**, faol bank yozuvi bor (O'zbekiston uchun), 2 ta AQSh soliq formasi Active. Demak iOS'da pullik obuna uchun to'siq ko'rinmayapti. Men buni o'zim ko'rmadim (yordamchi hisoboti), amalda obuna mahsulotini yaratganda qayta tasdiqlanadi.
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
- **Services ID yaratildi:** `uz.samiya.beautylab.signin` ("SAMIYA sign in"). Uning Domains/Return URL sozlamasi SAQLANMAGAN: Firebase loyihasi yaratilgach `<project-id>.firebaseapp.com` va `https://<project-id>.firebaseapp.com/__/auth/handler` kiritiladi.
- **Akkaunt turi:** Individual (Team ID `5Z9CT2W378`).
- **Hali qilinmagan:** Firebase loyihasi (asosiy to'siq), App Store Connect ilova yozuvi (til va kategoriya qarori kerak), App Store Connect API kaliti (CI), Cloudflare.
- Ilovaning bosh ekran nomi: **SAMIYA** (Android va iOS), chunki to'liq nom ikonka ostiga sig'maydi.

## Phase 1 davomi: skaner oqimi (16, 19, 20, 21) - TEKSHIRILGAN
- **16 Skaner** (kamera tugmasi hali "Tez orada"), **19 Tarkibni kiritish** (qo'lda, matn tahlilchisi bilan), **20 Tahlil natijasi**, **21 Ingredient sahifasi** (xulosa, dalil darajalari A/B/C, har da'vo uchun PubMed havolasi).
- **Natija faqat "bazada bor/yo'q":** xavfsizlik bahosi, foiz yoki "sizga mos" xulosasi yo'q. Moslashtirish faqat aniq INCI nomi yoki tasdiqlangan sinonim bo'yicha (Sodium Hyaluronate, Retinyl Palmitate kabi hosilalar taxmin bilan bog'lanmaydi, testlar bilan himoyalangan). Bazada 5 ingredient bor.
- **Halol belgilar:** har ingredient sahifasida "matn qoralama, tarjima tekshirilmagan" va "EU/CosIng tasdiqlanmagan" eslatmalari ko'rinadi.
- **Kontent yagona manbadan:** `content/tools/build_app_content.py` `content/pilot` dan `mobile/assets/content/ingredients.json` ni yasaydi (qo'lda tahrirlanmaydi).
- **Testlar:** `flutter test` 142 ta o'tdi (jumladan kontent shartnomasi, siyosat va 320x568/1.5x shriftda 4 tilda overflow yo'q); `flutter analyze` toza. Test topgan xato: asset o'qish soxta vaqt zonasida qotib qolgan edi (`runAsync` bilan tuzatildi).

## Apple davomi: ilova yozuvi va CI kaliti (yordamchi, 2026-10-31)
- **App Store Connect ilova yozuvi yaratildi:** "SAMIYA BEAUTY LAB", Apple ID `6829190065`, Bundle `uz.samiya.beautylab`, SKU `samiya-beauty-lab`, til English (U.S.), kategoriya Lifestyle (asosiy) va Education (qo'shimcha). Obuna mahsuloti hali yaratilmagan (narx yo'q).
- **CI API kaliti yaratildi:** "SAMIYA CI", Key ID `ZC53Z723LK`, rol App Manager. `.p8` ni egasi o'zi yuklab oladi. **Issuer ID** yordamchi hisobotida noto'g'ri formatda (38 belgi), qiymat taxmin qilinmadi: egasi Apple sahifasidan aniq nusxalaydi.
- **Firebase:** loyiha yaratish shartlarini qabul qilishni egasi o'zi bajaradi (yordamchi to'xtagan).
- **CI ish oqimlari qo'shildi** (`.github/workflows/`): `ci.yml` (har push, Linux: tahlil, testlar, kontent tekshiruvi), `android-aab.yml` va `ios-testflight.yml` (faqat qo'lda; **tekshirilmagan qoralamalar**, Android SDK va Mac bu yerda yo'q). Kerakli Secrets: `docs/SECRETS.md`. Android release imzosi `key.properties` orqali (kalit yo'q bo'lsa debug imzo, faqat lokal).

## Firebase va haqiqiy kirish (2026-10-31)
- **Firebase loyihasi:** Project ID `samiya-beauty-lab` (raqam `256361630285`), bepul Spark rejasi. Google va Apple provayderlari yoqilgan (Apple: Services ID `uz.samiya.beautylab.signin`, Team `5Z9CT2W378`, Key `94WS6NBPXQ`; `.p8` ni egasi o'zi kiritdi). Android va iOS ilovalari ro'yxatdan o'tgan. Apple callback: `https://samiya-beauty-lab.firebaseapp.com/__/auth/handler`.
- **Hali qolgan (egasi/yordamchi):** `google-services.json` va `GoogleService-Info.plist` ni egasi yuklab olib Secrets'ga qo'yadi; Apple Services ID'da Domains/Return URL ni saqlash (Save); Android SHA-1.
- **Backend:** `GET /api/v1/me` Firebase ID tokenini Worker'da tekshiradi (RS256, kalitlar Google'dan, kesh; aud/iss/exp/iat/sub, alg=none va HS256 hujumlari rad etiladi); foydalanuvchini D1'ga bir marta yozadi. 31 backend test o'tdi.
- **Ilova:** `AuthService` abstraksiyasi, `FirebaseAuthService` (Google va Apple, provayder oqimi), Firebase sozlanmagan bo'lsa `UnavailableAuthService` ("Kirish hozircha mavjud emas", qulamaydi). Kirish ekrani: band holati, bekor qilish jim, xato xabari 4 tilda. 122 test o'tdi (soxta kirish xizmati bilan). **Haqiqiy qurilmada Google/Apple kirishi HALI SINALMAGAN** (konfiguratsiya fayllari va qurilma kerak).
- **Xavf:** iOS'da `GoogleService-Info.plist` bo'lmasa Firebase ishga tushganda native qulash bo'lishi mumkin; shu sabab CI uni majburiy qildi. Android'da google-services plagini faqat `google-services.json` bor bo'lsa ulanadi (tekshirilmagan gradle).

## CI va Android build (2026-10-31)
- **Repo OMMAVIY** (egasi qarori): GitHub Actions bepul ishlaydi. Litsenziya MIT'dan "barcha huquqlar himoyalangan" ga almashtirildi (huquq egasi hozircha brend nomi; yuridik nomga almashtirish egasining ishi). Workflow'lar `contents: read`, Android natijasi AES-256 parolli zip.
- **CI** (`ci.yml`, har push): GitHub'da o'tdi (backend, mobile, content).
- **Android AAB va APK** (`android-aab.yml`, qo'lda): **birinchi muvaffaqiyatli build** (7 daqiqa, run 41199555366): testlar, `appbundle` va `apk` quriladi; imzo yuklash kaliti bilan (SHA-1 `D1:F8:C3:33:38:27:89:6F:5E:1E:AC:90:C8:47:3D:FD:67:5F:49:8A`, Firebase'ga qo'shilgan). Secret dekoderi chidamli (`.github/scripts/write_secret.sh`).
- **Telefonda HALI SINALMAGAN:** Google/Apple bilan kirish, ilova umuman ishga tushishi.
- **iOS TestFlight:** workflow tayyor, ishga tushirilmagan (macOS). Navbatda: Profil ekrani, hisobni o'chirish (`DELETE /api/v1/me`), Google Play ichki test.

## Profil ekrani va hisobni o'chirish (2026-10-31) - TEKSHIRILGAN (qurilmada emas)
- **59 Profil:** hisob kartasi (ism/email/provayder yoki "Mehmon"), mehmon uchun "Kirish", til almashtirish, rol qatori (rol ekraniga olib boradi), maxfiylik va shartlar qatorlari (URL tayyor emas: halol "Tez orada"), **Chiqish** va **Hisobni o'chirish** (tasdiq oynasi bilan). Do'konlar hisobni ilova ichida o'chirishni talab qiladi.
- **Tartib (muhim):** hisobni o'chirishda AVVAL backend `DELETE /api/v1/me` (token yaroqliyida), KEYIN Firebase hisobi. Backend o'chira olmasa Firebase hisobi saqlanadi (ma'lumot yetim qolmaydi, qayta urinish xavfsiz). Firebase "yaqinda kirish" talab qilsa aniq xabar chiqadi.
- **Backend:** `DELETE /api/v1/me` foydalanuvchining barcha qatorlarini bitta batch'da o'chiradi (entitlements, ai_daily_usage, ai_request_idempotency, users). 36 backend test o'tdi.
- **Ilova:** `BackendApi` (HttpBackendApi, `--dart-define=API_BASE_URL=...`; manzil berilmasa NoBackendApi: server ma'lumoti yo'q, faqat Firebase hisobi o'chiriladi). 147 test o'tdi.
- **Ochiq:** Worker hali deploy qilinmagan (D1 ID yo'q), shuning uchun `API_BASE_URL` berilmaydi. Maxfiylik siyosati URL va shartlar sahifasi yo'q. Hisob o'chirish veb-sahifasi (Play talab qiladi) yo'q.

## Cloudflare (yordamchi, 2026-10-31) - maxfiy bo'lmagan natijalar
- **Account ID:** `31c4b3d8ece4b65de515debc4552334a` (URL'dan; maxfiy emas). **workers.dev subdomain:** `davlatsudekspert` (allaqachon ro'yxatdan o'tgan), shuning uchun Worker manzili `https://samiya-api.davlatsudekspert.workers.dev` bo'ladi.
- **D1 bazasi yaratildi:** `samiya`, Eastern Europe, UUID `9f25a933-c4f9-4050-a1d1-27ce27b55eee`. (Hisobda 9 ta D1 bor, limit 10; boshqa loyihalar ham shu hisobda.)
- **API token:** "samiya-ci" (Workers Scripts: Edit, D1: Edit, Cloudflare Pages: Edit, Account Settings: Read; muddati 2027-10-31) **hali yaratilmagan**: "Create Token" ni yordamchi bosa olmadi (xavfsizlik to'sig'i), egasi o'zi bosadi va `CLOUDFLARE_API_TOKEN` hamda `CLOUDFLARE_ACCOUNT_ID` Secrets'ni qo'yadi.
- **Ogohlantirish:** token butun hisobga tegishli (boshqa loyihalarning Worker va D1'lariga ham ruxsati bor). Imkon bo'lsa SAMIYA uchun alohida Cloudflare hisobi ochish xavfsizroq. Hozirgi himoya: Secrets forklarga berilmaydi, deploy faqat qo'lda ishga tushadi.
- **Navbat:** token qo'yilgach `Deploy backend (Cloudflare)` ishga tushadi (D1'ni nomi bo'yicha topadi); keyin ilovaga `API_BASE_URL` ulanadi (deploy tasdiqlangandan SO'NG: aks holda hisobni o'chirish ishlamay qolardi).

## Backend JONLI (2026-10-31)
- **Worker joylandi:** `https://samiya-api.davlatsudekspert.workers.dev` (GitHub Actions "Deploy backend (Cloudflare)" orqali). D1 `samiya` topildi, `0001_init.sql` qo'llandi. Jonli tekshiruv: `/health` 200, `/api/v1/config/public` to'g'ri (prelaunch, kartasiz, billing/reklama o'chiq), `/api/v1/me` tokensiz 401.
- **Android/iOS build'lar** endi `--dart-define=API_BASE_URL=...` bilan quriladi, ya'ni hisobni o'chirish serverdagi ma'lumotni ham o'chiradi.
- **TEKSHIRILMAGAN (jonli):** Firebase tokenini Worker'da tekshirish (`/api/v1/me`, `DELETE /api/v1/me`) haqiqiy token bilan sinalmagan: birinchi telefon sinovida (kirish, so'ng hisobni o'chirish) tasdiqlanadi.
- **Hali yo'q:** GEMINI_API_KEY (AI), RevenueCat webhook, maxfiylik siyosati sahifasi.

## Foydalanuvchi sifatida aylanib chiqish (QA, 2026-10-31)
- **Usul:** ilovaning veb-versiyasi (Flutter web) haqiqiy brauzerda (Chromium, Playwright) uz va ar tillarida to'liq oqim bo'yicha bosib chiqildi: til, welcome, 3 onboarding, kirish (Google xatosi), mehmon, rol, bosh sahifa, skaner, kiritish, natija, ingredient sahifasi, profil, til almashtirish. 19+19 qadam xatosiz o'tdi, brauzer konsolida xato yo'q, resurslar to'liq yuklandi. Skrinshotlar ko'rib chiqildi.
- **Topilgan va tuzatilgan:** (1) xato xabari (snackbar) pastdagi tugmalarni, jumladan "Mehmon sifatida davom etish" ni YOPIB QO'YARDI: endi sahifa ichidagi xabar (`login-error`); (2) xabar keyingi ekranga o'tib qolardi; (3) welcome'da rasm ostida katta bo'sh joy: rasm ekran balandligiga moslashadi. 148 test o'tdi.
- **Halollik tekshiruvi (jonli):** "Sodium Hyaluronate" kiritilganda "Bazada hali yo'q" deb ko'rsatildi (Hyaluronic Acid bilan aralashtirilmadi).
- **QA'da TEKSHIRILMAGAN:** haqiqiy Google/Apple kirishi (veb'da Firebase sozlanmagan), kamera, push, telefon qurilmasi xususiyatlari.

## Keyingi qadamlar
1. Phase 1: dizayn tizimi + 1-10 ekranlar (4 tilda, RTL) · 2. Kontent pilot: 5 ingredient, 4 tilda, manbalar bilan · 3. Phase 2: Firebase auth + Worker token tekshiruvi.
