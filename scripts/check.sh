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

if command -v qmllint >/dev/null 2>&1; then
    qml_diagnostics="$(mktemp)"
    qml_status=0
    while IFS= read -r -d '' qml_file; do
        output="$(qmllint -I "${QML_ROOT}" "${qml_file}" 2>&1)" || qml_status=$?
        if [[ -n "${output}" ]]; then
            printf '%s\n%s\n' "${qml_file}" "${output}" >>"${qml_diagnostics}"
        fi
    done < <(find "${QML_ROOT}" -type f -name '*.qml' -print0)
    if [[ -s "${qml_diagnostics}" ]]; then
        cat "${qml_diagnostics}" >&2
        fail "qmllint diagnostics"
    elif ((qml_status != 0)); then
        printf '[warn] qmllint returned %d without diagnostics; runtime imports may be unavailable\n' \
            "${qml_status}"
    else
        pass "qmllint"
    fi
    rm -f -- "${qml_diagnostics}"
fi

if ((failures > 0)); then
    printf '\n%d check(s) failed.\n' "${failures}" >&2
    exit 1
fi

printf '\nAll repository checks passed.\n'
