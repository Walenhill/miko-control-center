import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool ready: false
    property var commands: ({})
    property bool archBased: false
    property bool mikoExtensions: false

    readonly property var optionalIntegrations: [
        { id: "throne", command: "throne", title: "Throne" },
        { id: "kdeconnect", command: "kdeconnect-cli", title: "KDE Connect" },
        { id: "easyeffects", command: "easyeffects", title: "EasyEffects" },
        { id: "ddc", command: "ddcutil", title: "DDC/CI" },
        { id: "smart", command: "smartctl", title: "SMART" }
    ]

    function has(command) {
        return commands[command] === true;
    }

    function refresh() {
        ready = false;
        probe.running = true;
    }

    property Process probe: Process {
        command: [
            "bash", "-lc",
            "for c in pacman paru yay hyprctl qs wpctl nmcli bluetoothctl "
                + "kdeconnect-cli throne ddcutil easyeffects smartctl "
                + "lsusb ps kill systemctl journalctl kitty pkexec ufw "
                + "powerprofilesctl checkupdates paccache gio "
                + "miko-watch miko-check; do "
                + "command -v \"$c\" >/dev/null 2>&1 && printf '%s\\n' \"$c\"; "
                + "done; "
                + "test -e /etc/arch-release && printf '%s\\n' '@arch'; "
                + "test -x \"$HOME/.local/bin/miko-watch\" "
                + "&& printf '%s\\n' '@miko'"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const found = {};
                text.split("\n").map(line => line.trim())
                    .filter(line => line !== "")
                    .forEach(line => found[line] = true);
                root.commands = found;
                root.archBased = found["@arch"] === true;
                root.mikoExtensions = found["@miko"] === true;
                root.ready = true;
            }
        }
    }

    Component.onCompleted: refresh()
}
