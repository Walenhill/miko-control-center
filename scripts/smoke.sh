#!/usr/bin/env bash
# Run the source payload against the installed ii imports, with private CC state.
set -Eeuo pipefail
readonly repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly runtime="${MIKO_QS_ROOT:-${XDG_CONFIG_HOME:-${HOME}/.config}/quickshell/ii}"
work="$(mktemp -d)"
trap 'rm -rf -- "$work"' EXIT
payload="$work/src"
mkdir -p "$payload"
cp -a -- "$repo_root/src/." "$payload/"
for directory in modules services assets scripts defaults panelFamilies translations; do
    [[ ! -e "$runtime/$directory" ]] || ln -s "$runtime/$directory" "$payload/$directory"
done
for file in "$runtime"/*.qml; do
    [[ -e "$payload/${file##*/}" ]] || ln -s "$file" "$payload/${file##*/}"
done
mkdir -p "$work/state"
status=0
env MIKO_CONTROL_CENTER_SMOKE_TEST=1 XDG_STATE_HOME="$work/state" QT_QPA_PLATFORM=wayland \
    timeout 35s qs -p "$payload/control-center.qml" --no-color >"$work/log" 2>&1 || status=$?
if ((status != 0)) || ! grep -Fq '[Miko smoke] complete' "$work/log" \
        || ! grep -Fq '[Miko smoke] navigation memory and search complete' "$work/log" \
        || ! grep -Fq '[Miko smoke] appearance editors complete' "$work/log" \
        || grep -Eq 'ERROR|ReferenceError|TypeError|is not a type|Binding loop|Cannot assign|Unable to assign' "$work/log"; then
    cat "$work/log" >&2
    exit 1
fi
printf '[ok] source runtime smoke: 9 pages and 5 appearance editors in RU and EN, navigation memory and search\n'
cp -- "$repo_root/tests/appearance-smoke.qml" "$payload/appearance-smoke.qml"
cp -- "$repo_root/tests/fixtures/theme-generator.sh" "$payload/theme-generator.sh"
chmod +x "$payload/theme-generator.sh"
status=0
env XDG_STATE_HOME="$work/state" QT_QPA_PLATFORM=wayland \
    timeout 20s qs -p "$payload/appearance-smoke.qml" --no-color >"$work/appearance-log" 2>&1 || status=$?
if ((status != 0)) || ! grep -Fq '[Miko appearance test] complete' "$work/appearance-log" \
        || grep -Eq 'ERROR|ReferenceError|TypeError|Binding loop|Cannot assign|Unable to assign' "$work/appearance-log"; then
    cat "$work/appearance-log" >&2
    exit 1
fi
printf '[ok] appearance palette/accent queue, grouped profile undo, failure and external-change runtime tests (mock generator)\n'
