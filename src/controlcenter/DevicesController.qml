import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    required property var capabilities
    property string bluetoothManagerCommand: ""
    property var usbDevices: []
    property bool usbLoaded: false
    property string usbError: ""
    readonly property bool usbBusy: usbDevicesRead.running

    function ensureLoaded() {
        if (!usbLoaded)
            refreshUsb();
    }

    function openBluetoothManager() {
        if (bluetoothManagerCommand !== "") {
            Quickshell.execDetached([
                "bash", "-c", bluetoothManagerCommand
            ]);
        }
    }

    function refreshUsb() {
        if (root.capabilities.ready && !root.capabilities.has("lsusb")) {
            root.usbLoaded = true;
            root.usbError = I18n.tr("Команда lsusb не установлена");
            return;
        }
        if (!usbDevicesRead.running)
            usbDevicesRead.running = true;
    }

    property Process usbReadProcess: Process {
        id: usbDevicesRead
        running: false
        command: ["bash", "-c", `
            lsusb 2>/dev/null | sed -E \
                -e '/Linux Foundation.*root hub/d' \
                -e '/Genesys Logic.*Hub/d' \
                -e 's/^Bus [0-9]+ Device [0-9]+: ID ([^ ]+) (.*)$/\\1|\\2/'
        `]
        onExited: (exitCode, exitStatus) => {
            root.usbLoaded = true;
            root.usbError = exitCode === 0
                ? "" : I18n.tr("Не удалось прочитать список USB-устройств");
        }
        stdout: StdioCollector {
            onStreamFinished: {
                root.usbDevices = text.trim().split("\n")
                    .filter(line => line.includes("|"))
                    .map(line => {
                        const split = line.indexOf("|");
                        const id = line.slice(0, split);
                        const name = line.slice(split + 1).trim();
                        const isHeadset = id === "3142:0080";
                        const isMysticLight = id === "1462:7c56";
                        const isReceiver = id === "25a7:fa70"
                            || id === "25a7:fa7c";
                        return {
                            id,
                            rawName: name,
                            name: isHeadset ? "Fifine H6"
                                : isMysticLight
                                    ? I18n.tr("Подсветка MSI Mystic Light")
                                    : isReceiver
                                        ? I18n.tr("Беспроводной ресивер") : name,
                            description: isHeadset ? I18n.tr("USB-гарнитура")
                                : isMysticLight
                                    ? I18n.tr("Внутренний RGB-контроллер материнки")
                                    : isReceiver
                                        ? I18n.tr("Мышь или клавиатура · 2.4 ГГц")
                                        : I18n.tr("USB-устройство"),
                            icon: isHeadset ? "headphones"
                                : isReceiver ? "mouse"
                                    : isMysticLight ? "lightbulb" : "usb"
                        };
                    });
            }
        }
    }
}
