import QtQuick
import Quickshell.Io

QtObject {
    id: root
    required property var environment

    property var snapshots: []
    property bool busy: false
    property string message: ""
    property string pendingRestore: ""

    function quote(value) {
        return "'" + String(value).replace(/'/g, "'\\''") + "'";
    }

    function refresh() {
        if (!listProcess.running)
            listProcess.running = true;
    }

    function createSnapshot() {
        if (createProcess.running)
            return;
        createProcess.command = ["bash", "-lc", `
            set -eu
            root=${quote(environment.snapshotRoot)}
            stamp=$(date +%Y%m%d-%H%M%S)
            work=$(mktemp -d)
            trap 'rm -rf "$work"' EXIT
            mkdir -p "$root" "$work/config"
            cfg=${quote(environment.illogicalConfig)}
            prefs=${quote(environment.preferencesState)}
            [ -f "$cfg" ] && cp -- "$cfg" "$work/config/illogical-impulse.json"
            [ -f "$prefs" ] && cp -- "$prefs" "$work/config/control-center.json"
            printf 'created=%s\n' "$(date --iso-8601=seconds)" > "$work/metadata"
            tar -C "$work" -czf "$root/$stamp.tar.gz" .
            printf '%s\n' "$root/$stamp.tar.gz"
        `];
        createProcess.running = true;
    }

    function requestRestore(path) {
        pendingRestore = path;
    }

    function cancelRestore() {
        pendingRestore = "";
    }

    function confirmRestore() {
        if (pendingRestore === "" || restoreProcess.running)
            return;
        const archive = pendingRestore;
        pendingRestore = "";
        restoreProcess.command = ["bash", "-lc", `
            set -eu
            archive=${quote(archive)}
            work=$(mktemp -d)
            trap 'rm -rf "$work"' EXIT
            tar -C "$work" -xzf "$archive"
            cfg=${quote(environment.illogicalConfig)}
            prefs=${quote(environment.preferencesState)}
            if [ -f "$work/config/illogical-impulse.json" ]; then
                mkdir -p "$(dirname "$cfg")"
                cp -- "$work/config/illogical-impulse.json" "$cfg"
            fi
            if [ -f "$work/config/control-center.json" ]; then
                mkdir -p "$(dirname "$prefs")"
                cp -- "$work/config/control-center.json" "$prefs"
            fi
        `];
        restoreProcess.running = true;
    }

    property Process listAction: Process {
        id: listProcess
        command: ["bash", "-lc", `
            root=${root.quote(root.environment.snapshotRoot)}
            [ -d "$root" ] || exit 0
            find "$root" -maxdepth 1 -type f -name '*.tar.gz' -printf '%T@|%p|%s\n' 2>/dev/null |
                sort -rn | head -20
        `]
        onRunningChanged: root.busy = running
        stdout: StdioCollector {
            onStreamFinished: {
                root.snapshots = text.trim().split("\n")
                    .filter(row => row !== "").map(row => {
                        const fields = row.split("|");
                        const date = new Date(Number(fields[0]) * 1000);
                        return {
                            path: fields[1],
                            title: String(fields[1]).split("/").pop().replace(".tar.gz", ""),
                            created: date.toLocaleString(Qt.locale(), Locale.ShortFormat),
                            bytes: Number(fields[2] || 0)
                        };
                    });
            }
        }
    }

    property Process createAction: Process {
        id: createProcess
        onRunningChanged: root.busy = running
        onExited: (code, status) => {
            root.message = code === 0 ? "Снимок настроек создан" : "Не удалось создать снимок";
            root.refresh();
        }
    }

    property Process restoreAction: Process {
        id: restoreProcess
        onRunningChanged: root.busy = running
        onExited: (code, status) => {
            root.message = code === 0
                ? "Настройки восстановлены; переоткрой центр"
                : "Восстановление не удалось";
        }
    }
}
