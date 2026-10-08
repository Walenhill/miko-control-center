import QtQuick
import Quickshell.Io

QtObject {
    id: root

    required property var environment
    property bool busy: false
    property bool initialized: false
    property string lastChecked: I18n.tr("ещё не проверялось")
    property var temperatures: []
    property var failedUnits: []
    property bool rebootRecommended: false
    property string reportPath: ""
    property string message: ""

    function refresh() {
        if (!probe.running)
            probe.running = true;
    }

    function exportReport() {
        if (!reportWriter.running)
            reportWriter.running = true;
    }

    property Process probeProcess: Process {
        id: probe
        command: ["bash", "-lc", `
            printf 'CHECKED|%s\n' "$(date +%s)"
            if command -v sensors >/dev/null 2>&1; then
                sensors 2>/dev/null | awk '
                    /^[^[:space:]].*:/ { chip=$0; sub(/:$/, "", chip) }
                    /[+][-]?[0-9]+(\.[0-9]+)?°C/ {
                        line=$0; gsub(/^[ \t]+/, "", line)
                        split(line, a, ":"); value=a[2]
                        if (match(value, /[+][-]?[0-9]+(\.[0-9]+)?°C/))
                            printf "TEMP|%s · %s|%s\n", chip, a[1], substr(value, RSTART, RLENGTH)
                    }' | head -8
            fi
            systemctl --failed --no-legend --plain 2>/dev/null |
                awk 'NF { printf "FAILED|system|%s\n", $1 }'
            systemctl --user --failed --no-legend --plain 2>/dev/null |
                awk 'NF { printf "FAILED|user|%s\n", $1 }'
            if [ -e /run/reboot-required ]; then printf 'REBOOT|1\n'; else printf 'REBOOT|0\n'; fi
        `]
        onRunningChanged: root.busy = running
        stdout: StdioCollector {
            onStreamFinished: {
                root.initialized = true;
                const temperatures = [];
                const failed = [];
                let reboot = false;
                for (const row of text.trim().split("\n")) {
                    const fields = row.split("|");
                    if (fields[0] === "CHECKED") {
                        const value = new Date(Number(fields[1]) * 1000);
                        root.lastChecked = value.toLocaleTimeString(
                            Qt.locale(), Locale.ShortFormat
                        );
                    } else if (fields[0] === "TEMP") {
                        temperatures.push({ name: fields[1], value: fields[2] });
                    } else if (fields[0] === "FAILED") {
                        failed.push({ scope: fields[1], unit: fields[2] });
                    } else if (fields[0] === "REBOOT") {
                        reboot = fields[1] === "1";
                    }
                }
                root.temperatures = temperatures;
                root.failedUnits = failed;
                root.rebootRecommended = reboot;
                root.message = failed.length === 0
                    ? I18n.tr("Фоновые службы без ошибок")
                    : I18n.tr("Найдено ошибок служб: ") + failed.length;
            }
        }
    }

    property Process reportProcess: Process {
        id: reportWriter
        command: ["bash", "-lc", `
            set -eu
            dir="${root.environment.controlCenterState}/reports"
            mkdir -p "$dir"
            file="$dir/diagnostics-$(date +%Y%m%d-%H%M%S).txt"
            {
                printf 'Miko Control Center diagnostic report\n'
                printf 'Created: '; date --iso-8601=seconds
                printf '\nSystem\n'; uname -srmo
                sed -n 's/^PRETTY_NAME=//p' /etc/os-release 2>/dev/null | tr -d '"'
                printf '\nFailed system units\n'
                systemctl --failed --no-legend --plain 2>/dev/null || true
                printf '\nFailed user units\n'
                systemctl --user --failed --no-legend --plain 2>/dev/null || true
                printf '\nDisk usage\n'; df -h / "$HOME" 2>/dev/null || true
                printf '\nAvailable integrations\n'
                for c in qs hyprctl wpctl nmcli kdeconnect-cli throne smartctl ddcutil sensors; do
                    command -v "$c" >/dev/null 2>&1 && printf '%s: yes\n' "$c" || printf '%s: no\n' "$c"
                done
            } > "$file"
            printf '%s\n' "$file"
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                root.reportPath = text.trim();
                root.message = root.reportPath === ""
                    ? I18n.tr("Не удалось создать отчёт")
                    : I18n.tr("Отчёт создан без IP, hostname и журналов");
            }
        }
    }
}
