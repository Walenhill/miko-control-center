#!/usr/bin/env python3
"""Check each literal, catalog entry and named placeholder, including multiline calls."""
import json
from pathlib import Path
import re
import sys

root = Path(__file__).resolve().parents[1] / "src"
catalog = json.loads((root / "controlcenter/i18n/en_US.json").read_text())
errors = []
keys = set()
# Skip comments first, without confusing comment markers inside string literals.
tokens = re.compile(r'//[^\n]*|/\*[\s\S]*?\*/|`(?:[^`\\]|\\.)*`|"(?:[^"\\\n]|\\.)*"|\'(?:[^\'\\\n]|\\.)*\'')
for file in root.rglob("*.qml"):
    if file.name == "I18n.qml":
        continue
    source = file.read_text()
    for match in tokens.finditer(source):
        raw = match.group()
        if not raw.startswith('"'):
            continue
        try:
            value = json.loads(raw)
        except ValueError:
            continue  # JavaScript escapes in command/data strings are not JSON escapes.
        translated = re.search(r'I18n\.tr\(\s*$', source[:match.start()])
        line = source.count("\n", 0, match.start()) + 1
        if translated:
            keys.add(value)
            translation = catalog.get(value)
            if not isinstance(translation, str) or not translation:
                errors.append(f"{file.name}:{line}: missing English: {value}")
            elif set(re.findall(r'\{\w+\}', value)) != set(re.findall(r'\{\w+\}', translation)):
                errors.append(f"{file.name}:{line}: mismatched placeholders: {value}")
        elif re.search('[А-Яа-яЁё]', value):
            # A device-name matching token is data, not text displayed to users.
            if file.name == "SoundDeviceCard.qml" and value == "наушник":
                continue
            errors.append(f"{file.name}:{line}: untranslated literal: {value}")
if errors:
    sys.exit("\n".join(errors))
print(f"[ok] i18n coverage and placeholders ({len(keys)} source keys)")
