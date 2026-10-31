#!/usr/bin/env python3
"""Kontent kartochkalarini tekshiradi (sxema, taqiqlangan iboralar, tarjimalar, PMID).

Ishlatish:  python3 -I content/tools/validate_content.py content/pilot [--online]
--online: har PMID ni PubMed (NCBI eutils) dan olib, sarlavha va yilni solishtiradi.
"""
import difflib, json, re, sys, time, urllib.request, urllib.error
from pathlib import Path

_FIRST = ["niacinamide", "retinol", "salicylic-acid", "hyaluronic-acid", "ascorbic-acid"]  # birinchi 5 ta tartibi saqlanadi; qolganlari fayllardan avtomatik (alifbo tartibida)
_PILOT = Path(__file__).resolve().parent.parent / "pilot"
SLUGS = _FIRST + sorted(p.stem for p in _PILOT.glob("*.json") if p.stem != "glossary" and p.stem not in _FIRST)
LEVELS = {"A", "B", "C", "insufficient"}
ANNEX = {"none", "II", "III", "IV", "V", "VI", "unverified"}
# Qat'iy da'vo va tibbiy va'dalar: ilova siyosati bo'yicha taqiqlangan.
FORBIDDEN = re.compile(
    r"(\d+\s*%\s*(safe|xavfsiz|безопас)|halal[\s-]*certif|halol\s+sertifikat|safe for all|"
    r"\bcures?\b|\bheals?\b|\bguarantee|kafolat|davolaydi|гарантир|лечит|излечи|suits your skin|"
    r"teringizga mos|подходит вашей коже)", re.I)
ARABIC, CYRILLIC = re.compile(r"[؀-ۿ]"), re.compile(r"[А-Яа-яЁё]")

errors: list[str] = []
def err(slug, msg): errors.append(f"[{slug}] {msg}")

def texts(card):
    yield card.get("summary_en", "")
    for c in card.get("claims", []): yield c.get("text_en", "")
    for tr in card.get("translations", {}).values():
        yield tr.get("summary", "")
        yield from tr.get("claims", {}).values()

def check_card(slug, card):
    for k in ("inci", "slug", "status", "cosing", "eu_regulation", "summary_en", "claims", "translations"):
        if k not in card: err(slug, f"kalit yo'q: {k}")
    if card.get("slug") != slug: err(slug, "slug fayl nomiga mos emas")
    if card.get("status") != "draft": err(slug, "status 'draft' bo'lishi kerak (tasdiq faqat egasidan keyin)")
    eu = card.get("eu_regulation", {})
    if eu.get("annex") not in ANNEX: err(slug, f"annex noto'g'ri: {eu.get('annex')}")
    if eu.get("annex") != "unverified" and not (eu.get("verified") and eu.get("source_url")):
        err(slug, "EU annex aytilgan, lekin verified/source_url yo'q")
    claims = card.get("claims", [])
    if not 3 <= len(claims) <= 5: err(slug, f"da'volar soni 3..5 bo'lishi kerak, hozir {len(claims)}")
    ids = [c.get("id") for c in claims]
    if len(set(ids)) != len(ids): err(slug, "da'vo id takrorlangan")
    for c in claims:
        cid = c.get("id", "?")
        if not str(cid).startswith(slug + "-"): err(slug, f"{cid}: id slug bilan boshlanishi kerak")
        if c.get("evidence_level") not in LEVELS: err(slug, f"{cid}: evidence_level noto'g'ri")
        if not c.get("sources"): err(slug, f"{cid}: manba yo'q")
        for s in c.get("sources", []):
            if s.get("type") == "pubmed" and not re.fullmatch(r"\d{4,9}", str(s.get("pmid", ""))):
                err(slug, f"{cid}: PMID noto'g'ri formatda")
            if not (s.get("title") and s.get("year")): err(slug, f"{cid}: manbada sarlavha/yil yo'q")
        if c.get("evidence_level") in ("A", "B") and not any(s.get("type") in ("pubmed", "regulatory") for s in c.get("sources", [])):
            err(slug, f"{cid}: A/B daraja uchun pubmed yoki regulyator manba kerak")
    tr = card.get("translations", {})
    for lang in ("uz", "ru", "ar"):
        t = tr.get(lang)
        if not t: err(slug, f"tarjima yo'q: {lang}"); continue
        if not t.get("summary"): err(slug, f"{lang}: summary bo'sh")
        missing = set(ids) - set(t.get("claims", {}))
        if missing: err(slug, f"{lang}: tarjimasiz da'volar {sorted(missing)}")
    if "ar" in tr and not ARABIC.search(tr["ar"].get("summary", "")): err(slug, "ar summary arabcha emas")
    if "ru" in tr and not CYRILLIC.search(tr["ru"].get("summary", "")): err(slug, "ru summary kirillcha emas")
    for t in texts(card):
        m = FORBIDDEN.search(t or "")
        if m: err(slug, f"taqiqlangan ibora '{m.group(0)}': {t[:80]}")

