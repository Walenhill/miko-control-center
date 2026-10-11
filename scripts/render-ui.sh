#!/usr/bin/env bash
# Opt-in visual QA of source using the installed ii imports, without settings writes.
set -Eeuo pipefail
readonly repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly runtime="${MIKO_QS_ROOT:-${XDG_CONFIG_HOME:-${HOME}/.config}/quickshell/ii}"
[[ $# == 1 && "$1" == /* ]] || { printf 'Usage: bash scripts/render-ui.sh /absolute/output.png\n' >&2; exit 2; }
work="$(mktemp -d)"
trap 'rm -rf -- "$work"' EXIT
payload="$work/src"
mkdir -p "$payload" "$work/state"
palette="${XDG_STATE_HOME:-${HOME}/.local/state}/quickshell/user/generated/colors.json"
if [[ -f "$palette" ]]; then
    mkdir -p "$work/state/quickshell/user/generated"
    cp -- "$palette" "$work/state/quickshell/user/generated/colors.json"
fi
cp -a -- "$repo_root/src/." "$payload/"
cp -- "$repo_root/tests/ui-form-render.qml" "$payload/ui-form-render.qml"
for directory in modules services assets scripts defaults panelFamilies translations; do
    [[ ! -e "$runtime/$directory" ]] || ln -s "$runtime/$directory" "$payload/$directory"
done
for file in "$runtime"/*.qml; do
    [[ -e "$payload/${file##*/}" ]] || ln -s "$file" "$payload/${file##*/}"
done
status=0
env MIKO_CONTROL_CENTER_RENDER_TEST=1 MIKO_RENDER_OUTPUT="$1" XDG_STATE_HOME="$work/state" QT_QPA_PLATFORM=wayland \
    timeout 15s qs -p "$payload/ui-form-render.qml" --no-color >"$work/log" 2>&1 || status=$?
if ((status != 0)) || ! grep -Fq '[Miko UI render] complete' "$work/log" \
        || grep -Eq 'ERROR|ReferenceError|TypeError|is not a type|Binding loop|Cannot assign|Unable to assign' "$work/log"; then
    cat "$work/log" >&2
    exit 1
fi
printf '[ok] source UI render: %s\n' "$1"
