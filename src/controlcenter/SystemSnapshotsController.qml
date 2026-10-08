import QtQuick
import Quickshell.Io

QtObject {
    id: root
    required property var environment

    property var snapshots: []
    readonly property bool busy: listProcess.running || createProcess.running || restoreProcess.running
    property string message: ""
    property string pendingRestore: ""

    function quote(value) {
        return "'" + String(value).replace(/'/g, "'\\''") + "'";
    }

    function snapshotCommand(action) {
        return ["python3", decodeURIComponent(Qt.resolvedUrl("tools/snapshots.py").toString().replace(/^file:\/\//, "")),
            action, environment.snapshotRoot, environment.illogicalConfig, environment.preferencesState];
    }

    function refresh() {
        if (!listProcess.running)
            listProcess.running = true;
    }

    function createSnapshot() {
        if (busy)
            return;
        createProcess.command = root.snapshotCommand("create");
        createProcess.running = true;
    }

    function requestRestore(path) {
        pendingRestore = path;
    }

    function cancelRestore() {
        pendingRestore = "";
    }

    function confirmRestore() {
        if (pendingRestore === "" || busy)
            return;
        const archive = pendingRestore;
        pendingRestore = "";
        restoreProcess.command = root.snapshotCommand("restore").concat([archive]);
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
        onExited: (code, status) => {
            root.message = code === 0 ? I18n.tr("Снимок настроек создан") : I18n.tr("Не удалось создать снимок");
            root.refresh();
        }
    }

    property Process restoreAction: Process {
        id: restoreProcess
        onExited: (code, status) => {
            root.message = code === 0
                ? I18n.tr("Настройки восстановлены; переоткрой центр")
                : I18n.tr("Восстановление не удалось");
        }
    }
}
