import QtQuick
import Quickshell.Io
import qs.modules.common

QtObject {
    id: root

    required property var capabilities
    property var runningApplications: []
    property var autostartEntries: []
    property int selectedPid: -1
    property string actionMessage: ""
    property bool notificationsSilent: false
    property bool active: false
    property bool initialized: false
    property bool notificationInitialized: false

    readonly property bool actionRunning: processAction.running
    readonly property real notificationTimeoutSeconds:
        Config.options.notifications.timeout / 1000

    onActiveChanged: {
        if (active)
            ensureLoaded();
    }

    function ensureLoaded() {
        if (!initialized) {
            initialized = true;
            refreshAutostart();
        }
        ensureNotificationLoaded();
        refreshProcesses();
    }

    function ensureNotificationLoaded() {
        if (notificationInitialized)
            return;
        notificationInitialized = true;
        refreshNotificationState();
    }

    function stop(pid) {
        if (processAction.running || pid < 1)
            return;
        actionMessage = "Завершаю процесс " + pid + "…";
        processAction.exec(["kill", "-TERM", String(pid)]);
    }

    function refreshProcesses() {
        if (root.capabilities.ready && !root.capabilities.has("ps")) {
            root.actionMessage = "Команда ps не установлена";
            return;
        }
        if (!runningAppsRead.running)
            runningAppsRead.running = true;
    }

    function refreshAutostart() {
        if (!autostartRead.running)
            autostartRead.running = true;
    }

    function refreshNotificationState() {
        if (!notificationStateRead.running)
            notificationStateRead.running = true;
    }

    function toggleNotifications() {
        if (!notificationToggle.running)
            notificationToggle.running = true;
    }

    function setNotificationTimeout(seconds) {
        Config.options.notifications.timeout =
            Math.round(seconds) * 1000;
    }

    property Process runningAppsProcess: Process {
        id: runningAppsRead
        running: false
        command: [
            "sh", "-c",
            "ps -eo pid=,comm=,%cpu=,%mem= --sort=-%cpu "
                + "| awk 'NF >= 4 && $2 !~ /^(ps|awk|head|sh|bash|systemd)$/ "
                + "{print $1 \"|\" $2 \"|\" $3 \"|\" $4}' | head -n 14"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const applications = [];
                for (const row of text.trim().split("\n")) {
                    const [pid, command, cpu, memory] = row.split("|");
                    if (!pid || !command)
                        continue;
                    applications.push({
                        pid: Number(pid),
                        command,
                        cpu: Number(cpu),
                        memory: Number(memory)
                    });
                }
                root.runningApplications = applications;
            }
        }
    }

    property Timer processRefreshTimer: Timer {
        interval: 3000
        running: root.active
        repeat: true
        onTriggered: root.refreshProcesses()
    }

    property Process autostartProcess: Process {
        id: autostartRead
        running: false
        command: ["bash", "-c", `
            find "$HOME/.config/autostart" /etc/xdg/autostart \
                -maxdepth 1 -type f -name '*.desktop' 2>/dev/null |
            while IFS= read -r file; do
                name=$(awk -F= '/^Name=/{print substr($0,6); exit}' "$file")
                exec_line=$(awk -F= '/^Exec=/{print substr($0,6); exit}' "$file")
                hidden=$(awk -F= '/^Hidden=/{print $2; exit}' "$file")
                [ "$hidden" = "true" ] && continue
                printf "%s|%s|%s\\n" "$name" "$exec_line" "$file"
            done
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                const entries = [];
                for (const row of text.trim().split("\n")) {
                    const [name, execLine, file] = row.split("|");
                    if (name)
                        entries.push({ name, execLine, file });
                }
                root.autostartEntries = entries;
            }
        }
    }

    property Process actionProcess: Process {
        id: processAction
        onExited: (exitCode, exitStatus) => {
            root.actionMessage = exitCode === 0
                ? "Приложению отправлен запрос на завершение"
                : "Не удалось завершить процесс";
            root.selectedPid = -1;
            processMessageTimer.restart();
            root.refreshProcesses();
        }
    }

    property Timer messageTimer: Timer {
        id: processMessageTimer
        interval: 3000
        onTriggered: root.actionMessage = ""
    }

    property Process notificationReadProcess: Process {
        id: notificationStateRead
        running: false
        command: [
            "qs", "-c", "ii", "ipc", "call",
            "notifications", "getSilent"
        ]
        stdout: StdioCollector {
            onStreamFinished:
                root.notificationsSilent = text.trim() === "true"
        }
    }

    property Process notificationToggleProcess: Process {
        id: notificationToggle
        command: [
            "qs", "-c", "ii", "ipc", "call",
            "notifications", "toggleSilent"
        ]
        stdout: StdioCollector {
            onStreamFinished:
                root.notificationsSilent = text.trim() === "true"
        }
    }
}
