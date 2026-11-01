#!/usr/bin/env python3
"""content/pilot kartochkalaridan ilova uchun ixcham ma'lumot faylini yasaydi.

Ishlatish:  python3 -I content/tools/build_app_content.py content/pilot mobile/assets/content/ingredients.json
Yagona manba: content/pilot/*.json. Chiqish faylini qo'lda tahrirlamang.
"""
import json, sys
from pathlib import Path

def uz(t: str) -> str:
    """O'zbek lotin: tutuq/oʻ-gʻ belgisi interfeys matnlari bilan bir xil (‘)."""
    return t.replace("'", "\u2018").replace("\u2019", "\u2018")

_FIRST = ["niacinamide", "hyaluronic-acid", "salicylic-acid", "ascorbic-acid", "retinol"]  # birinchi 5 ta tartibi saqlanadi; qolganlari fayllardan avtomatik (alifbo tartibida)
_PILOT = Path(__file__).resolve().parent.parent / "pilot"
SLUGS = _FIRST + sorted(p.stem for p in _PILOT.glob("*.json") if p.stem != "glossary" and p.stem not in _FIRST)
LANGS = ["en", "uz", "ru", "ar"]
# Faqat bir xil modda ekanligi aniq nomlar (taxmin qilinmaydi).
# Tabiiy/o'simlik asosli ingredientlar (ilovada alohida bo'lim). Qolganlari "faol modda".
NATURAL = {"honey", "aloe-vera", "coconut-oil", "nigella-sativa-oil", "rosehip-oil", "cucumber", "banana", "oat", "green-tea",
           "olive-oil", "chamomile", "rose-water", "turmeric"}
PRACTICE = {"facial-massage", "gua-sha"}          # parvarish usullari (ingredient emas)
CAUTION = {"lemon-juice", "baking-soda"}          # uy vositalari: zarar hodisalari haqida ogohlantirish

# Yangi kartochkalar uchun metama'lumot: content/tools/meta_*.json (slug -> category, names, aliases).
META = {}
for _m in sorted(Path(__file__).resolve().parent.glob("meta_*.json")):
    META.update(json.loads(_m.read_text(encoding="utf-8")))
for _s, _v in META.items():
    {"natural": NATURAL, "practice": PRACTICE, "caution": CAUTION}.get(_v.get("category"), set()).add(_s)

def category(slug):
    return "natural" if slug in NATURAL else "practice" if slug in PRACTICE else "caution" if slug in CAUTION else "active"

# Tushunarli nomlar (uz, ru, en, ar): faqat INCI nomi tushunarsiz bo'lgan tabiiy/usul/ehtiyot kartochkalari uchun.
NAMES = {
    "honey": ("Asal", "Мёд", "Honey", "عسل"),
    "aloe-vera": ("Aloe vera", "Алоэ вера", "Aloe vera", "الصبار"),
    "coconut-oil": ("Kokos moyi", "Кокосовое масло", "Coconut oil", "زيت جوز الهند"),
    "nigella-sativa-oil": ("Qora zira moyi", "Масло чёрного тмина", "Black seed oil", "زيت حبة البركة"),
    "rosehip-oil": ("Itburun (rosehip) moyi", "Масло шиповника", "Rosehip oil", "زيت ثمر الورد البري"),
    "cucumber": ("Bodring", "Огурец", "Cucumber", "الخيار"),
    "banana": ("Banan", "Банан", "Banana", "الموز"),
    "oat": ("Suli", "Овёс", "Oat (colloidal oatmeal)", "الشوفان"),
    "green-tea": ("Yashil choy", "Зелёный чай", "Green tea", "الشاي الأخضر"),
    "olive-oil": ("Zaytun moyi", "Оливковое масло", "Olive oil", "زيت الزيتون"),
    "chamomile": ("Romashka", "Ромашка", "Chamomile", "البابونج"),
    "rose-water": ("Atirgul suvi", "Розовая вода", "Rose water", "ماء الورد"),
    "turmeric": ("Zarchava (kurkuma)", "Куркума", "Turmeric", "الكركم"),
    "lemon-juice": ("Limon sharbati", "Лимонный сок", "Lemon juice", "عصير الليمون"),
    "baking-soda": ("Ichimlik sodasi", "Пищевая сода", "Baking soda", "بيكربونات الصوديوم (صودا الخبز)"),
    "facial-massage": ("Yuz massaji", "Массаж лица", "Facial massage", "تدليك الوجه"),
    "gua-sha": ("Gua sha", "Гуаша", "Gua sha", "الغواشا"),
}


ALIASES = {
    "niacinamide": ["Nicotinamide", "Vitamin B3"],
    "salicylic-acid": ["2-Hydroxybenzoic Acid"],
    "ascorbic-acid": ["L-Ascorbic Acid", "Vitamin C"],
    "glycerin": ["Glycerol"],
    # Tabiiy ingredientlar: faqat bir xil modda uchun umumiy nom yoki yorliqdagi rasmiy yozuv shakli (taxmin yo'q;
    # masalan "Aloe Barbadensis Leaf Extract" boshqa modda hisoblanadi va bu yerga kiritilmagan).
    "honey": ["Honey"],
    "aloe-vera": ["Aloe Vera"],
    "coconut-oil": ["Coconut Oil", "Cocos Nucifera (Coconut) Oil"],
    "nigella-sativa-oil": ["Black Seed Oil", "Nigella Sativa Oil"],
    "rosehip-oil": ["Rosehip Oil"],
    "cucumber": ["Cucumber", "Cucumis Sativus (Cucumber) Fruit Extract"],
    "banana": ["Banana", "Musa Sapientum (Banana) Fruit Extract"],
    "oat": ["Oatmeal", "Colloidal Oatmeal", "Avena Sativa (Oat) Kernel Flour"],
    "green-tea": ["Green Tea", "Camellia Sinensis (Green Tea) Leaf Extract"],
    "olive-oil": ["Olive Oil", "Olea Europaea (Olive) Fruit Oil"],
    "chamomile": ["Chamomile", "Chamomilla Recutita (Matricaria) Flower Extract"],
    "rose-water": ["Rose Water", "Rosa Damascena Flower Water"],
    "turmeric": ["Turmeric", "Curcumin"],
    "lemon-juice": ["Lemon Juice", "Citrus Limon (Lemon) Juice"],
    "baking-soda": ["Baking Soda"],
}

