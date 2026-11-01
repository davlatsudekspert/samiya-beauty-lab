// Maxfiylik siyosati, foydalanish shartlari va hisobni o'chirish sahifalari (4 tilda).
// Matn ilovaning HAQIQIY ma'lumot amaliyotiga mos bo'lishi shart: o'zgarganda shu yer ham yangilanadi.

export const CONTACT_EMAIL = "davlatsudekspert@gmail.com";
export const LEGAL_UPDATED = "2026-11-01";
const LANGS = ["uz", "ru", "en", "ar"] as const;
type Lang = (typeof LANGS)[number];
type Page = "privacy" | "terms" | "delete-account";

const T: Record<Lang, Record<Page, { title: string; body: string[] }>> = {
  en: {
    privacy: {
      title: "Privacy Policy",
      body: [
        "This policy explains what the SAMIYA BEAUTY LAB app (\"the app\") collects and why. Contact: {email}.",
        "## Account (optional)",
        "You can use the app as a guest. If you sign in with Google or Apple, sign-in is handled by Google Firebase Authentication, which receives your name, email address and a user identifier from the provider. Our server stores only that user identifier, the time your record was created, and any Pro access linked to it.",
        "## Pro access granted by email",
        "The app owner can grant Pro access to an email address. In that case the email address and the end date are stored on our server until access is removed or your account is deleted.",
        "## Anonymous install counter",
        "To count how many devices use the app, the app sends a random installation ID (not linked to you or your device hardware), the platform (Android, iOS or web), the app version and the time of use. It does not contain your name, email or location.",
        "## Stored only on your phone",
        "Your language, role, skin preferences, avoid list, care routine and journal are stored only on your device. They are not sent to our server. Deleting the account in the app also clears them.",
        "## Camera and photos",
        "When you scan an ingredient list, the photo is read on your device by Google ML Kit text recognition and is not uploaded to our server. Google ML Kit may send anonymous technical and usage diagnostics to Google.",
        "## What we do not do",
        "We do not show ads, sell personal data or use advertising trackers. The content is educational and is not medical advice.",
        "## Service providers",
        "Google Firebase (sign-in) and Cloudflare (our server and database). They process data on our behalf and may store it outside your country.",
        "## Deleting your data",
        "In the app: Profile, then Delete account. This deletes your server data and your sign-in account. You can also email {email} with the subject \"Delete account\".",
        "## Children",
        "The app is not intended for children under 13.",
        "## Changes",
        "We will update this page when our practices change. Last updated: {date}.",
      ],
    },
    terms: {
      title: "Terms of Use",
      body: [
        "By using SAMIYA BEAUTY LAB you agree to these terms. Contact: {email}.",
        "## Information, not medical advice",
        "The app summarises published research and historical sources for education. It does not diagnose, treat or recommend products for your skin. Talk to a qualified professional about medical concerns.",
        "## Content status",
        "Ingredient cards are drafts based on published studies. Translations and EU regulatory data are still being reviewed. Historical and traditional information is not scientific evidence.",
        "## Your responsibility",
        "Check product labels and test new products on a small area of skin. Do not rely on the app as the only source for decisions about your health.",
        "## Accounts and Pro",
        "You may use the app as a guest. Any paid features will be described before purchase. Pro access granted by the app owner can be changed or removed.",
        "## Availability",
        "The app is provided as is. We may change or stop features. Last updated: {date}.",
      ],
    },
    "delete-account": {
      title: "Delete your account",
      body: [
        "## In the app",
        "Open Profile, tap Delete account and confirm. This deletes your data on our server and your sign-in account, and clears the data stored on your phone.",
        "## By email",
        "If you no longer have the app, email {email} with the subject \"Delete account\" from the address you used to sign in. We will delete your data and confirm by email.",
        "## What is deleted",
        "Your user record, Pro access linked to your account or email, and sign-in account. The anonymous install counter does not contain personal data.",
      ],
    },
  },
  uz: {
    privacy: {
      title: "Maxfiylik siyosati",
      body: [
        "Bu siyosat SAMIYA BEAUTY LAB ilovasi (\"ilova\") nimani va nima uchun to‘plashini tushuntiradi. Aloqa: {email}.",
        "## Hisob (ixtiyoriy)",
        "Ilovadan mehmon sifatida foydalanish mumkin. Google yoki Apple orqali kirsangiz, kirishni Google Firebase Authentication bajaradi va u provayderdan ismingiz, email manzilingiz va foydalanuvchi identifikatorini oladi. Bizning serverimiz faqat shu identifikatorni, yozuv yaratilgan vaqtni va unga bog‘langan Pro huquqini saqlaydi.",
        "## Email bo‘yicha berilgan Pro",
        "Ilova egasi email manzilga Pro huquqini berishi mumkin. Bunda email manzil va muddat huquq olib tashlanguncha yoki hisob o‘chirilguncha serverimizda saqlanadi.",
        "## Anonim o‘rnatish hisoblagichi",
        "Ilovadan nechta qurilma foydalanayotganini bilish uchun ilova tasodifiy o‘rnatish identifikatorini (sizga yoki qurilma uskunasiga bog‘lanmagan), platformani (Android, iOS yoki veb), ilova versiyasini va foydalanish vaqtini yuboradi. Unda ismingiz, emailingiz yoki joylashuvingiz yo‘q.",
        "## Faqat telefoningizda saqlanadi",
        "Til, rol, teri afzalliklari, chetlab o‘tish ro‘yxati, parvarish rejasi va kundalik faqat qurilmangizda saqlanadi va serverimizga yuborilmaydi. Ilovada hisobni o‘chirish ularni ham tozalaydi.",
        "## Kamera va rasmlar",
        "Tarkibni skanerlaganingizda rasm qurilmangizning o‘zida Google ML Kit matn tanish vositasi bilan o‘qiladi va serverimizga yuklanmaydi. Google ML Kit Google’ga anonim texnik va foydalanish diagnostikasini yuborishi mumkin.",
        "## Biz nima qilmaymiz",
        "Reklama ko‘rsatmaymiz, shaxsiy ma‘lumotlarni sotmaymiz va reklama kuzatuvchilaridan foydalanmaymiz. Kontent ta‘limiy maqsadda va tibbiy maslahat emas.",
        "## Xizmat ko‘rsatuvchilar",
        "Google Firebase (kirish) va Cloudflare (server va ma‘lumotlar bazasi). Ular ma‘lumotlarni bizning nomimizdan qayta ishlaydi va sizning mamlakatingizdan tashqarida saqlashi mumkin.",
        "## Ma‘lumotlarni o‘chirish",
        "Ilovada: Profil, so‘ng Hisobni o‘chirish. Bu serverdagi ma‘lumotlaringiz va kirish hisobingizni o‘chiradi. {email} manziliga \"Hisobni o‘chirish\" mavzusi bilan yozishingiz ham mumkin.",
        "## Bolalar",
        "Ilova 13 yoshgacha bo‘lgan bolalar uchun mo‘ljallanmagan.",
        "## O‘zgarishlar",
        "Amaliyotimiz o‘zgarsa, bu sahifani yangilaymiz. Oxirgi yangilanish: {date}.",
      ],
    },
    terms: {
      title: "Foydalanish shartlari",
      body: [
        "SAMIYA BEAUTY LAB’dan foydalanish orqali ushbu shartlarga rozilik bildirasiz. Aloqa: {email}.",
        "## Ma‘lumot, tibbiy maslahat emas",
        "Ilova chop etilgan tadqiqotlar va tarixiy manbalarni ta‘lim uchun umumlashtiradi. U tashxis qo‘ymaydi, davolamaydi va teringiz uchun mahsulot tavsiya qilmaydi. Tibbiy masalalar bo‘yicha malakali mutaxassisga murojaat qiling.",
        "## Kontent holati",
        "Ingredient kartochkalari chop etilgan tadqiqotlarga asoslangan qoralamalar. Tarjimalar va EU qonunchilik ma‘lumotlari hali tekshirilmoqda. Tarixiy va an‘anaviy ma‘lumot ilmiy dalil emas.",
        "## Sizning mas‘uliyatingiz",
        "Mahsulot yorlig‘ini tekshiring va yangi vositani avval terining kichik joyida sinab ko‘ring. Sog‘lig‘ingiz bo‘yicha qarorlarda faqat ilovaga tayanmang.",
        "## Hisob va Pro",
        "Ilovadan mehmon sifatida foydalanishingiz mumkin. Pullik imkoniyatlar sotib olishdan oldin tushuntiriladi. Ilova egasi bergan Pro huquqi o‘zgartirilishi yoki olib tashlanishi mumkin.",
        "## Mavjudlik",
        "Ilova \"boricha\" taqdim etiladi. Imkoniyatlarni o‘zgartirishimiz yoki to‘xtatishimiz mumkin. Oxirgi yangilanish: {date}.",
      ],
    },
    "delete-account": {
      title: "Hisobni o‘chirish",
      body: [
        "## Ilovada",
        "Profilni oching, Hisobni o‘chirish tugmasini bosing va tasdiqlang. Bu serverdagi ma‘lumotlaringiz va kirish hisobingizni o‘chiradi hamda telefoningizdagi ma‘lumotlarni tozalaydi.",
        "## Email orqali",
        "Agar ilova endi sizda bo‘lmasa, kirishda ishlatgan manzilingizdan {email} ga \"Hisobni o‘chirish\" mavzusi bilan yozing. Ma‘lumotlaringizni o‘chirib, email orqali tasdiqlaymiz.",
        "## Nima o‘chadi",
        "Foydalanuvchi yozuvingiz, hisobingiz yoki emailingizga bog‘langan Pro huquqi va kirish hisobingiz. Anonim o‘rnatish hisoblagichida shaxsiy ma‘lumot yo‘q.",
      ],
    },
  },
  ru: {
    privacy: {
      title: "Политика конфиденциальности",
      body: [
        "Эта политика объясняет, какие данные собирает приложение SAMIYA BEAUTY LAB («приложение») и зачем. Контакт: {email}.",
        "## Аккаунт (необязательно)",
        "Приложением можно пользоваться как гость. При входе через Google или Apple вход выполняет Google Firebase Authentication, который получает от провайдера ваше имя, адрес электронной почты и идентификатор пользователя. Наш сервер хранит только этот идентификатор, время создания записи и связанный с ней доступ Pro.",
        "## Pro, выданный по email",
        "Владелец приложения может выдать доступ Pro по адресу электронной почты. В этом случае адрес и срок хранятся на нашем сервере до отзыва доступа или удаления аккаунта.",
        "## Анонимный счётчик установок",
        "Чтобы считать, сколько устройств пользуется приложением, оно отправляет случайный идентификатор установки (не связанный с вами или оборудованием устройства), платформу (Android, iOS или веб), версию приложения и время использования. В нём нет вашего имени, email или местоположения.",
        "## Хранится только на вашем телефоне",
        "Язык, роль, предпочтения кожи, список исключений, уход и дневник хранятся только на устройстве и не отправляются на наш сервер. Удаление аккаунта в приложении также очищает их.",
        "## Камера и фото",
        "При сканировании состава фото распознаётся на устройстве с помощью Google ML Kit и не загружается на наш сервер. Google ML Kit может отправлять в Google анонимную техническую диагностику и статистику использования.",
        "## Чего мы не делаем",
        "Мы не показываем рекламу, не продаём персональные данные и не используем рекламные трекеры. Контент носит образовательный характер и не является медицинской рекомендацией.",
        "## Поставщики услуг",
        "Google Firebase (вход) и Cloudflare (наш сервер и база данных). Они обрабатывают данные по нашему поручению и могут хранить их за пределами вашей страны.",
        "## Удаление данных",
        "В приложении: Профиль, затем Удалить аккаунт. Это удаляет данные на сервере и аккаунт для входа. Также можно написать на {email} с темой «Удалить аккаунт».",
        "## Дети",
        "Приложение не предназначено для детей младше 13 лет.",
        "## Изменения",
        "Мы обновим эту страницу при изменении практики. Последнее обновление: {date}.",
      ],
    },
    terms: {
      title: "Условия использования",
      body: [
        "Пользуясь SAMIYA BEAUTY LAB, вы соглашаетесь с этими условиями. Контакт: {email}.",
        "## Информация, а не медицинская рекомендация",
        "Приложение обобщает опубликованные исследования и исторические источники в образовательных целях. Оно не ставит диагнозов, не лечит и не подбирает средства для вашей кожи. По медицинским вопросам обращайтесь к квалифицированному специалисту.",
        "## Статус контента",
        "Карточки ингредиентов являются черновиками на основе опубликованных исследований. Переводы и данные регулирования ЕС ещё проверяются. Историческая и традиционная информация не является научным доказательством.",
        "## Ваша ответственность",
        "Проверяйте этикетки и тестируйте новые средства на небольшом участке кожи. Не полагайтесь на приложение как на единственный источник решений о здоровье.",
        "## Аккаунт и Pro",
        "Приложением можно пользоваться как гость. Платные функции описываются до покупки. Доступ Pro, выданный владельцем, может быть изменён или отозван.",
        "## Доступность",
        "Приложение предоставляется «как есть». Мы можем изменять или прекращать функции. Последнее обновление: {date}.",
      ],
    },
    "delete-account": {
      title: "Удаление аккаунта",
      body: [
        "## В приложении",
        "Откройте Профиль, нажмите Удалить аккаунт и подтвердите. Это удаляет данные на нашем сервере и аккаунт для входа, а также очищает данные на телефоне.",
        "## По email",
        "Если приложения у вас больше нет, напишите на {email} с темой «Удалить аккаунт» с адреса, который вы использовали для входа. Мы удалим данные и подтвердим по email.",
        "## Что удаляется",
        "Запись пользователя, доступ Pro, связанный с аккаунтом или email, и аккаунт для входа. Анонимный счётчик установок не содержит персональных данных.",
      ],
    },
  },
  ar: {
    privacy: {
      title: "سياسة الخصوصية",
      body: [
        "توضّح هذه السياسة ما يجمعه تطبيق SAMIYA BEAUTY LAB («التطبيق») ولماذا. للتواصل: {email}.",
        "## الحساب (اختياري)",
        "يمكنك استخدام التطبيق كضيف. إذا سجّلت الدخول عبر Google أو Apple فإن تسجيل الدخول يتم عبر Google Firebase Authentication الذي يتلقى من مزوّد الخدمة اسمك وبريدك الإلكتروني ومعرّف المستخدم. يحفظ خادمنا هذا المعرّف فقط ووقت إنشاء السجل وأي وصول Pro مرتبط به.",
        "## وصول Pro الممنوح عبر البريد الإلكتروني",
        "يمكن لمالك التطبيق منح وصول Pro لعنوان بريد إلكتروني. في هذه الحالة يُحفظ العنوان وتاريخ الانتهاء على خادمنا حتى إزالة الوصول أو حذف الحساب.",
        "## عدّاد التثبيت المجهول",
        "لمعرفة عدد الأجهزة التي تستخدم التطبيق، يرسل التطبيق معرّف تثبيت عشوائيًا (غير مرتبط بك أو بعتاد جهازك) والمنصة (Android أو iOS أو الويب) وإصدار التطبيق ووقت الاستخدام. لا يتضمن اسمك أو بريدك أو موقعك.",
        "## محفوظ على هاتفك فقط",
        "اللغة والدور وتفضيلات البشرة وقائمة التجنّب وروتين العناية والمذكرات محفوظة على جهازك فقط ولا تُرسل إلى خادمنا. حذف الحساب في التطبيق يمسحها أيضًا.",
        "## الكاميرا والصور",
        "عند مسح قائمة المكوّنات تُقرأ الصورة على جهازك بواسطة Google ML Kit ولا تُرفع إلى خادمنا. قد يرسل Google ML Kit إلى Google بيانات تشخيصية تقنية واستخدامية مجهولة.",
        "## ما لا نفعله",
        "لا نعرض إعلانات ولا نبيع البيانات الشخصية ولا نستخدم أدوات تتبع إعلانية. المحتوى تعليمي وليس نصيحة طبية.",
        "## مزوّدو الخدمة",
        "Google Firebase (تسجيل الدخول) وCloudflare (خادمنا وقاعدة البيانات). يعالجون البيانات نيابةً عنا وقد يخزنونها خارج بلدك.",
        "## حذف بياناتك",
        "في التطبيق: الملف الشخصي ثم حذف الحساب. يحذف ذلك بياناتك على الخادم وحساب تسجيل الدخول. ويمكنك أيضًا مراسلة {email} بعنوان «حذف الحساب».",
        "## الأطفال",
        "التطبيق غير موجّه للأطفال دون 13 عامًا.",
        "## التغييرات",
        "سنحدّث هذه الصفحة عند تغيّر ممارساتنا. آخر تحديث: {date}.",
      ],
    },
    terms: {
      title: "شروط الاستخدام",
      body: [
        "باستخدامك SAMIYA BEAUTY LAB فإنك توافق على هذه الشروط. للتواصل: {email}.",
        "## معلومات وليست نصيحة طبية",
        "يلخّص التطبيق الدراسات المنشورة والمصادر التاريخية لأغراض تعليمية. لا يشخّص ولا يعالج ولا يوصي بمنتجات لبشرتك. استشيري مختصًا مؤهلًا في المسائل الطبية.",
        "## حالة المحتوى",
        "بطاقات المكوّنات مسودات مبنية على دراسات منشورة. الترجمات وبيانات التشريع الأوروبي قيد المراجعة. المعلومات التاريخية والتقليدية ليست دليلًا علميًا.",
        "## مسؤوليتك",
        "راجعي ملصقات المنتجات وجرّبي أي منتج جديد على منطقة صغيرة من الجلد. لا تعتمدي على التطبيق مصدرًا وحيدًا لقرارات صحتك.",
        "## الحساب وPro",
        "يمكنك استخدام التطبيق كضيف. تُوضَّح أي ميزات مدفوعة قبل الشراء. يمكن تغيير وصول Pro الممنوح من المالك أو إزالته.",
        "## التوفر",
        "يُقدَّم التطبيق «كما هو». قد نغيّر الميزات أو نوقفها. آخر تحديث: {date}.",
      ],
    },
    "delete-account": {
      title: "حذف الحساب",
      body: [
        "## داخل التطبيق",
        "افتحي الملف الشخصي واضغطي حذف الحساب ثم أكّدي. يحذف ذلك بياناتك على خادمنا وحساب تسجيل الدخول ويمسح البيانات المحفوظة على هاتفك.",
        "## عبر البريد الإلكتروني",
        "إذا لم يعد التطبيق لديك، راسلي {email} بعنوان «حذف الحساب» من العنوان الذي استخدمته لتسجيل الدخول. سنحذف بياناتك ونؤكد ذلك بالبريد.",
        "## ما الذي يُحذف",
        "سجل المستخدم ووصول Pro المرتبط بحسابك أو بريدك وحساب تسجيل الدخول. عدّاد التثبيت المجهول لا يحتوي على بيانات شخصية.",
      ],
    },
  },
};

