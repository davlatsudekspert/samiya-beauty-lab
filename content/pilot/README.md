# Kontent pilot (5 ingredient, 4 til) - HOLAT: DRAFT

Barcha kartochkalar `status: draft`. Hech biri "tasdiqlangan" emas va ilovada "ekspert tasdiqlagan" deb ko'rsatilmaydi.

## Nima tekshirilgan
- Har da'vo PubMed manbasiga bog'langan; PMID, sarlavha va yil validator (`content/tools/validate_content.py --online`) bilan PubMed'ning o'zidan solishtirilgan.
- Qo'lda tanlab tekshirilgan (annotatsiya bilan): niacinamide-2, niacinamide-3.

## Nima TEKSHIRILMAGAN (reliz oldidan majburiy)
- **EU regulyatsiyasi va CosIng**: barcha 5 kartochkada `annex: unverified`, `cosing.functions: []`. EUR-Lex va CosIng bu muhitdan o'qilmadi. Retinol va salitsil kislota EU'da cheklovlarga ega bo'lishi mumkin, rasmiy manbadan (EUR-Lex, CosIng) qo'lda tekshirilishi kerak.
- Tarjimalar (uz, ru, ar) mashina qoralamasi; ayniqsa arabchani ona tili egasi ko'rib chiqishi kerak.
- Da'voning manbaga to'liq mosligi validator tomonidan tekshirilmaydi (u faqat sarlavha/yilni solishtiradi); to'liq tekshiruv qo'lda.

## Mazmun doirasi qoidasi (ko'rib chiqish natijasi)
Kosmetika ta'limi ilovasida **dori vositasi yoki tibbiy/kosmetik protsedura** haqidagi tadqiqotlar ishlatilmaydi. Shu sabab olib tashlangan da'volar:
- `niacinamide-5`: aktinik keratoz, fluorouracil bilan solishtirish (dori bilan davolash);
- `salicylic-acid-2`: kimyoviy pilinglar (professional protsedura);
- `ascorbic-acid-4`: lazer protsedurasidan keyingi qizarish.

## Ochiq savollar (egasi/kuzatuvchi qarori)
- Ba'zi sharhlar PubMed'da "Review" deb belgilangan, lekin o'zini tizimli (PRISMA) deb ta'riflaydi; darajasi A. Qat'iyroq bo'lish uchun B ga tushirish mumkin.
- Akne/melazma/pigmentatsiya haqidagi da'volar "tadqiqotlarda o'rganilgan" shaklida; ilovada har doim "tibbiy maslahat emas" izohi bilan ko'rsatilsin.
- `hyaluronic-acid-1` hikoyaviy sharh (`narrative review`, daraja C): validator bu qiymatni tekshirmaydi; sxemaga qo'shish kerak.
