import { describe, expect, it } from "vitest";
import worker from "../src/index";
import { CONTACT_EMAIL } from "../src/legal";

const get = (path: string) => worker.fetch(new Request(`https://api.test${path}`), {} as never);

describe("huquqiy sahifalar", () => {
  for (const page of ["privacy", "terms", "delete-account"]) {
    for (const lang of ["uz", "ru", "en", "ar"]) {
      it(`${page} ${lang}: HTML, aloqa emaili bilan`, async () => {
        const r = await get(`/${page}?lang=${lang}`);
        expect(r.status).toBe(200);
        expect(r.headers.get("content-type")).toContain("text/html");
        const h = await r.text();
        expect(h).toContain(`lang="${lang}"`);
        if (page !== "terms" || lang) expect(h).toContain(CONTACT_EMAIL);
        if (lang === "ar") expect(h).toContain('dir="rtl"');
      });
    }
  }
  it("noma'lum til: inglizcha", async () => {
    const h = await (await get("/privacy?lang=xx")).text();
    expect(h).toContain('lang="en"');
  });
  it("til parametri HTML'ga kiritilmaydi (XSS yo'q)", async () => {
    const h = await (await get('/privacy?lang="><script>alert(1)</script>')).text();
    expect(h).not.toContain("<script>alert(1)");
  });
  it("maxfiylik siyosati haqiqiy amaliyotni aytadi: reklama yo'q, kundalik faqat telefonda, kamera qurilmada", async () => {
    const h = await (await get("/privacy?lang=en")).text();
    expect(h).toContain("do not show ads");
    expect(h).toContain("stored only on your device");
    expect(h).toContain("not uploaded to our server");
  });
  it("POST: 405", async () => {
    const r = await worker.fetch(new Request("https://api.test/privacy", { method: "POST" }), {} as never);
    expect(r.status).toBe(405);
  });
});
