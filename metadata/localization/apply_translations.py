#!/usr/bin/env python3
"""Fills BlackSwan/Localizable.xcstrings with the translations in translations.py.

Run after Xcode (or `xcstringstool sync`) has added new keys to the catalog.
Prints any key that still has no translation, and any translation whose
format specifiers don't match the source.
"""

import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from translations import DO_NOT_TRANSLATE, T  # noqa: E402

LANGUAGES = ["de", "es", "fr", "it"]
CATALOG = Path(__file__).resolve().parents[2] / "BlackSwan" / "Localizable.xcstrings"
SPECIFIER = re.compile(r"%(?:lld|@|%)")

catalog = json.loads(CATALOG.read_text())
missing, bad = [], []

for key, entry in catalog["strings"].items():
    if key in DO_NOT_TRANSLATE:
        entry["shouldTranslate"] = False
        entry.pop("localizations", None)
        continue
    values = T.get(key)
    if values is None:
        missing.append(key)
        continue
    localizations = entry.setdefault("localizations", {})
    for language, value in zip(LANGUAGES, values):
        if sorted(SPECIFIER.findall(value)) != sorted(SPECIFIER.findall(key)):
            bad.append((language, key, value))
        localizations[language] = {"stringUnit": {"state": "translated", "value": value}}

CATALOG.write_text(json.dumps(catalog, ensure_ascii=False, indent=2, sort_keys=True) + "\n")

for key in missing:
    print(f"missing: {key!r}")
for language, key, value in bad:
    print(f"specifier mismatch [{language}]: {key!r} -> {value!r}")
print(f"{len(catalog['strings'])} keys, {len(missing)} missing, {len(bad)} specifier mismatches")
