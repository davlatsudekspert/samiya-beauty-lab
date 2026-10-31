-- Anonim o'rnatish hisoblagichi: tasodifiy ID (qurilma/shaxsga bog'lanmagan), platforma, versiya.
-- Do'kondagi yuklab olishlar soni EMAS: ilova kamida bir marta ochilgan o'rnatishlar.
CREATE TABLE installs (
  id TEXT PRIMARY KEY,
  platform TEXT NOT NULL CHECK (platform IN ('android','ios','web')),
  app_version TEXT NOT NULL DEFAULT 'unknown',
  first_seen TEXT NOT NULL DEFAULT (datetime('now')),
  last_seen TEXT NOT NULL DEFAULT (datetime('now')),
  opens INTEGER NOT NULL DEFAULT 1
);
CREATE INDEX installs_last_seen ON installs(last_seen);
