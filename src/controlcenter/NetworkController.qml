import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    required property var environment
    required property var capabilities
    property bool active: false
    property bool portsActive: false
    property bool initialized: false
    property string networkSettingsCommand: ""

    property bool tunnelActive: false
    property string tunnelName: ""
    property bool wifiHardwareAvailable: false
    property var snapshot: ({})
    property string lastChecked: "ещё не проверялось"
    property var listeningPorts: []
    property var portInspection: ({})
    property string portQuery: ""
    property string portActionMessage: ""
    property bool portListExpanded: false

    readonly property bool snapshotBusy: snapshotRead.running
    readonly property bool portListBusy: portListRead.running
    readonly property bool portQueryBusy: portQueryRead.running
    readonly property bool throneAvailable:
        !capabilities.ready || capabilities.has("throne")

    onActiveChanged: {
        if (active)
            ensureLoaded();
    }
    onPortsActiveChanged: {
        if (portsActive)
            refreshPorts();
    }

    function ensureLoaded() {
        if (!initialized) {
            initialized = true;
            if (!tunnelStatusRead.running)
                tunnelStatusRead.running = true;
            if (!wifiHardwareRead.running)
                wifiHardwareRead.running = true;
        }
        refreshSnapshot();
    }

    function openNetworkSettings() {
        if (networkSettingsCommand !== "") {
            Quickshell.execDetached([
                "bash", "-c", networkSettingsCommand
            ]);
        }
    }

    function openThrone() {
        if (throneAvailable)
            Quickshell.execDetached(["throne"]);
    }

    function refreshSnapshot() {
        if (!snapshotRead.running)
            snapshotRead.running = true;
    }

    function refreshPorts() {
        if (!portListRead.running)
            portListRead.running = true;
    }

    function inspectPort(value) {
        const normalized = String(value).trim();
        const port = Number(normalized);
        if (!Number.isInteger(port) || port < 1 || port > 65535
                || portQueryRead.running)
            return;
        portQuery = normalized;
        portInspection = ({});
        portQueryRead.exec([environment.portInspect, normalized]);
    }

    function changeFirewall(protocol, allow) {
        if (portQuery === "" || firewallAction.running)
            return;
        const transport = protocol === "udp" ? "udp" : "tcp";
        const verb = allow ? "allow" : "deny";
        const title = allow ? "Открыть порт" : "Закрыть порт";
        const subject = transport === "tcp"
            ? (allow
                ? "Разрешить входящие TCP-подключения к порту $1 через UFW?"
                : "Запретить входящие TCP-подключения к порту $1 через UFW? Приложение продолжит работать локально.")
            : (allow
                ? "Разрешить входящие UDP-пакеты на порт $1 через UFW?"
                : "Запретить входящие UDP-пакеты на порт $1 через UFW? Приложение продолжит работать локально.");
        firewallAction.exec([
            "bash", "-c",
            "kdialog --title '" + title + "' --yesno \"" + subject
                + "\" && pkexec ufw " + verb + " \"$1/" + transport + "\"",
            "miko-port", portQuery
        ]);
    }

    function formatBytes(value) {
        const bytes = Number(value);
        if (!isFinite(bytes) || bytes < 0)
            return "—";
        const units = ["Б", "КБ", "МБ", "ГБ", "ТБ"];
        let amount = bytes;
        let unit = 0;
        while (amount >= 1024 && unit < units.length - 1) {
            amount /= 1024;
            unit++;
        }
        return (unit === 0
            ? Math.round(amount)
            : amount.toFixed(amount >= 10 ? 1 : 2)) + " " + units[unit];
    }

    property Process tunnelStatusProcess: Process {
        id: tunnelStatusRead
        running: false
        command: [
            "sh", "-c",
            "nmcli -t -f NAME,TYPE connection show --active | awk -F: '$2 == \"tun\" {print $1; exit}'"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                root.tunnelName = text.trim();
                root.tunnelActive = root.tunnelName.length > 0;
            }
        }
    }

    property Process wifiHardwareProcess: Process {
        id: wifiHardwareRead
        running: false
        command: [
            "sh", "-c",
            "nmcli -t -f TYPE device status | grep -qx wifi"
        ]
        onExited: (exitCode, exitStatus) =>
            root.wifiHardwareAvailable = exitCode === 0
    }

    property Process snapshotProcess: Process {
        id: snapshotRead
        running: false
        command: [root.environment.networkSnapshot]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.snapshot = JSON.parse(text);
                    root.lastChecked = Qt.formatDateTime(new Date(), "HH:mm:ss");
                } catch (error) {
                    root.snapshot = ({});
                }
            }
        }
    }

    property Process portListProcess: Process {
        id: portListRead
        running: false
        command: [root.environment.portInspect]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.listeningPorts = JSON.parse(text).sockets || [];
                } catch (error) {
                    root.listeningPorts = [];
                }
            }
        }
    }

    property Process portQueryProcess: Process {
        id: portQueryRead
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.portInspection = JSON.parse(text);
                } catch (error) {
                    root.portInspection = ({});
                }
            }
        }
    }

    property Process firewallProcess: Process {
        id: firewallAction
        onRunningChanged: {
            if (running)
                root.portActionMessage = "Применяем правило UFW…";
        }
        onExited: (exitCode, exitStatus) => {
            root.portActionMessage = exitCode === 0
                ? "Правило UFW применено"
                : "Действие отменено или завершилось с ошибкой";
            root.refreshPorts();
            if (root.portQuery !== "")
                root.inspectPort(root.portQuery);
        }
    }

    property Timer tunnelRefreshTimer: Timer {
        interval: 5000
        running: root.active
        repeat: true
        triggeredOnStart: false
        onTriggered: if (!tunnelStatusRead.running)
            tunnelStatusRead.running = true
    }

    property Timer snapshotRefreshTimer: Timer {
        interval: 30000
        running: root.active
        repeat: true
        triggeredOnStart: false
        onTriggered: root.refreshSnapshot()
    }
}
