#!/usr/bin/env bash

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
readonly QML_ROOT="${REPO_ROOT}/src"

failures=0

pass() {
    printf '[ok] %s\n' "$1"
}

fail() {
    printf '[fail] %s\n' "$1" >&2
    ((failures += 1))
}

while IFS= read -r -d '' script; do
    if bash -n "${script}"; then
        pass "bash syntax: ${script#${REPO_ROOT}/}"
    else
        fail "bash syntax: ${script#${REPO_ROOT}/}"
    fi
done < <(
    find "${REPO_ROOT}/scripts" "${REPO_ROOT}/src/controlcenter/tools" \
        -type f -name '*.sh' -print0
    find "${REPO_ROOT}/packaging/bin" -maxdepth 1 -type f -print0
)

if command -v shellcheck >/dev/null 2>&1; then
    mapfile -d '' shell_files < <(
        find "${REPO_ROOT}/scripts" "${REPO_ROOT}/src/controlcenter/tools" \
            -type f -name '*.sh' -print0
        find "${REPO_ROOT}/packaging/bin" -maxdepth 1 -type f -print0
    )
    if shellcheck "${shell_files[@]}"; then
        pass "shellcheck"
    else
        fail "shellcheck"
    fi
else
    printf '[skip] shellcheck is not installed\n'
fi

desktop_file="${REPO_ROOT}/packaging/applications/miko-control-center.desktop"
if command -v desktop-file-validate >/dev/null 2>&1; then
    if desktop-file-validate "${desktop_file}"; then
        pass "desktop file"
    else
        fail "desktop file"
    fi
fi

if "${REPO_ROOT}/scripts/check-i18n.sh"; then
    pass "translation catalogs"
else
    fail "translation catalogs"
fi

if grep -RInE \
    --exclude='check.sh' \
    --exclude-dir='.git' \
    '(gho_[A-Za-z0-9_]+|BEGIN [A-Z ]*PRIVATE KEY|/home/[A-Za-z0-9._-]+/)' \
    "${REPO_ROOT}"; then
    fail "possible secret or absolute home path"
else
    pass "secret and absolute-path scan"
fi

if [[ -f "${QML_ROOT}/control-center.qml"
      && -d "${QML_ROOT}/controlcenter" ]]; then
    pass "source payload"
else
    fail "source payload"
fi

qml_count="$(find "${QML_ROOT}" -type f -name '*.qml' | wc -l)"
if ((qml_count >= 80)); then
    pass "QML inventory (${qml_count} files)"
else
    fail "QML inventory is unexpectedly small (${qml_count} files)"
fi

if python3 "${REPO_ROOT}/scripts/check-qml.py"; then
    pass "QML syntax"
else
    fail "QML syntax"
fi

if command -v git >/dev/null 2>&1; then
    for integration_patch in "${REPO_ROOT}"/integrations/miko-theme/*.patch; do
        if git apply --numstat "${integration_patch}" >/dev/null; then
            pass "integration patch syntax: ${integration_patch#${REPO_ROOT}/}"
        else
            fail "integration patch syntax: ${integration_patch#${REPO_ROOT}/}"
        fi
    done
else
    printf '[skip] git is unavailable for integration patch checks\n'
fi

if PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s "${REPO_ROOT}/tests"; then
    pass "backend failure and recovery tests"
else
    fail "backend tests"
fi

if ((failures > 0)); then
    printf '\n%d check(s) failed.\n' "${failures}" >&2
    exit 1
fi

if command -v node >/dev/null 2>&1; then
    node --test "${REPO_ROOT}/tests/test_ui_logic.cjs"
else
    printf '[skip] JavaScript regression tests require Node.js (development only)\n'
fi

printf '\nAll static and backend checks passed. Run scripts/smoke.sh in a Wayland session for runtime validation.\n'
