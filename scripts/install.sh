#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"

dry_run=false
force=false

usage() {
    cat <<'EOF'
Usage: ./scripts/install.sh [--dry-run] [--force]

Install Miko Control Center into the current user's XDG directories.

  --dry-run  Print the destination paths without writing files.
  --force    Continue when the ii runtime compatibility check is incomplete.
  -h, --help Show this help.

Environment:
  XDG_CONFIG_HOME, XDG_DATA_HOME, XDG_STATE_HOME, XDG_BIN_HOME
  MIKO_QS_ROOT  Override the Quickshell ii root directory.
EOF
}

while (($# > 0)); do
    case "$1" in
        --dry-run) dry_run=true ;;
        --force) force=true ;;
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
readonly qml_target="${qs_root}/control-center.qml"
readonly module_target="${qs_root}/controlcenter"
readonly launcher_target="${bin_home}/miko-control-center"
readonly desktop_target="${data_home}/applications/miko-control-center.desktop"
readonly icon_target="${data_home}/icons/hicolor/scalable/apps/miko-control-center.svg"
readonly install_state="${state_home}/miko-control-center"

readonly qml_source="${REPO_ROOT}/src/control-center.qml"
readonly module_source="${REPO_ROOT}/src/controlcenter"
readonly launcher_source="${REPO_ROOT}/packaging/bin/miko-control-center"
readonly desktop_source="${REPO_ROOT}/packaging/applications/miko-control-center.desktop"
readonly icon_source="${REPO_ROOT}/packaging/icons/hicolor/scalable/apps/miko-control-center.svg"

for source_path in \
    "${qml_source}" "${module_source}" "${launcher_source}" \
    "${desktop_source}" "${icon_source}"; do
    [[ -e "${source_path}" ]] || {
        printf 'Missing repository payload: %s\n' "${source_path}" >&2
        exit 1
    }
done

missing_runtime=()
for runtime_path in \
    "${qs_root}/modules/common" \
    "${qs_root}/modules/common/widgets" \
    "${qs_root}/services"; do
    [[ -e "${runtime_path}" ]] || missing_runtime+=("${runtime_path}")
done

if ((${#missing_runtime[@]} > 0)) && ! ${force}; then
    printf 'Compatible illogical-impulse runtime was not found:\n' >&2
    printf '  %s\n' "${missing_runtime[@]}" >&2
    printf 'Use --force only if your runtime provides equivalent imports.\n' >&2
    exit 1
fi

printf 'Miko Control Center installation plan:\n'
printf '  QML entry:  %s\n' "${qml_target}"
printf '  QML module: %s\n' "${module_target}"
printf '  Launcher:   %s\n' "${launcher_target}"
printf '  Desktop:    %s\n' "${desktop_target}"
printf '  Icon:       %s\n' "${icon_target}"

if ${dry_run}; then
    printf '\nDry run: no files were changed.\n'
    exit 0
fi

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
backup_parent="${install_state}/backups"
backup_root=""

if [[ -e "${qml_target}" || -e "${module_target}" ]]; then
    mkdir -p -- "${backup_parent}"
    backup_root="$(mktemp -d "${backup_parent}/${timestamp}.XXXXXXXX")"
    [[ ! -e "${qml_target}" ]] \
        || cp -a -- "${qml_target}" "${backup_root}/control-center.qml"
    [[ ! -e "${module_target}" ]] \
        || cp -a -- "${module_target}" "${backup_root}/controlcenter"
    printf 'Existing control center backed up to %s\n' "${backup_root}"
fi

mkdir -p -- "${qs_root}" "${bin_home}" \
    "${data_home}/applications" \
    "${data_home}/icons/hicolor/scalable/apps" \
    "${install_state}"

module_stage="$(mktemp -d "${qs_root}/.controlcenter.XXXXXXXX")"
cleanup() {
    [[ ! -d "${module_stage}" ]] || rm -rf -- "${module_stage}"
}
trap cleanup EXIT INT TERM

cp -a -- "${module_source}/." "${module_stage}/"
install -m 0644 -- "${qml_source}" "${qml_target}"
rm -rf -- "${module_target}"
mv -- "${module_stage}" "${module_target}"
install -m 0755 -- "${launcher_source}" "${launcher_target}"
install -m 0644 -- "${desktop_source}" "${desktop_target}"
install -m 0644 -- "${icon_source}" "${icon_target}"

{
    printf 'version=%s\n' "$(tr -d '\n' <"${REPO_ROOT}/VERSION")"
    printf 'installed_at=%s\n' "${timestamp}"
    printf 'qs_root=%s\n' "${qs_root}"
} >"${install_state}/install.env"
chmod 0600 "${install_state}/install.env"

command -v update-desktop-database >/dev/null 2>&1 \
    && update-desktop-database "${data_home}/applications" >/dev/null 2>&1 \
    || true

printf '\nInstalled successfully. The main Quickshell process was not restarted.\n'
printf 'Run: miko-control-center\n'
