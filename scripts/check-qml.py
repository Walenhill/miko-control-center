#!/usr/bin/env python3
"""Qt 6 syntax validation. Runtime imports are tested by smoke.sh separately."""
import json
from pathlib import Path
import shutil
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
candidates = [shutil.which("qmllint6"), "/usr/lib/qt6/bin/qmllint", shutil.which("qmllint")]
compiler = None
for candidate in candidates:
    if candidate and Path(candidate).is_file():
        version = subprocess.run([candidate, "--version"], capture_output=True, text=True)
        if "qmllint 6." in version.stdout + version.stderr:
            compiler = candidate
            break
if not compiler:
    sys.exit("Qt 6 qmllint is required (usually provided by qt6-declarative)")

files = sorted((root / "src").rglob("*.qml"))
result = subprocess.run([compiler, "--ignore-settings", "--json", "-", *map(str, files)],
                        capture_output=True, text=True)
try:
    report = json.loads(result.stdout)
except ValueError:
    sys.exit("qmllint did not return diagnostics: " + result.stderr)
if len(report.get("files", [])) != len(files):
    sys.exit("qmllint did not inspect every QML file")
errors = []
for file in report["files"]:
    warnings = file.get("warnings", [])
    if not file.get("success") and not warnings:
        errors.append(file["filename"] + ": lint failed without diagnostics")
    for warning in warnings:
        if warning.get("id") == "syntax" or warning.get("type") in ("error", "critical"):
            errors.append(f'{file["filename"]}:{warning.get("line", 0)}: {warning["message"]}')
if errors:
    sys.exit("\n".join(errors))
print(f"[ok] Qt 6 QML syntax ({len(files)} files); runtime imports require scripts/smoke.sh")