def _trad_items(d):
    """An'anaviy qo'llanish yozuvlari: matn 4 tilda, faqat PubMed manbalari bilan."""
    tr = d["translations"]
    out = []
    for it in d["items"]:
        out.append({
            "id": it["id"], **({"tradition": it["tradition"]} if it.get("tradition") else {}),
            "text": {"en": it["text_en"], "uz": uz(tr["uz"][it["id"]]), "ru": tr["ru"][it["id"]], "ar": tr["ar"][it["id"]]},
            "sources": [{"pmid": s["pmid"], "title": s["title"], "year": s["year"], "url": f"https://pubmed.ncbi.nlm.nih.gov/{s['pmid']}/"}
                        for s in it["sources"] if s.get("type") == "pubmed"],
        })
    return out

ACADEMY_ORDER = ["skin", "inci", "spf", "moist", "hygiene", "safety"]

def _loc(d):
    """{en,uz,ru,ar} matn; o'zbekcha tutuq belgisi normallashtiriladi."""
    return {l: (uz(d[l]) if l == "uz" else d[l]) for l in LANGS}

def _src(s):
    pmid = s.get("pmid")
    url = s.get("url") or (f"https://pubmed.ncbi.nlm.nih.gov/{pmid}/" if pmid else None)
    return {k: v for k, v in {"pmid": pmid, "title": s.get("title"), "publisher": s.get("publisher"), "year": s.get("year"), "url": url}.items() if v}

def _lesson(d, lid):
    return {
        "id": lid, "status": d.get("status", "draft"),
        "title": _loc(d["title"]), "summary": _loc(d["summary"]),
        "sections": [{"heading": _loc(x["heading"]), "text": _loc(x["text"])} for x in d["sections"]],
        "keyPoints": [_loc(x) for x in d["key_points"]],
        "quiz": [{"question": _loc(q["question"]), "options": [_loc(o) for o in q["options"]], "correct": q["correct"]}
                 for q in d.get("quiz", [])],
        "sources": [_src(s) for s in d.get("sources", [])],
    }

def build(src: Path):
    items = []
    trad_dir = src / "traditional"
    for slug in SLUGS:
        c = json.loads((src / f"{slug}.json").read_text(encoding="utf-8"))
        tr = c["translations"]
        claims = []
        for cl in c["claims"]:
            text = {"en": cl["text_en"], "uz": uz(tr["uz"]["claims"][cl["id"]]),
                    **{l: tr[l]["claims"][cl["id"]] for l in ("ru", "ar")}}
            sources = [{"pmid": s.get("pmid"), "doi": s.get("doi"), "title": s["title"], "year": s["year"],
                        "url": f"https://pubmed.ncbi.nlm.nih.gov/{s['pmid']}/"}
                       for s in cl["sources"] if s.get("type") == "pubmed"]
            claims.append({"id": cl["id"], "level": cl["evidence_level"], "studyType": cl["study_type"],
                           "text": text, "sources": sources})
        items.append({
            "inci": c["inci"], "slug": slug, "status": c["status"], "category": category(slug), **({"names": dict(zip(("uz", "ru", "en", "ar"), NAMES[slug]))} if slug in NAMES else {"names": dict(zip(("uz", "ru", "en", "ar"), META[slug]["names"]))} if META.get(slug, {}).get("names") else {}), "aliases": ALIASES.get(slug, META.get(slug, {}).get("aliases", [])),
            "eu": {"annex": c["eu_regulation"]["annex"], "verified": c["eu_regulation"]["verified"]},
            "summary": {"en": c["summary_en"], "uz": uz(tr["uz"]["summary"]),
                        **{l: tr[l]["summary"] for l in ("ru", "ar")}},
            "claims": claims,
            **({"traditional": _trad_items(json.loads((trad_dir / f"{slug}.json").read_text(encoding="utf-8")))}
               if (trad_dir / f"{slug}.json").exists() else {}),
        })
    out = {"version": 1, "ingredients": items}
    acad = src.parent / "academy"
    if acad.exists():
        out["academy"] = [_lesson(json.loads((acad / f"{i}.json").read_text(encoding="utf-8")), i)
                          for i in ACADEMY_ORDER if (acad / f"{i}.json").exists()]
    ibn = trad_dir / "ibn-sina.json"
    if ibn.exists():
        d = json.loads(ibn.read_text(encoding="utf-8"))
        out["ibnSina"] = {"title": {**d["title"], "uz": uz(d["title"]["uz"])}, "items": _trad_items(d)}
    return out

if __name__ == "__main__":
    out = build(Path(sys.argv[1]))
    Path(sys.argv[2]).write_text(json.dumps(out, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    n = sum(len(i["claims"]) for i in out["ingredients"])
    print(f"{len(out['ingredients'])} ingredient, {n} da'vo -> {sys.argv[2]}")
