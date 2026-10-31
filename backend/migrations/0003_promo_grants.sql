-- Admin bergan Pro: email bo'yicha (foydalanuvchi hali ro'yxatdan o'tmagan bo'lishi mumkin).
-- Faqat Firebase tasdiqlagan email shu yozuvdan foydalanadi. email = kichik harflarda.
CREATE TABLE promo_grants (
  email TEXT PRIMARY KEY,
  ends_at TEXT,
  granted_at TEXT NOT NULL DEFAULT (datetime('now'))
);
