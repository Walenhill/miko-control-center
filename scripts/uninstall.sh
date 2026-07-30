#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

yes=false

usage() {
    cat <<'EOF'
Usage: ./scripts/uninstall.sh [--yes]

Move installed Miko Control Center files into an XDG state backup.
The surrounding illogical-impulse runtime is never removed.

  --yes      Skip the interactive confirmation.
  -h, --help Show this help.
EOF
}

while (($# > 0)); do
    case "$1" in
        --yes) yes=true ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'Unknown option: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

readonly config_home="${XDG_CONFIG_HOME:-${HOME}/.config}"
readonly data_home="${XDG_DATA_HOME:-${HOME}/.local/share}"
readonly state_home="${XDG_STATE_HOME:-${HOME}/.local/state}"
readonly bin_home="${XDG_BIN_HOME:-${HOME}/.local/bin}"
readonly qs_root="${MIKO_QS_ROOT:-${config_home}/quickshell/ii}"
readonly install_state="${state_home}/miko-control-center"

targets=(
    "${qs_root}/control-center.qml"
    "${qs_root}/controlcenter"
    "${bin_home}/miko-control-center"
    "${data_home}/applications/miko-control-center.desktop"
    "${data_home}/icons/hicolor/scalable/apps/miko-control-center.svg"
)

existing=()
for target in "${targets[@]}"; do
    [[ ! -e "${target}" && ! -L "${target}" ]] || existing+=("${target}")
done

if ((${#existing[@]} == 0)); then
    printf 'Miko Control Center files were not found.\n'
    exit 0
fi

printf 'The following files will be moved to a backup:\n'
printf '  %s\n' "${existing[@]}"

if ! ${yes}; then
    [[ -t 0 ]] || {
        printf 'Interactive confirmation requires a terminal; use --yes.\n' >&2
        exit 2
    }
    read -r -p 'Continue? [y/N] ' answer
    [[ "${answer}" == "y" || "${answer}" == "Y" ]] || {
        printf 'Cancelled.\n'
        exit 0
    }
fi

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
backup_parent="${install_state}/removed"
mkdir -p -- "${backup_parent}"
backup_root="$(mktemp -d "${backup_parent}/${timestamp}.XXXXXXXX")"

for target in "${existing[@]}"; do
    relative="${target#/}"
    destination="${backup_root}/${relative}"
    mkdir -p -- "${destination%/*}"
    mv -- "${target}" "${destination}"
done

command -v update-desktop-database >/dev/null 2>&1 \
    && update-desktop-database "${data_home}/applications" >/dev/null 2>&1 \
    || true

printf 'Removed files were preserved at %s\n' "${backup_root}"
printf 'The main Quickshell process was not restarted.\n'
