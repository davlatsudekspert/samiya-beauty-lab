#!/usr/bin/env bash
# Secret qiymatini faylga yozadi. base64 bo'lsa dekodlaydi (bo'shliq va \r tozalanadi),
# xom matn (JSON, XML, PEM) bo'lsa o'zini yozadi. Qiymat HECH QACHON chop etilmaydi.
# Ishlatish: write_secret.sh "$VALUE" chiqish_fayli [json|xml|none]
set -euo pipefail
value="${1-}"; out="$2"; kind="${3:-none}"
if [ -z "$value" ]; then echo "::error::Secret bo'sh ($out)"; exit 1; fi
clean="$(printf '%s' "$value" | tr -d '\r')"
case "$clean" in
  '{'*|'<'*|'-----BEGIN'*) printf '%s\n' "$clean" > "$out" ;;
  *) if ! printf '%s' "$clean" | tr -d ' \n\t' | base64 --decode > "$out" 2>/dev/null; then
       echo "::error::Secret base64 emas va xom matnga ham o'xshamaydi ($out). Qayta nusxalang (docs/SECRETS.md)."; exit 1
     fi ;;
esac
case "$kind" in
  json) python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$out" 2>/dev/null || { echo "::error::$out yaroqli JSON emas"; exit 1; } ;;
  xml)  python3 -c "import plistlib,sys; plistlib.load(open(sys.argv[1],'rb'))" "$out" 2>/dev/null || { echo "::error::$out yaroqli plist emas"; exit 1; } ;;
esac
echo "$out yozildi ($(wc -c < "$out") bayt)"
