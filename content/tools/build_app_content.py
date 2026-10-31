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
NATURAL = {"honey", "aloe-vera", "coconut-oil", "nigella-sativa-oil", "rosehip-oil", "cucumber", "banana", "oat", "green-tea"}

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
}

def build(src: Path):
    items = []
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
            "inci": c["inci"], "slug": slug, "status": c["status"], "category": "natural" if slug in NATURAL else "active", "aliases": ALIASES.get(slug, []),
            "eu": {"annex": c["eu_regulation"]["annex"], "verified": c["eu_regulation"]["verified"]},
            "summary": {"en": c["summary_en"], "uz": uz(tr["uz"]["summary"]),
                        **{l: tr[l]["summary"] for l in ("ru", "ar")}},
            "claims": claims,
        })
    return {"version": 1, "ingredients": items}

if __name__ == "__main__":
    out = build(Path(sys.argv[1]))
    Path(sys.argv[2]).write_text(json.dumps(out, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    n = sum(len(i["claims"]) for i in out["ingredients"])
    print(f"{len(out['ingredients'])} ingredient, {n} da'vo -> {sys.argv[2]}")
