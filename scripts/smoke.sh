#!/usr/bin/env bash
# Run the source payload against the installed ii imports, with private CC state.
set -Eeuo pipefail
readonly repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly runtime="${MIKO_QS_ROOT:-${XDG_CONFIG_HOME:-${HOME}/.config}/quickshell/ii}"
work="$(mktemp -d)"
trap 'rm -rf -- "$work"' EXIT
cp -a -- "$repo_root/src/." "$work/"
for directory in modules services assets scripts defaults panelFamilies translations; do
    [[ ! -e "$runtime/$directory" ]] || ln -s "$runtime/$directory" "$work/$directory"
done
for file in "$runtime"/*.qml; do
    [[ -e "$work/${file##*/}" ]] || ln -s "$file" "$work/${file##*/}"
done
mkdir -p "$work/state"
status=0
env MIKO_CONTROL_CENTER_SMOKE_TEST=1 XDG_STATE_HOME="$work/state" QT_QPA_PLATFORM=wayland \
    timeout 35s qs -p "$work/control-center.qml" --no-color >"$work/log" 2>&1 || status=$?
if ((status != 0)) || ! grep -Fq '[Miko smoke] complete' "$work/log" \
        || grep -Eq 'ERROR|ReferenceError|TypeError|is not a type|Binding loop|Cannot assign|Unable to assign' "$work/log"; then
    cat "$work/log" >&2
    exit 1
fi
printf '[ok] source runtime smoke: 9 pages in RU and EN\n'
