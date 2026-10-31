-- Phase 0 sxemasi. id = Firebase Auth uid (token serverda tekshirilgandan keyin).
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  locale TEXT NOT NULL DEFAULT 'uz' CHECK (locale IN ('uz','ru','en','ar')),
  consent_revision INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  deleted_at TEXT
);

-- Pro huquqlari faqat serverda tekshirilgan manbalardan (RevenueCat webhook / promo). Klient yozolmaydi.
CREATE TABLE entitlements (
  user_id TEXT NOT NULL REFERENCES users(id),
  product TEXT NOT NULL,
  provider TEXT NOT NULL CHECK (provider IN ('apple','google','revenuecat','promo')),
  provider_transaction_id TEXT,
  verified_at TEXT NOT NULL,
  ends_at TEXT,
  PRIMARY KEY (user_id, product, provider)
);

-- AI kunlik kvota (Asia/Tashkent kuni) va idempotentlik: qayta urinish kvotani ikki marta sarflamaydi.
CREATE TABLE ai_daily_usage (
  user_id TEXT NOT NULL,
  day TEXT NOT NULL,
  count INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (user_id, day)
);
CREATE TABLE ai_request_idempotency (
  user_id TEXT NOT NULL,
  request_id TEXT NOT NULL,
  day TEXT NOT NULL,
  PRIMARY KEY (user_id, request_id)
);

-- Kontent (Phase 0 pilot sxemasi; to'liq sxema C-trekda): har da'vo manba bilan.
CREATE TABLE ingredients (
  inci TEXT PRIMARY KEY,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','verified')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
