#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

readonly PROGRAM_NAME="${0##*/}"
readonly BUNDLE_NAME="miko-control-center"

usage() {
    cat <<EOF
Usage:
  ${PROGRAM_NAME} [--full-runtime] OUTPUT.tar.gz

Build a portable source bundle without installing or changing live files.

Options:
  --full-runtime  Include the complete Quickshell ii runtime. The default
                  bundle contains only control-center.qml and controlcenter/.
  -h, --help      Show this help.

Environment overrides:
  MIKO_QS_ROOT    Quickshell ii source root
                  (default: \$XDG_CONFIG_HOME/quickshell/ii)
  MIKO_LAUNCHER   Launcher source path
  XDG_BIN_HOME    User executable directory
                  (default: \$HOME/.local/bin)

The output path must not already exist. Nothing is copied into XDG directories.
EOF
}

die() {
    printf '%s: %s\n' "${PROGRAM_NAME}" "$*" >&2
    exit 2
}

require_command() {
    command -v "$1" >/dev/null 2>&1 \
        || die "required command is missing: $1"
}

write_portable_launcher() {
    local destination="$1"

    cat >"${destination}" <<'EOF'
#!/usr/bin/env bash

set -Eeuo pipefail

readonly QML_PATH="${XDG_CONFIG_HOME:-${HOME}/.config}/quickshell/ii/control-center.qml"
readonly LOG_PATH="${XDG_STATE_HOME:-${HOME}/.local/state}/miko-control-center.log"

if [[ ! -f "${QML_PATH}" ]]; then
    if command -v notify-send >/dev/null 2>&1; then
        notify-send \
            --app-name="Miko Control Center" \
            --icon="miko-control-center" \
            "Не удалось открыть центр управления" \
            "Файл приложения не найден: ${QML_PATH}"
    fi
    printf 'Miko Control Center: file not found: %s\n' "${QML_PATH}" >&2
    exit 1
fi

command -v qs >/dev/null 2>&1 || {
    printf 'Miko Control Center: Quickshell command "qs" is not installed\n' >&2
    exit 127
}

if qs list --all 2>/dev/null | grep -Fq "Config path: ${QML_PATH}"; then
    exec qs -p "${QML_PATH}" ipc call controlCenter show
fi

mkdir -p "$(dirname "${LOG_PATH}")"
exec qs -p "${QML_PATH}" >>"${LOG_PATH}" 2>&1
EOF
    chmod 0755 "${destination}"
}

normalize_launcher() {
    local source="$1"
    local destination="$2"

    if grep -Eq '^[[:space:]]*readonly[[:space:]]+QML_PATH=' "${source}"; then
        awk '
            /^[[:space:]]*readonly[[:space:]]+QML_PATH=/ {
                print "readonly QML_PATH=\"${XDG_CONFIG_HOME:-${HOME}/.config}/quickshell/ii/control-center.qml\""
                next
            }
            { print }
        ' "${source}" >"${destination}"
        chmod 0755 "${destination}"
        return
    fi

    # Keep an unfamiliar launcher for reference, but use a known XDG-aware
    # wrapper as the installable entry point.
    mkdir -p "$(dirname "${destination}")/../source-artifacts"
    cp -a -- "${source}" "$(dirname "${destination}")/../source-artifacts/launcher.original"
    write_portable_launcher "${destination}"
}

normalize_desktop_file() {
    local source="$1"
    local destination="$2"

    awk '
        BEGIN { replaced_exec = 0 }
        /^TryExec=/ { next }
        /^Exec=/ && !replaced_exec {
            print "TryExec=miko-control-center"
            print "Exec=miko-control-center"
            replaced_exec = 1
            next
        }
        { print }
        END {
            if (!replaced_exec) {
                print "TryExec=miko-control-center"
                print "Exec=miko-control-center"
            }
        }
    ' "${source}" >"${destination}"
    chmod 0644 "${destination}"
}

full_runtime=false
output=""

