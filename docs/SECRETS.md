# GitHub Secrets (qiymatlar HECH QACHON chatga yoki repoga yozilmaydi)

Repo > Settings > Secrets and variables > Actions > New repository secret. Qiymatlarni faqat egasi kiritadi.

| Nomi | Nima | Qayerdan | Holat |
|---|---|---|---|
| `ASC_KEY_ID` | App Store Connect API Key ID | `ZC53Z723LK` (maxfiy emas) | egasi kiritadi |
| `ASC_ISSUER_ID` | Issuer ID (UUID, 36 belgi: 8-4-4-4-12) | App Store Connect > Users and Access > Integrations tepasidagi "Issuer ID" ni NUSXA tugmasi bilan | **yordamchi yozgan qiymat noto'g'ri formatda (38 belgi), qayta nusxalang** |
| `ASC_KEY_P8_B64` | CI kalit fayli (.p8), base64 | "SAMIYA CI" kalitini egasi o'zi yuklab oladi (bir martalik), `base64 -w0 AuthKey_ZC53Z723LK.p8` | egasi yuklab oladi |
| `GOOGLE_SERVICE_INFO_PLIST_B64` | Firebase iOS fayli, base64 | Firebase loyihasi yaratilgach | kutilmoqda |
| `GOOGLE_SERVICES_JSON_B64` | Firebase Android fayli, base64 | Firebase loyihasi yaratilgach | kutilmoqda |
| `ANDROID_KEYSTORE_B64` | Android imzo kaliti (.jks), base64 | `keytool -genkeypair ...` (men buyruqni beraman); kalit va parolni yo'qotsangiz ilovani yangilab bo'lmaydi | egasi yaratadi |
| `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` | imzo kaliti paroli va nomi | yuqoridagi bilan birga | egasi yaratadi |

Cloudflare uchun (Worker deploy): `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID` (keyingi bosqich).

Workflow'lar: `ci.yml` (har push, Linux), `android-aab.yml` va `ios-testflight.yml` (faqat QO'LDA, ikkalasi tekshirilmagan qoralama).
