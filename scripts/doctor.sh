#!/usr/bin/env bash

set -u

readonly config_home="${XDG_CONFIG_HOME:-${HOME}/.config}"
readonly qs_root="${MIKO_QS_ROOT:-${config_home}/quickshell/ii}"

ok=0
warning=0
missing=0

check_command() {
    local command_name="$1"
    local kind="$2"
    local description="$3"

    if command -v "${command_name}" >/dev/null 2>&1; then
        printf '  [ok]       %-18s %s\n' "${command_name}" "${description}"
        ((ok += 1))
    elif [[ "${kind}" == "required" ]]; then
        printf '  [missing]  %-18s %s\n' "${command_name}" "${description}"
        ((missing += 1))
    else
        printf '  [optional] %-18s %s\n' "${command_name}" "${description}"
        ((warning += 1))
    fi
}

printf 'Runtime\n'
check_command qs required "Quickshell launcher"
check_command bash required "controller command runner"
check_command systemctl required "service inspection"
check_command wpctl required "PipeWire controls"
check_command hyprctl required "Hyprland display integration"

printf '\nPackage and system tools\n'
check_command pacman optional "Arch package manager"
check_command paru optional "AUR updates"
check_command powerprofilesctl optional "power profiles"
check_command smartctl optional "SMART diagnostics"
check_command ddcutil optional "DDC/CI displays"
check_command ufw optional "firewall context"

printf '\nIntegrations\n'
check_command kdeconnect-cli optional "phone integration"
check_command easyeffects optional "audio effects"
check_command throne optional "tunnel integration"
check_command miko-watch optional "Miko health monitor"
check_command miko-check optional "Miko desktop diagnostics"

printf '\nillogical-impulse imports\n'
for runtime_path in \
    "${qs_root}/modules/common" \
    "${qs_root}/modules/common/widgets" \
    "${qs_root}/services"; do
    if [[ -e "${runtime_path}" ]]; then
        printf '  [ok]       %s\n' "${runtime_path}"
        ((ok += 1))
    else
        printf '  [missing]  %s\n' "${runtime_path}"
        ((missing += 1))
    fi
done

printf '\nSummary: %d available, %d optional missing, %d required missing\n' \
    "${ok}" "${warning}" "${missing}"

((missing == 0))