const esc = (s: string) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");

export function legalPage(page: Page, langParam: string | null): Response {
  const lang: Lang = (LANGS as readonly string[]).includes(langParam ?? "") ? (langParam as Lang) : "en";
  const { title, body } = T[lang][page];
  const rtl = lang === "ar";
  const fill = (s: string) => esc(s).replace(/\{email\}/g, `<a href="mailto:${CONTACT_EMAIL}">${CONTACT_EMAIL}</a>`).replace(/\{date\}/g, LEGAL_UPDATED);
  const html = body.map((p) => (p.startsWith("## ") ? `<h2>${fill(p.slice(3))}</h2>` : `<p>${fill(p)}</p>`)).join("\n");
  const nav = LANGS.map((l) => `<a href="?lang=${l}"${l === lang ? ' aria-current="page"' : ""}>${l.toUpperCase()}</a>`).join(" ");
  const doc = `<!doctype html><html lang="${lang}" dir="${rtl ? "rtl" : "ltr"}"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${esc(title)} · SAMIYA BEAUTY LAB</title>
<style>body{margin:0;background:#F7F3F1;color:#2A1B22;font:17px/1.65 Georgia,"Times New Roman",serif}main{max-width:720px;margin:0 auto;padding:28px 18px 60px}
h1{font-weight:600;color:#3B1E2B;font-size:34px;line-height:1.15;margin:8px 0 4px}h2{color:#3B1E2B;font-size:21px;margin:28px 0 6px}
.brand{font:600 13px/1 system-ui,sans-serif;letter-spacing:.08em;color:#8E4A5E}.rule{width:64px;height:1px;background:#B08D57;margin:14px 0 18px}
nav{font:14px system-ui,sans-serif;margin:0 0 18px}nav a{color:#8E4A5E;margin-inline-end:10px}nav a[aria-current]{font-weight:700;color:#3B1E2B}a{color:#8E4A5E}</style></head>
<body><main><div class="brand">SAMIYA BEAUTY LAB</div><h1>${esc(title)}</h1><div class="rule"></div><nav>${nav}</nav>${html}</main></body></html>`;
  return new Response(doc, { headers: { "content-type": "text/html; charset=utf-8", "cache-control": "public, max-age=3600" } });
}