while (($# > 0)); do
    case "$1" in
        --full-runtime)
            full_runtime=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            (($# == 1)) || die "expected exactly one output path after --"
            output="$1"
            shift
            break
            ;;
        -*)
            die "unknown option: $1"
            ;;
        *)
            [[ -z "${output}" ]] || die "expected exactly one output path"
            output="$1"
            ;;
    esac
    shift
done

[[ -n "${output}" ]] || {
    usage >&2
    exit 2
}

for command_name in awk chmod cp find grep mkdir mktemp mv realpath rm \
    sha256sum sort tar xargs; do
    require_command "${command_name}"
done

readonly home_dir="${HOME:?HOME is not set}"
readonly xdg_config_home="${XDG_CONFIG_HOME:-${home_dir}/.config}"
readonly xdg_data_home="${XDG_DATA_HOME:-${home_dir}/.local/share}"
readonly xdg_bin_home="${XDG_BIN_HOME:-${home_dir}/.local/bin}"
readonly qs_root="${MIKO_QS_ROOT:-${xdg_config_home}/quickshell/ii}"
readonly control_center_qml="${qs_root}/control-center.qml"
readonly controlcenter_dir="${qs_root}/controlcenter"
readonly desktop_source="${xdg_data_home}/applications/miko-control-center.desktop"

[[ -f "${control_center_qml}" ]] \
    || die "entry point not found: ${control_center_qml}"
[[ -d "${controlcenter_dir}" ]] \
    || die "module directory not found: ${controlcenter_dir}"

output="$(realpath -m -- "${output}")"
readonly output
readonly output_parent="${output%/*}"
readonly qs_root_real="$(realpath -m -- "${qs_root}")"

case "${output}" in
    "${qs_root_real}"|"${qs_root_real}"/*)
        die "refusing to write the bundle inside its source runtime: ${output}"
        ;;
esac

[[ ! -e "${output}" && ! -L "${output}" ]] \
    || die "output already exists (refusing to overwrite): ${output}"
mkdir -p -- "${output_parent}"

stage_root="$(mktemp -d "${TMPDIR:-/tmp}/miko-control-center-bundle.XXXXXXXX")"
archive_tmp="$(mktemp "${output_parent}/.${BUNDLE_NAME}.XXXXXXXX.tar.gz")"

cleanup() {
    local status=$?
    rm -rf -- "${stage_root}"
    [[ -e "${archive_tmp}" ]] && rm -f -- "${archive_tmp}"
    exit "${status}"
}
trap cleanup EXIT INT TERM

readonly bundle_root="${stage_root}/${BUNDLE_NAME}"
readonly config_payload="${bundle_root}/xdg-config/quickshell/ii"
readonly data_payload="${bundle_root}/xdg-data"
readonly bin_payload="${bundle_root}/bin"

mkdir -p -- "${config_payload}" "${data_payload}" "${bin_payload}"

profile="source"
if ${full_runtime}; then
    profile="full-runtime"
    cp -a -- "${qs_root}/." "${config_payload}/"
else
    cp -a -- "${control_center_qml}" "${config_payload}/control-center.qml"
    cp -a -- "${controlcenter_dir}" "${config_payload}/controlcenter"
fi

launcher_source="${MIKO_LAUNCHER:-}"
if [[ -z "${launcher_source}" && -f "${desktop_source}" ]]; then
    desktop_exec="$(awk -F= '/^Exec=/ { sub(/^Exec=/, ""); print; exit }' "${desktop_source}")"
    desktop_command="${desktop_exec%% *}"
    desktop_command="${desktop_command#\"}"
    desktop_command="${desktop_command%\"}"
    if [[ "${desktop_command}" == /* && -f "${desktop_command}" ]]; then
        launcher_source="${desktop_command}"
    elif [[ -n "${desktop_command}" ]] && command -v "${desktop_command}" >/dev/null 2>&1; then
        launcher_source="$(command -v "${desktop_command}")"
    fi
fi
if [[ -z "${launcher_source}" && -f "${xdg_bin_home}/miko-control-center" ]]; then
    launcher_source="${xdg_bin_home}/miko-control-center"
fi

launcher_included=false
if [[ -n "${launcher_source}" && -f "${launcher_source}" ]]; then
    normalize_launcher "${launcher_source}" "${bin_payload}/miko-control-center"
    launcher_included=true
fi

desktop_included=false
if [[ -f "${desktop_source}" ]]; then
    mkdir -p -- "${data_payload}/applications"
    normalize_desktop_file \
        "${desktop_source}" \
        "${data_payload}/applications/miko-control-center.desktop"
    desktop_included=true
fi

icon_count=0
icon_root="${xdg_data_home}/icons"
if [[ -d "${icon_root}" ]]; then
    while IFS= read -r -d '' icon_source; do
        icon_relative="${icon_source#"${xdg_data_home}/"}"
        icon_destination="${data_payload}/${icon_relative}"
        mkdir -p -- "${icon_destination%/*}"
        cp -a -- "${icon_source}" "${icon_destination}"
        ((icon_count += 1))
    done < <(
        find "${icon_root}" \
            \( -type f -o -type l \) \
            -name 'miko-control-center.*' \
            -print0
    )
fi

cat >"${bundle_root}/BUNDLE.md" <<'EOF'
# Miko Control Center source bundle

This archive does not install anything automatically.

Payload mapping:

- `xdg-config/` -> `${XDG_CONFIG_HOME:-$HOME/.config}/`
- `xdg-data/` -> `${XDG_DATA_HOME:-$HOME/.local/share}/`
- `bin/` -> a directory in `$PATH` (normally `$HOME/.local/bin/`)

The packaged desktop entry uses `Exec=miko-control-center`; the launcher resolves
the QML entry point through `XDG_CONFIG_HOME`, so no source-machine home path is
embedded in the installable files.

Before copying a `full-runtime` bundle to another machine, inspect it for local
configuration or private data. No files should be copied over an existing setup
without a backup and an explicit review.
EOF

cat >"${bundle_root}/manifest.env" <<EOF
BUNDLE_FORMAT=1
PROFILE=${profile}
ENTRYPOINT=xdg-config/quickshell/ii/control-center.qml
DESKTOP_EXEC=miko-control-center
LAUNCHER_INCLUDED=${launcher_included}
DESKTOP_INCLUDED=${desktop_included}
ICON_COUNT=${icon_count}
EOF
chmod 0644 "${bundle_root}/BUNDLE.md" "${bundle_root}/manifest.env"

(
    cd "${bundle_root}"
    find . -type f ! -name files.sha256 -print0 \
        | sort -z \
        | xargs -0 sha256sum >files.sha256
)
chmod 0644 "${bundle_root}/files.sha256"

tar -C "${stage_root}" -czf "${archive_tmp}" "${BUNDLE_NAME}"
tar -tzf "${archive_tmp}" >/dev/null
mv -- "${archive_tmp}" "${output}"
chmod 0600 "${output}"

printf 'Bundle: %s\n' "${output}"
printf 'Profile: %s\n' "${profile}"
printf 'Launcher: %s; desktop: %s; icons: %d\n' \
    "${launcher_included}" "${desktop_included}" "${icon_count}"
printf 'No live files were installed or changed.\n'