def norm(s): return re.sub(r"[^a-z0-9]+", " ", s.lower()).strip()

def check_pmids(slug, card):
    for c in card.get("claims", []):
        for s in c.get("sources", []):
            if s.get("type") != "pubmed": continue
            pmid = str(s["pmid"])
            url = f"https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id={pmid}&retmode=json"
            d, last = None, None
            for attempt in range(6):  # NCBI tezlik cheklovi (429): kutib qayta uriniladi
                try:
                    time.sleep(0.5)
                    d = json.load(urllib.request.urlopen(url, timeout=30))["result"].get(pmid)
                    last = None
                    break
                except urllib.error.HTTPError as e:
                    last = e
                    if e.code != 429: break
                    time.sleep(3 * (attempt + 1))
                except Exception as e:
                    last = e; break
            if last is not None:
                err(slug, f"PMID {pmid}: PubMed'ga ulanib bo'lmadi ({last})"); continue
            if not d or "error" in d: err(slug, f"PMID {pmid} PubMed'da topilmadi"); continue
            ratio = difflib.SequenceMatcher(None, norm(d.get("title", "")), norm(s["title"])).ratio()
            if ratio < 0.8: err(slug, f"PMID {pmid}: sarlavha mos emas ({ratio:.2f}): PubMed='{d.get('title','')[:70]}'")
            pub = re.search(r"\d{4}", d.get("pubdate", "") + " " + d.get("epubdate", ""))
            if pub and abs(int(pub.group(0)) - int(s["year"])) > 1: err(slug, f"PMID {pmid}: yil mos emas ({s['year']} vs {pub.group(0)})")

def main():
    folder, online = Path(sys.argv[1]), "--online" in sys.argv
    n_pmid = 0
    for slug in SLUGS:
        p = folder / f"{slug}.json"
        if not p.exists(): err(slug, "fayl yo'q"); continue
        try: card = json.loads(p.read_text(encoding="utf-8"))
        except Exception as e: err(slug, f"JSON xato: {e}"); continue
        check_card(slug, card)
        n_pmid += sum(1 for c in card.get("claims", []) for s in c.get("sources", []) if s.get("type") == "pubmed")
        if online: check_pmids(slug, card)
    # An'anaviy qo'llanish (tarixiy manbalar): sxema, tarjimalar, taqiqlangan iboralar, PMID.
    tdir = folder / "traditional"
    for p in sorted(tdir.glob("*.json")) if tdir.exists() else []:
        key = f"traditional/{p.stem}"
        try: d = json.loads(p.read_text(encoding="utf-8"))
        except Exception as e: err(key, f"JSON xato: {e}"); continue
        if p.stem != "ibn-sina" and p.stem not in SLUGS: err(key, "bunday kartochka yo'q")
        items = d.get("items", [])
        if not items: err(key, "item yo'q")
        for it in items:
            if not it.get("sources"): err(key, f"{it.get('id')}: manba yo'q")
            for s in it.get("sources", []):
                if not re.fullmatch(r"\d{4,9}", str(s.get("pmid", ""))): err(key, f"{it.get('id')}: PMID noto'g'ri")
            for lang in ("uz", "ru", "ar"):
                if not d.get("translations", {}).get(lang, {}).get(it.get("id")): err(key, f"{it.get('id')}: {lang} tarjima yo'q")
            for t in [it.get("text_en", "")] + [d.get("translations", {}).get(l, {}).get(it.get("id"), "") for l in ("uz", "ru", "ar")]:
                m = FORBIDDEN.search(t or "")
                if m: err(key, f"taqiqlangan ibora '{m.group(0)}'")
                if re.search(r"\b(proven|isbotlangan|доказан)", t or "", re.I): err(key, "an'anaviy matnda 'isbotlangan' so'zi bo'lmasin")
        n_pmid += sum(len(it.get("sources", [])) for it in items)
        if online: check_pmids(key, {"claims": items})
    g = folder / "glossary.json"
    if not g.exists(): err("glossary", "fayl yo'q")
    else:
        try:
            gl = json.loads(g.read_text(encoding="utf-8")); items = gl if isinstance(gl, list) else gl.get("terms", gl)
            if len(items) < 25: err("glossary", f"kamida 25 termin kerak, hozir {len(items)}")
        except Exception as e: err("glossary", f"JSON xato: {e}")
    print(f"PMID soni: {n_pmid}; online tekshiruv: {'ha' if online else 'yo`q'}")
    print("\n".join(errors) if errors else "OK: hamma tekshiruvlar o'tdi")
    sys.exit(1 if errors else 0)

main()
